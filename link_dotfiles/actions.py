"""Actions taken while linking files.
"""

from __future__ import annotations

import contextlib
import enum
import os
import shlex
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Callable, Optional

from humanize import naturalsize as fmt_bytes

from . import color as co
from . import log
from .schema import ResolvedDotfile, PrettyPath
from .table import Align, Table
from .util import has_cmd


class ActionResult(Enum):
    """The result of a user action on a dotfile.

    E.g. after diffing, we might want to ask again.
    """

    # We fixed the dotfile. It's good now, and we did work.
    FIXED = enum.auto()
    # We skipped this dotfile, or otherwise didn't do work. It'll probably
    # still need attention in the future, unless manually fixed.
    SKIPPED = enum.auto()
    # Ask the user what to do again, after an informative action like diffing
    # the installed and repository files.
    ASK_AGAIN = enum.auto()


Action = Callable[[ResolvedDotfile], ActionResult]


def diff(dotfile: ResolvedDotfile) -> ActionResult:
    """
    :returns: True if there were changes, else False
    :raises CalledProcessException: if problems calling diff
    """

    if has_cmd("delta"):
        files = [
            shlex.quote(str(name)) for name in [dotfile.installed.abs, dotfile.repo.abs]
        ]
        proc = subprocess.run(
            f"diff --unified {' '.join(files)} | delta", shell=True, check=False,
        )
    else:
        proc = subprocess.run(
            [
                "diff",
                "--unified",
                "--color=always",
                dotfile.installed.abs,
                dotfile.repo.abs,
            ],
            check=False,
        )

    if proc.returncode not in [0, 1]:
        if has_cmd("delta"):
            log.error(f"diff or delta exited with code {proc.returncode}")
        else:
            log.error(f"diff exited with code {proc.returncode}")

    return ActionResult.ASK_AGAIN


SAME_MARKER = co.GRAY + co.DIM + "[same]" + co.RESET


def _pretty_iso(dt: datetime) -> str:
    return dt.date().isoformat() + " " + co.GRAY + co.DIM + dt.strftime("%T") + co.RESET


def files_summary(dotfile: ResolvedDotfile) -> str:
    """Summarize basic differences between files.
    """

    installed_stat = os.stat(dotfile.installed.abs)
    repo_stat = os.stat(dotfile.repo.abs)

    table = Table([Align.RIGHT, Align.LEFT, Align.LEFT,])
    data = [["", dotfile.installed.disp, dotfile.repo.disp]]

    if installed_stat.st_size == repo_stat.st_size:
        data.append(["size", fmt_bytes(installed_stat.st_size), SAME_MARKER])
    else:
        installed_bigger = installed_stat.st_size > repo_stat.st_size
        data.append(
            [
                "size",
                (co.GREEN if installed_bigger else "")
                + fmt_bytes(installed_stat.st_size)
                + (co.RESET if installed_bigger else ""),
                (co.GREEN if not installed_bigger else "")
                + fmt_bytes(repo_stat.st_size)
                + (co.RESET if not installed_bigger else ""),
            ]
        )

    if installed_stat.st_mtime == repo_stat.st_mtime:
        mtime = datetime.fromtimestamp(installed_stat.st_mtime)
        data.append(
            ["last modified", mtime.isoformat(), SAME_MARKER,]
        )
    else:
        repo_dt = datetime.fromtimestamp(repo_stat.st_mtime)
        installed_dt = datetime.fromtimestamp(installed_stat.st_mtime)

        installed_newer = installed_dt > repo_dt

        repo_date = repo_dt.date()
        installed_date = installed_dt.date()
        if repo_date == installed_date:
            # Same date, different times
            data.append(
                [
                    "last modified",
                    (co.GREEN if installed_newer else "")
                    + installed_date.isoformat()
                    + " "
                    + installed_dt.strftime("%T")
                    + (co.RESET if installed_newer else ""),
                    SAME_MARKER
                    + " "
                    + (co.GREEN if not installed_newer else "")
                    + repo_dt.strftime("%T")
                    + (co.RESET if not installed_newer else ""),
                ]
            )
        else:
            # Different dates and times
            data.append(
                [
                    "last modified",
                    (co.GREEN if installed_newer else "")
                    + _pretty_iso(installed_dt)
                    + (co.RESET if installed_newer else ""),
                    (co.GREEN if not installed_newer else "")
                    + _pretty_iso(repo_dt)
                    + (co.RESET if not installed_newer else ""),
                ]
            )

    return table.render(data)


@dataclass
class EditAction(contextlib.AbstractContextManager):
    """Action which merges installed and repo dotfiles together.
    """

    dotfile: ResolvedDotfile


def edit(dotfile: ResolvedDotfile) -> ActionResult:
    """Action which merges installed and repo dotfiles together.
    """
    # TODO: Clean this up...
    nl = r"%c'\012'"
    # diff3-like output
    changed_group_fmt = (
        f"<<<<<<< {dotfile.repo.disp}{nl}"
        + "%<"  # lines from left
        + f"======={nl}"
        + "%>"  # lines from right
        + f">>>>>>> {dotfile.installed.disp}{nl}"
    )

    installed_backup = get_backup_path(dotfile.installed.abs)
    if installed_backup is None:
        return ActionResult.ASK_AGAIN

    os.rename(dotfile.installed.abs, installed_backup)
    installed_basename = os.path.basename(dotfile.installed.abs)
    repo_basename = os.path.basename(dotfile.repo.abs)

    with tempfile.TemporaryDirectory() as tmpdir:
        os.mkdir(os.path.join(tmpdir, "installed"))

        installed_tmp = os.path.join(tmpdir, "installed", installed_basename)
        shutil.copyfile(dotfile.installed.abs, installed_tmp)

        os.mkdir(os.path.join(tmpdir, "repository"))
        repo_tmp = os.path.join(tmpdir, "repository", repo_basename)
        shutil.copyfile(dotfile.repo.abs, repo_tmp)

        os.mkdir(os.path.join(tmpdir, "merged"))
        merged_tmp = os.path.join(tmpdir, "merged", repo_basename)
        proc = subprocess.run(
            [
                "diff",
                f"--changed-group-format={changed_group_fmt}",
                dotfile.repo.abs,
                dotfile.installed.abs,
            ],
            capture_output=True,
            check=False,
        )

        if proc.returncode not in [0, 1]:
            log.error(
                "While preparing files for merging, `diff` exited abnormally: "
                + proc.stderr.decode("utf-8")
            )
            log.error("stdout: " + proc.stdout.decode("utf-8"))
            return ActionResult.ASK_AGAIN

        old_merged_tmp = proc.stdout

        with open(merged_tmp, "wb") as f:
            f.write(proc.stdout)

        subprocess.run(
            [
                "nvim" if has_cmd("nvim") else "vim",
                "-d",
                installed_tmp,
                merged_tmp,
                repo_tmp,
            ],
            check=False,
        )

        with open(merged_tmp, "rb") as f:
            new_merged_tmp = f.read()

    if old_merged_tmp == new_merged_tmp:
        log.warn("Merged file wasn't changed; not copying into repo.")
        return ActionResult.ASK_AGAIN

    print(f"Writing changes to {log.path(dotfile.repo.disp)}")

    with open(dotfile.repo.abs, "wb") as f:
        f.write(new_merged_tmp)

    return fix(dotfile)


def mklink(from_path: Path, to_path: Path) -> None:
    """Create a symlink at ``from_path`` pointing to ``to_path``.
    """
    from_dir = os.path.dirname(from_path)
    if not os.path.exists(from_dir):
        os.makedirs(os.path.abspath(from_dir))
    os.symlink(to_path, from_path)


def fix(dotfile: ResolvedDotfile) -> ActionResult:
    """Action: fix an incorrect dotfile link.
    """
    if os.path.lexists(dotfile.installed.abs):
        os.remove(dotfile.installed.abs)
    mklink(dotfile.installed.abs, dotfile.link_dest)
    print(log.created_link(dotfile))
    return ActionResult.FIXED


def fix_delete(dotfile: ResolvedDotfile) -> ActionResult:
    """Action: Delete the old link destination, then ``fix``.
    """
    old_dest = os.path.join(
        os.path.dirname(dotfile.installed.abs), os.readlink(dotfile.installed.abs)
    )
    os.remove(old_dest)
    return fix(dotfile)


def replace_from_repo(dotfile: ResolvedDotfile) -> ActionResult:
    """Action: Replace installed dotfile with link to repo.
    """
    return fix(dotfile)


def overwrite_in_repo(dotfile: ResolvedDotfile) -> ActionResult:
    """Action: Replace dotfile in repo with file on disk, then make link.
    """
    shutil.copyfile(dotfile.installed.abs, dotfile.repo.abs)
    return fix(dotfile)


def get_backup_path(p: Path) -> Optional[Path]:
    """Gets the backup path for a given path.

    If the path we come up with already exists (highly unlikely), returns
    ``None``.
    """
    basename = p.name
    # e.g. "2020-10-17T18_21_41"
    # Colons aren't allowed in Windows paths, so we can't quite use ISO 8601.
    now = datetime.now().strftime("%FT%H_%M_%S")
    backup_path = p.parent / (basename + now)
    if os.path.exists(backup_path):
        # Improbable, but possible!
        log.error(
            "While creating backup path for "
            + log.path(p)
            + ", we tried "
            + log.path(backup_path)
            + ", but that path already exists"
        )
        return None
    return p


def backup(dotfile: ResolvedDotfile) -> ActionResult:
    """Action: Backup the current destination, then link.
    """
    installed_backup = get_backup_path(dotfile.installed.abs)
    if installed_backup is None:
        return ActionResult.ASK_AGAIN

    installed_backup_pretty = PrettyPath.from_path(installed_backup).disp
    log.info(f"Moving {log.path(dotfile.installed.disp)} to {installed_backup_pretty}")
    os.rename(dotfile.installed.abs, installed_backup)
    mklink(dotfile.installed.abs, dotfile.link_dest)
    return ActionResult.FIXED


def skip(_dotfile: ResolvedDotfile) -> ActionResult:
    """No-op action.
    """
    return ActionResult.SKIPPED


def quit_(_dotfile: ResolvedDotfile) -> ActionResult:
    """Action: Quit the entire program.
    """
    sys.exit(1)
