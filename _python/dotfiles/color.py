"""Coloring primitives and variables.
"""

import re

_ANSI_ESCAPE_RE = re.compile(r"\x1b\[\d+m")

RESET = "\x1b[0m"
BOLD = "\x1b[1m"
RESET_BOLD = "\x1b[21m"
DIM = "\x1b[2m"
RESET_DIM = "\x1b[22m"
UNDERLINED = "\x1b[4m"
RESET_UNDERLINED = "\x1b[24m"

RED = "\x1b[31m"
BRRED = "\x1b[91m"
GREEN = "\x1b[32m"
BRGREEN = "\x1b[92m"
YELLOW = "\x1b[33m"
BRYELLOW = "\x1b[93m"
BLUE = "\x1b[34m"
BRBLUE = "\x1b[94m"
PURPLE = "\x1b[35m"
BRPURPLE = "\x1b[95m"
CYAN = "\x1b[36m"
BRCYAN = "\x1b[96m"
GRAY = "\x1b[37m"
BRGRAY = "\x1b[97m"
RESET_FG = "\x1b[39m"


def ul(s: str) -> str:
    """Underlines a string.
    """
    return UNDERLINED + s + RESET_UNDERLINED


def display_len(s: str) -> int:
    """Gives a string's display-length, accounting for color codes.
    """
    return len(_ANSI_ESCAPE_RE.sub("", s))
