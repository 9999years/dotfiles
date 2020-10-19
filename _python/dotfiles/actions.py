"""Actions taken while linking files.
"""

import shlex
import shutil
import subprocess
from typing import Optional, Dict, cast, Callable
import os
from os import path
from datetime import datetime
import textwrap
import filecmp
import sys
from enum import Enum

from humanize import naturalsize as fmt_bytes, naturaltime as fmt_dt

from .schema import Path, PrettyPath, ResolvedDotfile
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
    files = [shlex.quote(name) for name in [dotfile.installed_abs, dotfile.repo_abs]]
    if has_cmd("delta"):
        proc = subprocess.run(
            f"diff --unified {' '.join(files)} | delta", shell=True, check=False,
        )
    else:
        proc = subprocess.run(
            ["diff", "--unified", "--color=always"] + files, check=False,
        )

    if proc.returncode not in [0, 1]:
        proc.check_returncode()

    return ActionResult.ASK_AGAIN


SAME_MARKER = co.GRAY + co.DIM + "[same]" + co.RESET


def _pretty_iso(dt: datetime) -> str:
    return dt.date().isoformat() + " " + co.GRAY + co.DIM + dt.strftime("%T") + co.RESET


def files_summary(actual: PrettyPath, repo: PrettyPath) -> str:
    """Summarize basic differences between files.
    """

    actual_stat = os.stat(actual.path)
    repo_stat = os.stat(repo.path)

    repo_path = log.path(repo.display)
    actual_path = log.path(actual.display)

    table = Table([Align.RIGHT, Align.LEFT, Align.LEFT,])
    data = [["", actual_path, repo_path]]

    if actual_stat.st_size == repo_stat.st_size:
        data.append(["size", fmt_bytes(actual_stat.st_size), SAME_MARKER])
    else:
        actual_bigger = actual_stat.st_size > repo_stat.st_size
        data.append(
            [
                "size",
                (co.GREEN if actual_bigger else "")
                + fmt_bytes(actual_stat.st_size)
                + (co.RESET if actual_bigger else ""),
                (co.GREEN if not actual_bigger else "")
                + fmt_bytes(repo_stat.st_size)
                + (co.RESET if not actual_bigger else ""),
            ]
        )

    if actual_stat.st_mtime == repo_stat.st_mtime:
        mtime = datetime.fromtimestamp(actual_stat.st_mtime)
        data.append(
            ["last modified", mtime.isoformat(), SAME_MARKER,]
        )
    else:
        repo_dt = datetime.fromtimestamp(repo_stat.st_mtime)
        actual_dt = datetime.fromtimestamp(actual_stat.st_mtime)

        actual_newer = actual_dt > repo_dt

        repo_date = repo_dt.date()
        actual_date = actual_dt.date()
        if repo_date == actual_date:
            # Same date, different times
            data.append(
                [
                    "last modified",
                    (co.GREEN if actual_newer else "")
                    + actual_date.isoformat()
                    + " "
                    + actual_dt.strftime("%T")
                    + (co.RESET if actual_newer else ""),
                    SAME_MARKER
                    + " "
                    + (co.GREEN if not actual_newer else "")
                    + repo_dt.strftime("%T")
                    + (co.RESET if not actual_newer else ""),
                ]
            )
        else:
            # Different dates and times
            data.append(
                [
                    "last modified",
                    (co.GREEN if actual_newer else "")
                    + _pretty_iso(actual_dt)
                    + (co.RESET if actual_newer else ""),
                    (co.GREEN if not actual_newer else "")
                    + _pretty_iso(repo_dt)
                    + (co.RESET if not actual_newer else ""),
                ]
            )

    return table.render(data)


def mklink(from_path: Path, to_path: Path):
    os.symlink(to_path, from_path)


def fix(dotfile: ResolvedDotfile) -> ActionResult:
    os.remove(dotfile.installed_abs)
    # TODO: abs links...?
    mklink(dotfile.installed_abs, dotfile.link_dest)
    return ActionResult.OK


def fix_delete(dotfile: ResolvedDotfile) -> ActionResult:
    old_dest = path.join(
        path.dirname(dotfile.installed_abs), os.readlink(dotfile.installed_abs)
    )
    os.remove(old_dest)
    return fix(dotfile)


def edit(dotfile: ResolvedDotfile) -> ActionResult:
    # We want to do a 3-way merge;
    #     old file
    #        v
    #     new result
    #        ^
    #     repo file
    # TODO: fill this in lol
    # We need to be really careful with failure modes here.
    # mktemp ...
    installed_backup = backup_path(dotfile.installed_abs)
    os.rename(dotfile.installed_abs, installed_backup)
    #  ["nvim", "-d"]
    return ActionResult.OK


def replace(dotfile: ResolvedDotfile) -> ActionResult:
    fix(dotfile)
    return ActionResult.OK


def backup_path(p: str):
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
    installed_backup = backup_path(dotfile.installed_abs)
    os.rename(dotfile.installed_abs, installed_backup)
    mklink(dotfile.installed_abs, dotfile.repo_rel)
    return ActionResult.OK


def skip(_dotfile: ResolvedDotfile) -> ActionResult:
    return ActionResult.OK


def quit_(_dotfile: ResolvedDotfile) -> ActionResult:
    sys.exit(1)
