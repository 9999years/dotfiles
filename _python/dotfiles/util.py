"""Various utilities that don't fit elsewhere.
"""

import subprocess
from functools import lru_cache


class Unreachable(RuntimeError):
    """An exception raised when theoretically-unreachable code is hit.

    Comparable to Rust's ``unreachable!()`` panic-macro.
    """


@lru_cache(maxsize=128)
def has_cmd(cmd: str) -> bool:
    """Determines if an executable exists.

    Runs ``{cmd} --version``.
    """
    try:
        proc = subprocess.run(
            [cmd, "--version"], stdout=subprocess.DEVNULL, check=False
        )
    except FileNotFoundError:
        return False
    return proc.returncode == 0
