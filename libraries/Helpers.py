"""Small helpers: placeholder detection, locator building, browser options."""
from robot.api.deco import keyword


def _scalar_is_todo(value):
    if value is None:
        return True
    text = str(value).strip()
    return text == "" or text.upper().startswith("TODO")


@keyword("Is Todo")
def is_todo(value):
    """True when a value (or any item inside a list/dict) is still a placeholder."""
    if isinstance(value, (list, tuple)):
        return len(value) == 0 or any(is_todo(v) for v in value)
    if isinstance(value, dict):
        return len(value) == 0 or any(is_todo(v) for v in value.values())
    return _scalar_is_todo(value)


@keyword("Format Locator")
def format_locator(template, **values):
    """Fill {label}/{group} in a locator template. Stays TODO if template is TODO."""
    if is_todo(template):
        return "TODO"
    return template.format(**values)


def _xpath_body(locator):
    for prefix in ("xpath=", "xpath:"):
        if locator.startswith(prefix):
            return locator[len(prefix):]
    if locator.startswith(("//", "(", ".")):
        return locator
    raise ValueError(f"Card locators must be xpath, got: {locator}")


@keyword("Card Child")
def card_child(card_locator, index, child_locator):
    """Locator of a child inside the Nth job card (1-based). TODO if either is TODO."""
    if is_todo(card_locator) or is_todo(child_locator):
        return "TODO"
    base = _xpath_body(card_locator)
    child = _xpath_body(child_locator)
    if child.startswith("."):
        child = child[1:]
    return f"xpath=({base})[{int(index)}]{child}"


@keyword("Build Browser Options")
def build_browser_options(headless=False):
    args = ["--window-size=1440,1000"]
    if headless:
        args.insert(0, "--headless=new")
    return ";".join(f'add_argument("{a}")' for a in args)
