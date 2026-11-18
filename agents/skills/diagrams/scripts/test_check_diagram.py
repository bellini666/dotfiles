"""Self-check for check_diagram.py: run with `python3 -I test_check_diagram.py`."""

import pathlib
import subprocess
import sys

HERE = pathlib.Path(__file__).parent
CHECKER = HERE / "check_diagram.py"


def check(text=None, path=None):
    args = [sys.executable, "-I", str(CHECKER)] + ([str(path)] if path else [])
    result = subprocess.run(args, input=text, capture_output=True, text=True, check=False)
    return result.returncode, result.stdout


for doc in (HERE.parent / "SKILL.md", HERE.parent / "references" / "patterns.md"):
    assert check(path=doc)[0] == 0, doc

code, out = check("╔═══╗\n║ x ║\n╚═│═╝\n")
assert code == 1 and "ERROR" in out, out

assert check("┏━━━━━┓\n┃ abc ┃\n┗━━┯━━┛\n   │\n   ▼\n")[0] == 0

code, out = check("text\n```\n┌──┐\n│\n")
assert code == 1 and "never closed" in out, out

print("ok")
