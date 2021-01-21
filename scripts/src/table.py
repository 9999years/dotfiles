"""Terminal-output table formatting.
"""

from dataclasses import dataclass
from enum import Enum
from typing import List, Optional, Sequence, cast

from . import color as co


class Align(Enum):
    LEFT = "l"
    RIGHT = "r"
    CENTER = "c"

    def align(self, s: str, width: int, display_len: Optional[int] = None) -> str:
        if display_len is not None:
            width += len(s) - display_len

        if self is Align.LEFT:
            return s.ljust(width)
        elif self is Align.RIGHT:
            return s.rjust(width)
        else:
            return s.center(width)


@dataclass
class Table:
    alignments: List[Align]
    col_headers: bool = True
    row_headers: bool = True
    col_sep: str = "  "

    def render(self, data: Sequence[Sequence[object]]) -> str:
        # TODO: Clean this up omg
        if (not data) or (not data[0]):
            return ""

        str_data = [[str(c) for c in row] for row in data]
        display_lens = []

        if self.col_headers:
            str_data[0] = [co.BOLD + header + co.RESET for header in str_data[0]]

        col_widths = [0 for c in str_data[0]]

        for row_ in str_data:
            if self.row_headers:
                row_[0] = co.BOLD + row_[0] + co.RESET

            row_display_lens = [co.display_len(cell) for cell in row_]
            display_lens.append(row_display_lens)
            col_widths = [
                max(old_width, display_len)
                for display_len, old_width in zip(row_display_lens, col_widths)
            ]

        ret: List[str] = []

        alignments = self.alignments

        if self.col_headers:
            ret.append(
                self.col_sep.join(
                    co.BOLD
                    + alignment.align(header, width, display_len=display_len)
                    + co.RESET
                    for header, display_len, alignment, width in zip(
                        str_data[0], display_lens[0], alignments, col_widths
                    )
                )
            )
            str_data = str_data[1:]
            display_lens = display_lens[1:]

        if self.row_headers:
            header_alignment = alignments[0]
            alignments = alignments[1:]

            header_width = col_widths[0]
            col_widths = col_widths[1:]

        for row, row_display_lens in zip(str_data, display_lens):
            prefix = ""
            if self.row_headers:
                prefix = (
                    co.BOLD
                    + header_alignment.align(
                        row[0], header_width, display_len=row_display_lens[0]
                    )
                    + co.RESET
                    + self.col_sep
                )
                row = row[1:]
                row_display_lens = row_display_lens[1:]

            ret.append(
                prefix
                + self.col_sep.join(
                    alignment.align(cell, width, display_len=display_len)
                    for alignment, width, cell, display_len in zip(
                        alignments, col_widths, row, row_display_lens
                    )
                )
            )

        return "\n".join(ret)
