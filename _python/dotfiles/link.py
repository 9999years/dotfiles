"""Linking the dotfiles themselves.
"""

import enum
from dataclasses import dataclass
import os
from os import path
import filecmp

from .schema import Dotfile, ResolvedDotfile, Path, PrettyPath
from . import log
from . import color as co
from . import actions
from . import prompt
from .actions import ActionResult, mklink
from .util import Unreachable


class Status(enum.Enum):
    """The status of an installed dotfile.
    """

    # The link already exists and points to the correct file.
    OK = enum.auto()
    # The link exists but points somewhere else; such a link may be broken.
    DIFF_DEST = enum.auto()
    # The path doesn't exist at all.
    MISSING = enum.auto()
    # The path exists and is a regular file/dir, not a link.
    NOT_LINK = enum.auto()


@dataclass
class Linker:
    """Manages the context around linking a set of dotfiles.
    """

    # The repository root; this is where the canonical dotfiles are stored, and
    # might be `~/.dotfiles`.
    repo_root: Path

    # The link root; this is where the dotfiles are linked from, and is usually
    # `~`.
    link_root: Path

    # Should links be relative?
    relative: bool = True

    # If True, don't actually link anything.
    dry_run: bool = False

    def status(self, resolved: ResolvedDotfile) -> Status:
        """Get the status of a given dotfile.
        """
        exists = path.exists(resolved.installed.abs)

        if path.islink(resolved.installed.abs):
            if not exists:
                # Broken symlink.
                return Status.DIFF_DEST

            # Get the link destination as an absolute path.
            dest = path.join(
                path.dirname(resolved.installed.abs),
                os.readlink(resolved.installed.abs),
            )
            if path.samefile(dest, resolved.repo.abs):
                # The link points to the correct file.
                return Status.OK
            else:
                # The link points somewhere else.
                return Status.DIFF_DEST

        else:
            if exists:
                # A regular file.
                return Status.NOT_LINK
            else:
                # Missing.
                return Status.MISSING

    def resolve(self, dotfile: Dotfile) -> ResolvedDotfile:
        """Resolve a dotfile from configuration.
        """
        installed = path.join(self.link_root, dotfile.installed)
        repo = path.join(self.repo_root, dotfile.repo)
        link_dest = repo
        if self.relative:
            prefix = path.commonpath([installed, link_dest])
            if prefix != os.sep:
                link_dest = path.relpath(link_dest, path.dirname(installed))
        return ResolvedDotfile(
            repo=PrettyPath.from_path(rel=dotfile.repo, abs=Path(repo),),
            installed=PrettyPath.from_path(rel=dotfile.installed, abs=Path(installed),),
            link_dest=Path(link_dest),
            when=dotfile.when,
        )

    def link(self, dotfile: Dotfile):
        """Link a dotfile from configuration.
        """
        resolved = self.resolve(dotfile)
        status = self.status(resolved)
        link_str = log.ln(str(resolved.installed.disp), str(resolved.link_dest))
        if status is Status.OK:
            # no action needed
            print(log.ok_link(resolved))

        elif status is Status.MISSING:
            # create unless dry run
            mklink(resolved.installed.abs, resolved.link_dest)
            print(log.created_link(resolved))

        elif status is Status.DIFF_DEST:
            # a link, but with a different destination
            print(
                co.RED + log.NOT_OK, link_str + co.RESET,
            )
            self._fix(resolved, status)

        elif status is Status.NOT_LINK:
            print(
                co.RED + log.NOT_OK, resolved.installed.disp, "is not a link" + co.RESET
            )
            self._fix(resolved, status)

    def _fix(self, resolved: ResolvedDotfile, status: Status):
        if status is not Status.NOT_LINK and status is not Status.DIFF_DEST:
            raise Unreachable

        if not path.exists(resolved.repo.abs):
            log.fatal(f"{resolved.repo.abs} doesn't exist!")

        if filecmp.cmp(resolved.installed.abs, resolved.repo.abs, shallow=False):
            # The files are the same! Just fix them up.
            if status is Status.DIFF_DEST:
                # TODO: oh my g-d test this
                installed_dest = path.join(
                    path.dirname(resolved.installed.abs),
                    os.readlink(resolved.installed.abs),
                )
                os.remove(installed_dest)

            actions.fix(resolved)  # TODO: handle result...?
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
                if choice.invoke(resolved) != ActionResult.ASK_AGAIN:
                    break
