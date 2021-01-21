"""Linking the dotfiles themselves.
"""

import enum
import filecmp
import os
from dataclasses import dataclass
from enum import Enum
from typing import List

from . import actions
from . import color as co
from . import log, prompt
from .actions import ActionResult, mklink
from .schema import ResolvedDotfile, Status
from .util import Unreachable


class LinkStatus(Enum):
    """The result of linking a dotfile. In short, did any work happen?
    """

    # Link was already OK
    OK = enum.auto()
    # Link was newly-created or fixed
    FIXED = enum.auto()
    # This dotfile was skipped or another error occured.
    ERROR = enum.auto()


@dataclass
class Linker:
    """Manages the context around linking a set of dotfiles.
    """

    # If True, don't actually link anything.
    dry_run: bool = False

    # Should we collapse multiple ok links in output to one line?
    verbose: bool = False

    def link_all(self, dotfiles: List[ResolvedDotfile]) -> None:
        """Link a list of dotfiles from configuration.
        """
        # Count of already ok links, collapsed in output to one line
        num_ok = 0

        for resolved in dotfiles:
            is_ok = _link_dotfile(resolved) is LinkStatus.OK
            if self.verbose:
                if is_ok:
                    print(log.ok_link(resolved))

            else:
                if is_ok:
                    if num_ok != 0:
                        print(co.move_cursor_up_beginning(1) + co.CLEAR_LINE, end="")
                    num_ok += 1
                    print(log.links_already_ok(resolved, num_ok))
                else:
                    num_ok = 0


def _link_dotfile(resolved: ResolvedDotfile) -> LinkStatus:
    """Link a dotfile from configuration.
    """
    status = resolved.status
    link_str = log.ln(str(resolved.installed.disp), str(resolved.link_dest))
    if status is Status.OK:
        # no action needed
        return LinkStatus.OK

    elif status is Status.MISSING:
        # create unless dry run
        mklink(resolved.installed.abs, resolved.link_dest)
        print(log.created_link(resolved))
        return LinkStatus.FIXED

    elif status is Status.DIFF_DEST:
        # a link, but with a different destination
        print(
            co.RED + log.NOT_OK, link_str + co.RESET,
        )
        return _fix_link(resolved, status)

    elif status is Status.NOT_LINK:
        print(co.RED + log.NOT_OK, resolved.installed.disp, "is not a link" + co.RESET)
        return _fix_link(resolved, status)

    else:
        raise Unreachable


def _fix_link(resolved: ResolvedDotfile, status: Status) -> LinkStatus:
    if status is not Status.NOT_LINK and status is not Status.DIFF_DEST:
        raise Unreachable

    if not resolved.repo.abs.exists():
        log.fatal(f"{resolved.repo.abs} doesn't exist!")

    if filecmp.cmp(resolved.installed.abs, resolved.repo.abs, shallow=False):
        log.info(
            log.path(resolved.installed.disp)
            + " and "
            + log.path(resolved.repo.disp)
            + " have the same contents; replacing with a link"
        )
        # The files are the same! Just fix them up.
        if status is Status.DIFF_DEST:
            # TODO: oh my g-d test this
            installed_dest = resolved.installed.abs.parent / os.readlink(
                resolved.installed.abs
            )
            os.remove(installed_dest)

        res = actions.fix(resolved)
        if res is not ActionResult.OK:
            log.error(
                f"Unexpected result {res} while fixing {log.path(resolved.installed.disp)}"
            )
            return LinkStatus.ERROR

        return LinkStatus.FIXED
    else:
        # show stat-diff summary, etc
        print(actions.files_summary(resolved))
        choices = (
            prompt.NOT_LINK_CHOICES
            if status is Status.NOT_LINK
            else prompt.DIFF_DEST_CHOICES
        )
        while True:
            choice = prompt.ask(choices)
            res = choice.invoke(resolved)
            if res is ActionResult.OK:
                return LinkStatus.FIXED
            elif res is ActionResult.SKIPPED:
                return LinkStatus.ERROR
            else:
                # ask again
                pass
