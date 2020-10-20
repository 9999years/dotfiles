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


def files_summary(actual: PrettyPath, repo: PrettyPath) -> str:
    #  """Summarize basic differences between files.
    #  """
    columns, _lines = shutil.get_terminal_size()
    ret = []

    _wrapper = textwrap.TextWrapper(
        width=columns, break_long_words=False, break_on_hyphens=False
    )

    def append(text: str):
        ret.append(_wrapper.fill(text))

    actual_stat = os.stat(actual.path)
    repo_stat = os.stat(repo.path)

    repo_path = log.path(repo.display)
    actual_path = log.path(actual.display)

    #  if filecmp.cmp(repo.path, actual.path):
    #  append(co.BOLD + f"Both files have the same content." + co.RESET)

    if actual_stat.st_size == repo_stat.st_size:
        append("Both are {}".format(fmt_bytes(actual_stat.st_size)))
    else:
        append(
            f"{repo_path} is {fmt_bytes(repo_stat.st_size)}, "
            + f"but {actual_path} is {fmt_bytes(actual_stat.st_size)}."
        )

    if actual_stat.st_mtime == repo_stat.st_mtime:
        mtime = datetime.fromtimestamp(actual_stat.st_mtime)
        append(f"Both were last modified {fmt_dt(mtime)}.")
    else:
        repo_dt = datetime.fromtimestamp(repo_stat.st_mtime)
        actual_dt = datetime.fromtimestamp(actual_stat.st_mtime)

        if repo_dt > actual_dt:
            append(f"{repo_path} was last modified most recently.")
        else:
            append(f"{actual_path} was last modified most recently.")

        repo_date = repo_dt.date()
        actual_date = actual_dt.date()
        if repo_date == actual_date:
            append(
                f"{repo_path} and {actual_path} "
                + f"were both last modified on {repo_date.isoformat()}, "
                + f"but {repo_path} was modified at {repo_dt.time().isoformat()}, "
                + f"while {actual_path} was modified {actual_dt.time().isoformat()}."
            )
        else:
            append(
                f"{repo_path} was last modified {repo_date.isoformat()}, "
                + f"but {actual_path} was last modified {actual_date.isoformat()}."
            )

    return "\n".join(ret)


def mklink(from_path: Path, to_path: Path):
    os.symlink(to_path, from_path)


def fix(dotfile: ResolvedDotfile) -> ActionResult:
    os.remove(dotfile.installed_abs)
    # TODO: abs links...?
    mklink(dotfile.installed_abs, dotfile.repo_rel)
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
