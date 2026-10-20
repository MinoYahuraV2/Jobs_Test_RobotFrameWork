"""List every locator / expected value / data field that is still TODO.

Run:  python tools/list_todo.py
This is the list to hand to dev (locators) and to the team (expected values).
"""
import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "libraries"))
from Helpers import is_todo  # noqa: E402
import json  # noqa: E402


def load(path):
    spec = importlib.util.spec_from_file_location(path.stem, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def walk(name, value):
    if isinstance(value, dict):
        for key, item in value.items():
            yield from walk(f"{name}[{key}]", item)
    elif isinstance(value, list) and value and all(isinstance(v, str) for v in value):
        if is_todo(value):
            yield name
    elif isinstance(value, str) and is_todo(value):
        yield name


def report(title, path):
    module = load(path)
    items = []
    for key, value in vars(module).items():
        if key.startswith("_") or key == "TODO" or not key.isupper():
            continue
        items.extend(walk(key, value))
    print(f"\n== {title} ({len(items)} TODO) - {path.relative_to(ROOT)}")
    for item in items:
        print(f"  {item}")
    return len(items)


total = 0
total += report("Config", ROOT / "config" / "env.py")
total += report("Locators (ask dev)", ROOT / "locators" / "jobs_page.py")
total += report("Expected values / links", ROOT / "testdata" / "expected.py")
data = json.loads((ROOT / "testdata" / "jobs.json").read_text(encoding="utf-8"))
print(f"\n== Job data - testdata/jobs.json: status = {data['status']}")
print(f"\nTOTAL TODO items: {total}")
