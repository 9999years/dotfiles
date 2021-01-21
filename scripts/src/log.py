"""Logging and messaging utilities.
"""

import sys
from datetime import datetime
from pathlib import Path
from typing import Union

from . import color as co
from .schema import ResolvedDotfile

OK = "🗹 "
NOT_OK = "🗷 "

PathLike = Union[str, Path]


def path(path_: PathLike) -> str:
    """A string describing a path.
    """
    return co.ul(str(path_))


def ln(from_path: PathLike, to_path: PathLike) -> str:
    """A message for a link from ``from_path`` pointing to ``to_path``.
    """
    return f"{co.ul(str(from_path))} →  {co.ul(str(to_path))}"


def ok_link(dotfile: ResolvedDotfile) -> str:
    """An output line for an already-OK dotfile.
    """
    return (
        co.DIM
        + co.GREEN
        + OK
        + " "
        + ln(dotfile.installed.disp, dotfile.link_dest)
        + co.RESET
    )


def created_link(dotfile: ResolvedDotfile) -> str:
    """An output line for a newly-created link.
    """
    return (
        co.BOLD
        + co.BRGREEN
        + OK
        + " "
        + ln(dotfile.installed.disp, dotfile.link_dest)
        + co.RESET
    )


def links_already_ok(resolved: ResolvedDotfile, num_ok: int) -> str:
    """An output line for a number of already-OK links after an OK dotfile.
    """
    return (
        ok_link(resolved)
        if num_ok == 1
        else (co.DIM + co.GREEN + OK + f" [{num_ok} links already OK]" + co.RESET)
    )


def _now() -> str:
    return datetime.now().strftime("%FT%T")


def _log(color: str, label: str, message: str) -> None:
    print(color + label + " " + message + co.RESET)


def dbg(message: str) -> None:
    """Prints a debug-level log message.
    """
    _log(co.GRAY, "🖝 ", message)


def info(message: str) -> None:
    """Prints an info-level log message.
    """
    _log(co.CYAN, "🛈 ", message)


def warn(message: str) -> None:
    """Prints a warning-level log message.
    """
    _log(co.BRYELLOW, "⚠ ", message)


def error(message: str) -> None:
    """Prints an error-level log message.
    """
    _log(co.BRRED, "⛔", message)


def fatal(message: str) -> None:
    """Prints a fatal-level log message and exits the entire program.
    """
    _log(co.BOLD + co.BRRED, "⛔ [FATAL]", message)
    sys.exit(1)
