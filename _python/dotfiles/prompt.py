"""Tools for prompting for choices/options.
"""

from dataclasses import dataclass
from typing import List, Iterable, Optional, Callable, cast
import subprocess

from . import color as co
from . import actions
from .actions import has_cmd, Action, ActionResult
from .schema import ResolvedDotfile


@dataclass
class PromptChoice:
    """A choice to prompt a user for.
    """

    abbr: str
    mnemonic: str
    description: str
    action: Action

    def invoke(self, dotfile: ResolvedDotfile) -> ActionResult:
        """Calls self.action.
        """
        # WACK
        return cast(Action, getattr(self, "action"))(dotfile)


PromptChoices = List[PromptChoice]


DIFF = PromptChoice("d", "[d]iff", "diff the two files", actions.diff)
FIX = PromptChoice(
    "f", "[f]ix", "update the link to point to the new destination", actions.fix
)
FIX_DELETE = PromptChoice(
    "F",
    "[F]ix and delete",
    "update the link and delete the old destination",
    actions.fix_delete,
)
SKIP = PromptChoice("s", "[s]kip", "skip this link", actions.skip)
QUIT = PromptChoice("q", "[q]uit", "quit the entire program", actions.quit_)
EDIT = PromptChoice("e", "[e]dit", "open editor to merge changes", actions.edit)
REPLACE = PromptChoice(
    "r",
    "[r]eplace",
    "replace the file with a link to the new destination",
    actions.replace,
)
BACKUP = PromptChoice(
    "b",
    "[b]ackup",
    "backup the old file and create a link to the new destination",
    actions.backup,
)


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
    REPLACE,
    BACKUP,
    SKIP,
    QUIT,
]


def _max_len(strs: Iterable[str]) -> int:
    return max(map(len, strs))


def _fmt_ask(choices: PromptChoices) -> str:
    mnem_len = _max_len(c.mnemonic for c in choices)

    ret = []

    for choice in choices:
        mnem = (
            choice.mnemonic.ljust(mnem_len)
            .replace("[", co.UNDERLINED + co.BOLD, 1)
            .replace("]", co.RESET, 1)
        )
        ret.append(
            co.BOLD
            + co.BRBLUE
            + choice.abbr
            + co.RESET
            + "  "
            + mnem
            + "  "
            + choice.description
        )
    return "\n".join(ret)


def _ask_fzf(choices: PromptChoices) -> PromptChoice:
    formatted = _fmt_ask(choices)
    proc = subprocess.run(
        ["fzf", "--tiebreak=begin", f"--height={len(choices) + 2}", "--ansi"],
        stdout=subprocess.PIPE,
        input=formatted.encode("utf-8"),
        check=False,
    )

    if proc.returncode != 0:
        # maybe a ctrl-c!
        print(co.RED + "fzf failed" + co.RESET)
        raise ValueError

    abbr, *_ = proc.stdout.decode("utf-8").split(maxsplit=1)
    for choice in choices:
        if choice.abbr == abbr:
            return choice
    # TODO: ??? couldn't find choice from fzf ???
    raise ValueError


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
            print(
                co.YELLOW
                + "Invalid input; please choose one of the valid choices "
                + "/".join(valid_choices.keys())
                + co.RESET
            )


def ask(choices: PromptChoices) -> PromptChoice:
    """Asks the user to choose an option.

    Uses fzf if installed.
    """

    if has_cmd("fzf"):
        return _ask_fzf(choices)
    else:
        return _ask_builtin(choices)
