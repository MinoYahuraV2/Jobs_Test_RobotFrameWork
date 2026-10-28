"""Small helpers for the Job Detail page tests."""
import datetime as _dt
import re

from robot.api.deco import keyword

_MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


def _squeeze(text):
    return " ".join(str(text).split())


@keyword("Thai Day Text")
def thai_day_text(utc_iso, hours=7):
    """'2026-11-25T16:59:59.999Z' + 7h -> 'Nov 25' (the day shown on the page)."""
    moment = _dt.datetime.fromisoformat(str(utc_iso).replace("Z", "+00:00"))
    local = moment + _dt.timedelta(hours=int(hours))
    return f"{_MONTHS[local.month - 1]} {local.day}"


@keyword("Description Matches Meta")
def description_matches_meta(description, meta, prefix=40):
    """meta description may be cut short; accept either one starting with the other."""
    a, b = _squeeze(description), _squeeze(meta)
    if not b:
        return False
    n = int(prefix)
    return a.startswith(b[:n]) or b.startswith(a[:n])


@keyword("Items Appear In Order")
def items_appear_in_order(seen, expected):
    """True when every expected item is in `seen`, in the same order (other items may sit between)."""
    it = iter(_squeeze(s) for s in seen)
    return all(any(_squeeze(e) == s for s in it) for e in expected)
