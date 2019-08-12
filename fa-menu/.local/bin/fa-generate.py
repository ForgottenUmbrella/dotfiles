#!/usr/bin/env python3
"""Generate Rofi/dmenu input for searching Font Awesome icons.

Each line of output will be in the following form (note the hard tab):
    <icon>	<name> (<term 1>, <term 2>, ...)
If there are no search terms, the parentheses will be omitted.
Note that a hard tab is used due to weird font quirks regarding Font
Awesome icons and spaces, creating mojibake. The tab character doesn't
experience this issue, so it is used instead.

You can copy the icon from Rofi by doing the following in your shell:
    ./fa-generate.py | rofi -dmenu | cut -f 1 | tr -d "\n" | xsel --clipboard
Substitute `rofi -dmenu` with just `dmenu` to use dmenu in place of
Rofi.

Better yet, you can cache the output for reuse by Rofi by doing:
    ./fa-generate.py > icons.txt
and then, to use the file to copy an icon:
    cat icons.txt | rofi -dmenu | cut -f 1 | tr -d "\n" | xsel --clipboard

**Notes on the format of the JSON file**
As of 2019-05-07, the relevant fields of each key of the JSON object are
encoded as follows:
    <id>: {
        "search": {
            "terms": [<term 1>, <term 2>, ...]
        },
        "unicode": <hex string matching regex /[0-9a-f]{4}/>,
        "label": <name>
    }
"""

from urllib.request import urlopen
from typing import Mapping
import json

# URL to the JSON file containing icon metadata, subject to change.
URL = "https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/metadata/icons.json"


def main() -> None:
    """Print Rofi input."""
    with urlopen(URL) as file:
        icons = json.loads(file.read())
        for icon in icons.values():
            print(Icon(icon))


class Icon:
    def __init__(self, icon: Mapping):
        self.icon = chr(int(icon["unicode"], base=16))
        self.name = icon["label"]
        self.terms = icon["search"]["terms"]

    def __str__(self) -> str:
        """Return Rofi input as per module docstring."""
        return f"{self.icon}\t{self.name} ({', '.join(self.terms)})".replace(
            " ()", ""
        )


if __name__ == "__main__":
    main()
