"""Tools for prompting for choices/options.
"""

import subprocess
from dataclasses import dataclass
from typing import Iterable, List, Optional, cast

from . import actions
from . import color as co
from . import log
from .actions import Action, ActionResult, ScanAction
from .schema import PrettyPath, ResolvedDotfile
from .util import Unreachable, has_cmd


@dataclass
class _PromptChoice:
    """Base class: A choice to prompt a user for.
    """

    abbr: str
    mnemonic: str
    description: str
    announcement: str

    def fmt(self, mnem_len: int) -> str:
        """Format this prompt for ``fzf`` display.
        """
        mnem = (
            self.mnemonic.ljust(mnem_len)
            .replace("[", co.UNDERLINED + co.BOLD, 1)
            .replace("]", co.RESET, 1)
        )
        return (
            co.BOLD
            + co.BRBLUE
            + self.abbr
            + co.RESET
            + "  "
            + mnem
            + "  "
            + self.description
        )


@dataclass
class PromptChoice(_PromptChoice):
    """A choice to prompt a user for.
    """

    action: Action

    def invoke(self, dotfile: ResolvedDotfile) -> ActionResult:
        """Calls self.action.
        """
        # WACK.
        #  - `getattr(...)` prevents a "redundant cast" warning.
        #  - `cast(...)` prevents Python from passing `self` to the action.
        # See: https://github.com/python/mypy/issues/6910
        return cast(Action, getattr(self, "action"))(dotfile)


@dataclass
class ScanPromptChoice(_PromptChoice):
    """A choice to prompt a user for.
    """

    action: ScanAction

    def invoke(self, path: PrettyPath) -> ActionResult:
        """Calls self.action.
        """
        # See `PromptChoice.invoke`.
        return cast(ScanAction, getattr(self, "action"))(path)


PromptChoices = List[PromptChoice]


DIFF = PromptChoice("d", "[d]iff", "diff the two files", "Diffing!", actions.diff)
FIX = PromptChoice(
    "f",
    "[f]ix",
    "update (replace) the link to point to the new destination",
    "Fixing!",
    actions.fix,
)
FIX_DELETE = PromptChoice(
    "F",
    "[F]ix and delete",
    "update (replace) the link and delete the old destination",
    "Fixing and deleting the old destination!",
    actions.fix_delete,
)
SKIP = PromptChoice("s", "[s]kip", "skip this link", "Skipping!", actions.skip)
QUIT = PromptChoice(
    "q", "[q]uit", "quit the entire program", "Quitting!", actions.quit_
)
EDIT = PromptChoice(
    "e",
    "[e]dit",
    "open editor to merge changes",
    "Opening an editor to merge changes!",
    actions.edit,
)
REPLACE_FROM_REPO = PromptChoice(
    "r",
    "[r]eplace",
    "replace the file with a link to the new destination",
    "Replacing the old file with a link!",
    actions.replace_from_repo,
)
OVERWRITE_IN_REPO = PromptChoice(
    "o",
    "[o]verwrite repository",
    "replace the file with a link to the new destination",
    "Copying installed file over repository version and then creating a link!",
    actions.overwrite_in_repo,
)
BACKUP = PromptChoice(
    "b",
    "[b]ackup",
    "backup the old file and create a link to the new destination",
    "Backing up the old file and then creating a link!",
    actions.backup,
)

SCAN_SKIP = ScanPromptChoice(
    "s", "[s]kip", "skip this file/directory", "Skipping!", actions.skip,
)
SCAN_ADD = ScanPromptChoice(
    "a",
    "[a]dd",
    "add this file/directory to the dotfiles repo",
    "Adding to repository!",
    actions.scan_add,
)
IGNORE = ScanPromptChoice(
    "i", "[i]gnore", "ignore this file/directory", "Ignoring!", actions.scan_ignore
)
RECURSE = ScanPromptChoice(
    "r", "[r]ecurse", "recurse into this directory", "Recursing!", actions.scan_recurse
)
CAT = ScanPromptChoice("c", "[c]at", "cat this file", "Catting!", actions.scan_cat)


DIFF_DEST_CHOICES: List[PromptChoice] = [
    DIFF,
    FIX,
    FIX_DELETE,
    SKIP,
    QUIT,
]

NOT_LINK_CHOICES = [
    DIFF,
    EDIT,
    REPLACE_FROM_REPO,
    OVERWRITE_IN_REPO,
    BACKUP,
    SKIP,
    QUIT,
]


def _max_len(strs: Iterable[str]) -> int:
    return max(map(len, strs))


def _fmt_ask(choices: PromptChoices) -> str:
    mnem_len = _max_len(c.mnemonic for c in choices)

    return "\n".join(choice.fmt(mnem_len) for choice in choices)


def _ask_fzf(choices: PromptChoices) -> PromptChoice:
    formatted = _fmt_ask(choices)
    proc = subprocess.run(
        ["fzf", "--tiebreak=begin", f"--height={len(choices) + 2}", "--ansi"],
        stdout=subprocess.PIPE,
        input=formatted.encode("utf-8"),
        check=False,
    )

    if proc.returncode != 0:
        log.fatal("fzf exited abnormally")

    abbr, *_ = proc.stdout.decode("utf-8").split(maxsplit=1)
    for choice in choices:
        if choice.abbr == abbr:
            return choice

    log.fatal(
        "fzf wrote "
        + repr(proc.stdout)
        + " to stdout, which didn't match an expected choice"
    )
    raise Unreachable


def _ask_builtin(choices: PromptChoices) -> PromptChoice:
    valid_choices = {c.abbr: c for c in choices}
    formatted = _fmt_ask(choices)
    print(formatted)

    while True:
        given_choice = input(co.BOLD + co.BRBLUE + "> " + co.RESET).strip()
        prompt_choice: Optional[PromptChoice] = valid_choices.get(given_choice, None)
        if prompt_choice is not None:
            return prompt_choice
        else:
            log.warn(
                "Invalid input; please enter one of " + "/".join(valid_choices.keys())
            )


def ask(choices: PromptChoices) -> PromptChoice:
    """Asks the user to choose an option.

    Uses fzf if installed.
    """

    if has_cmd("fzf"):
        ret = _ask_fzf(choices)
    else:
        ret = _ask_builtin(choices)

    print(co.BOLD + co.CYAN + ret.announcement + co.RESET)
    return ret
