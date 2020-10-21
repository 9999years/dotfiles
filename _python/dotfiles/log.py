"""Logging and messaging utilities.
"""

import sys
from datetime import datetime

from . import color as co
from .schema import ResolvedDotfile

OK = "🗹 "
NOT_OK = "🗷 "


def path(path_str: str) -> str:
    """A string describing a path.
    """
    return co.ul(path_str)


def ln(from_path: str, to_path: str) -> str:
    """A message for a link from ``from_path`` pointing to ``to_path``.
    """
    return f"{co.ul(from_path)} →  {co.ul(to_path)}"


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
    return (
        ok_link(resolved)
        if num_ok == 1
        else (co.DIM + co.GREEN + OK + f" [{num_ok} links already OK]" + co.RESET)
    )


def _now() -> str:
    return datetime.now().strftime("%FT%T")


def _log(color: str, label: str, message: str):
    print(color + label + " " + message + co.RESET)


def dbg(message: str):
    """Prints a debug-level log message.
    """
    _log(co.GRAY, "[debug]", message)


def info(message: str):
    """Prints an info-level log message.
    """
    _log(co.CYAN, "", message)


def warn(message: str):
    """Prints a warning-level log message.
    """
    _log(co.BRYELLOW, "[warn] ", message)


def error(message: str):
    """Prints an error-level log message.
    """
    _log(co.BRRED, "[error]", message)


def fatal(message: str):
    """Prints a fatal-level log message and exits the entire program.
    """
    _log(co.BOLD + co.BRRED, "[FATAL]", message)
    sys.exit(1)
