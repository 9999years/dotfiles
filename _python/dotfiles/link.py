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
from .actions import ActionResult
from .util import Unreachable


class Status(enum.Enum):
    # The link already exists and points to the correct file.
    OK = enum.auto()
    # The link exists but points somewhere else.
    DIFF_DEST = enum.auto()
    # The path doesn't exist at all.
    MISSING = enum.auto()
    # The path exists and is a regular file/dir, not a link.
    NOT_LINK = enum.auto()


@dataclass
class Linker:
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
        if not path.exists(resolved.installed_abs):
            # The path doesn't exist at all.
            return Status.MISSING
        elif path.islink(resolved.installed_abs):
            # The path is a link; get the link destination as an absolute path.
            dest = path.join(
                path.dirname(resolved.installed_abs),
                os.readlink(resolved.installed_abs),
            )
            if path.samefile(dest, resolved.repo_abs):
                # The link points to the correct file.
                return Status.OK
            else:
                # The link points somewhere else.
                return Status.DIFF_DEST
        else:
            # The path isn't a link.
            return Status.NOT_LINK

    def resolve(self, dotfile: Dotfile) -> ResolvedDotfile:
        installed = path.join(self.link_root, dotfile.installed)
        repo = path.join(self.repo_root, dotfile.repo)
        link_dest = repo
        if self.relative:
            prefix = path.commonpath([installed, link_dest])
            if prefix != os.sep:
                link_dest = path.relpath(link_dest, path.dirname(installed))
        return ResolvedDotfile(
            repo_rel=dotfile.repo,
            repo_abs=Path(repo),
            link_dest=Path(link_dest),
            installed_rel=dotfile.installed,
            installed_abs=Path(installed),
            when=dotfile.when,
        )

    def link(self, dotfile: Dotfile):
        resolved = self.resolve(dotfile)
        status = self.status(resolved)
        link_str = log.ln(
            str(PrettyPath.from_path(resolved.installed_abs)),
            str(PrettyPath.from_path(resolved.link_dest)),
        )
        if status is Status.OK:
            # no action needed
            print(
                co.DIM + co.GREEN + log.OK, link_str + co.RESET,
            )

        elif status is Status.DIFF_DEST:
            # a link, but with a different destination
            print(
                co.RED + log.NOT_OK, link_str + co.RESET,
            )
            # check for same content!
            # show stat diff summary
            while True:
                choice = prompt.ask(prompt.DIFF_DEST_CHOICES)
                if choice.invoke(resolved) != ActionResult.ASK_AGAIN:
                    break
            print("Actual destination:", os.readlink(resolved.installed_abs))

        elif status is Status.MISSING:
            # create unless dry run
            #  print(
            #  co.RED + log.NOT_OK, link_str, "(missing)" + co.RESET,
            #  )
            #  os.link(
            print(co.BRGREEN + log.OK, link_str + co.RESET)

        elif status is Status.NOT_LINK:
            print(
                co.RED + log.NOT_OK,
                str(PrettyPath.from_path(resolved.installed_abs)),
                "is not a link" + co.RESET
                #  co.RED + log.NOT_OK, link_str, "(not a link)" + co.RESET,
            )
            # check for same content!
            # show stat diff summary
            print(
                actions.files_summary(
                    PrettyPath.from_path(resolved.installed_abs),
                    PrettyPath.from_path(resolved.repo_abs),
                )
            )
            while True:
                choice = prompt.ask(prompt.NOT_LINK_CHOICES)
                if choice.invoke(resolved) != ActionResult.ASK_AGAIN:
                    break

    def fix(self, resolved: ResolvedDotfile, status: Status):
        if status is not Status.NOT_LINK and status is not Status.DIFF_DEST:
            raise Unreachable

        if filecmp.cmp(resolved.installed_abs, resolved.repo_abs, shallow=False):
            # The files are the same! Just fix them up.
            if status is Status.DIFF_DEST:
                # TODO: oh my g-d test this
                installed_dest = path.join(
                    path.dirname(resolved.installed_abs),
                    os.readlink(resolved.installed_abs),
                )
                os.remove(installed_dest)

            actions.fix(resolved)  # TODO: handle result...?
        else:
            # show stat-diff summary, etc
            print(
                actions.files_summary(
                    PrettyPath.from_path(resolved.installed_abs),
                    PrettyPath.from_path(resolved.repo_abs),
                )
            )
            choices = (
                prompt.NOT_LINK_CHOICES
                if status is Status.NOT_LINK
                else prompt.DIFF_DEST_CHOICES
            )
            while True:
                choice = prompt.ask(choices)
                if choice.invoke(resolved) != ActionResult.ASK_AGAIN:
                    break
