"""Actions taken while linking files.
"""

import shlex
import shutil
import subprocess
from typing import Callable
from enum import Enum
import os
from os import path
from datetime import datetime
import sys
import tempfile

from humanize import naturalsize as fmt_bytes

from .schema import Path, ResolvedDotfile
from . import log
from . import color as co
from .util import has_cmd
from .table import Align, Table


class ActionResult(Enum):
    """The result of a user action on a dotfile.

    E.g. after diffing, we might want to ask again.
    """

    OK = "OK"
    ASK_AGAIN = "ASK_AGAIN"


Action = Callable[[ResolvedDotfile], ActionResult]


def diff(dotfile: ResolvedDotfile) -> ActionResult:
    """
    :returns: True if there were changes, else False
    :raises CalledProcessException: if problems calling diff
    """

    # TODO: Check for `dotfile.installed_abs` is a symlink
    if has_cmd("delta"):
        files = [
            shlex.quote(name) for name in [dotfile.installed.abs, dotfile.repo.abs]
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
        proc.check_returncode()

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


def edit(dotfile: ResolvedDotfile) -> ActionResult:
    nl = r"%c'\012'"
    changed_group_fmt = (
        f"<<<<<<< {dotfile.repo.disp}{nl}"
        + "%<"  # lines from left
        + f"======={nl}"
        + "%>"  # lines from right
        + ">>>>>>> {dotfile.installed.disp}{nl}"
    )

    installed_backup = get_backup_path(dotfile.installed.abs)
    os.rename(dotfile.installed.abs, installed_backup)
    installed_basename = path.basename(dotfile.installed.abs)
    repo_basename = path.basename(dotfile.repo.abs)

    with tempfile.TemporaryDirectory() as tmpdir:
        os.mkdir(path.join(tmpdir, "installed"))

        installed_tmp = path.join(tmpdir, "installed", installed_basename)
        shutil.copyfile(dotfile.installed.abs, installed_tmp)

        os.mkdir(path.join(tmpdir, "repository"))
        repo_tmp = path.join(tmpdir, "repository", repo_basename)
        shutil.copyfile(dotfile.repo.abs, repo_tmp)

        os.mkdir(path.join(tmpdir, "merged"))
        merged_tmp = path.join(tmpdir, "merged", repo_basename)
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
            proc.check_returncode()

        old_merged_tmp = proc.stdout

        with open(merged_tmp, "wb") as f:
            f.write(proc.stdout)

        subprocess.run(["nvim", "-d", installed_tmp, merged_tmp, repo_tmp], check=False)

        with open(merged_tmp, "rb") as f:
            new_merged_tmp = f.read()

    if old_merged_tmp == new_merged_tmp:
        log.warn("Merged file unchanged")
        return ActionResult.ASK_AGAIN

    print(f"Writing changes to {log.path(dotfile.repo.disp)}")

    with open(dotfile.repo.abs, "wb") as f:
        f.write(new_merged_tmp)

    return fix(dotfile)


def mklink(from_path: Path, to_path: Path):
    from_dir = path.dirname(from_path)
    if not path.exists(from_dir):
        os.makedirs(path.abspath(from_dir))
    os.symlink(to_path, from_path)


def fix(dotfile: ResolvedDotfile) -> ActionResult:
    if path.lexists(dotfile.installed.abs):
        os.remove(dotfile.installed.abs)
    mklink(dotfile.installed.abs, dotfile.link_dest)
    print(log.created_link(dotfile))
    return ActionResult.OK


def fix_delete(dotfile: ResolvedDotfile) -> ActionResult:
    old_dest = path.join(
        path.dirname(dotfile.installed.abs), os.readlink(dotfile.installed.abs)
    )
    os.remove(old_dest)
    return fix(dotfile)


def replace_from_repo(dotfile: ResolvedDotfile) -> ActionResult:
    """Replace installed dotfile with link to repo.
    """
    fix(dotfile)
    return ActionResult.OK


def overwrite_in_repo(dotfile: ResolvedDotfile) -> ActionResult:
    """Replace dotfile in repo with file on disk, then make link.
    """
    shutil.copyfile(dotfile.installed.abs, dotfile.repo.abs)
    fix(dotfile)
    return ActionResult.OK


def get_backup_path(p: str):
    basename = path.basename(p)
    # e.g. "2020-10-17T18_21_41"
    # Colons aren't allowed in Windows paths, so we can't quite use ISO 8601.
    now = datetime.now().strftime("%FT%H_%M_%S")
    backup_path = path.join(path.dirname(p), basename + now)
    if path.exists(backup_path):
        # Improbable, but possible!
        # TODO: Handle 'backup path exists' case better.
        raise ValueError("Backup path " + backup_path + " already exists")
    return p


def backup(dotfile: ResolvedDotfile) -> ActionResult:
    installed_backup = get_backup_path(dotfile.installed.abs)
    os.rename(dotfile.installed.abs, installed_backup)
    mklink(dotfile.installed.abs, dotfile.link_dest)
    return ActionResult.OK


def skip(_dotfile: ResolvedDotfile) -> ActionResult:
    return ActionResult.OK


def quit_(_dotfile: ResolvedDotfile) -> ActionResult:
    sys.exit(1)
