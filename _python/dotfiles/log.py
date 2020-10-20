"""Logging and messaging utilities.
"""

from datetime import datetime
import sys

from . import color as co

OK = "🗹 "
NOT_OK = "🗷 "
PROG_NAME = "dotfiles"


def path(path_str: str) -> str:
    """A string describing a path.
    """
    return co.ul(path_str)


def ln(from_path: str, to_path: str) -> str:
    """A message for a link from ``from_path`` pointing to ``to_path``.
    """
    return f"{co.ul(from_path)} →  {co.ul(to_path)}"


def _now() -> str:
    return datetime.now().strftime("%FT%T")


def _log(color: str, label: str, message: str):
    print(color + label + " " + PROG_NAME + f" [{_now()}]: " + message + co.RESET)


def dbg(message: str):
    """Prints a debug-level log message.
    """
    _log(co.GRAY, "[debug]", message)


def info(message: str):
    """Prints an info-level log message.
    """
    _log(co.BRGREEN, "[info] ", message)


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
