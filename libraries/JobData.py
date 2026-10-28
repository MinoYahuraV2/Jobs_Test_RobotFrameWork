"""Expected job data + rules. The data file is meant to come from the REAL database.

testdata/jobs.json has "status": "PLACEHOLDER" until someone exports real rows.
While it is PLACEHOLDER, every test that needs data is SKIPPED.

ASSUMPTIONS (confirm with the team, then edit here):
  * Filters inside one group (e.g. 2 departments) combine with OR.
  * Filters across groups (department + job type + location) combine with AND.
  * Search matches the job title only (the real site may match more; search
    checks only require that expected titles are INCLUDED).
  * Description text is read from the data. It is never typed into a test, so a
    description change in the DB needs no test edit.
"""
import itertools
import json
import re
from pathlib import Path

from robot.api.deco import keyword

DATA_FILE = Path(__file__).resolve().parent.parent / "testdata" / "jobs.json"

WITHIN_GROUP_RULE = "OR"
ACROSS_GROUP_RULE = "AND"
POSTED_PREFIX = "Posted "
DEADLINE_PREFIX = "Due "

_GROUP_FIELD = {"departments": "department", "job_types": "job_type", "location": "location"}
_MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


def _load():
    with open(DATA_FILE, encoding="utf-8") as handle:
        return json.load(handle)


def _parse_iso(text):
    year, month, day = (int(p) for p in text.split("-"))
    return year, month, day


@keyword("Job Data Is Placeholder")
def job_data_is_placeholder():
    return str(_load().get("status", "PLACEHOLDER")).upper() != "REAL"


@keyword("Get Expected Jobs")
def get_expected_jobs():
    return _load()["jobs"]


@keyword("Distinct Values For Group")
def distinct_values_for_group(group):
    field = _GROUP_FIELD[group]
    seen = []
    for job in get_expected_jobs():
        if job[field] not in seen:
            seen.append(job[field])
    return seen


@keyword("Expected Titles")
def expected_titles(filters=None, text=""):
    """Titles the page should show for a search text + filters ({group: [values]})."""
    filters = filters or {}
    titles = []
    for job in get_expected_jobs():
        if text and text.lower() not in job["title"].lower():
            continue
        checks = []
        for group, values in filters.items():
            if not values:
                continue
            field = _GROUP_FIELD[group]
            if WITHIN_GROUP_RULE == "OR":
                checks.append(job[field] in values)
            else:
                checks.append(all(job[field] == v for v in values))
        if checks:
            ok = all(checks) if ACROSS_GROUP_RULE == "AND" else any(checks)
            if not ok:
                continue
        titles.append(job["title"])
    return titles


@keyword("Get Job")
def get_job(title):
    for job in get_expected_jobs():
        if job["title"] == title:
            return job
    raise AssertionError(f"Title shown on page is not in the data: {title!r}")


@keyword("First Title")
def first_title():
    return get_expected_jobs()[0]["title"]


@keyword("Search Keyword From Title")
def search_keyword_from_title(title):
    words = re.findall(r"[A-Za-z]{4,}", title)
    return max(words, key=len) if words else title


@keyword("Filters From First Job")
def filters_from_first_job():
    job = get_expected_jobs()[0]
    return {g: [job[f]] for g, f in _GROUP_FIELD.items()}


@keyword("Find Empty Filter Combo")
def find_empty_filter_combo(options):
    """A department+type+location combo that no job has. None if every combo has jobs."""
    for dept, jtype, loc in itertools.product(
        options["departments"], options["job_types"], options["location"]
    ):
        filters = {"departments": [dept], "job_types": [jtype], "location": [loc]}
        if not expected_titles(filters):
            return filters
    return None


def format_posted(iso):
    year, month, day = _parse_iso(iso)
    return f"{_MONTHS[month - 1]} {day}, {year}"


def format_deadline(iso):
    _, month, day = _parse_iso(iso)
    return f"{_MONTHS[month - 1]} {day}"


@keyword("Expected Card Text")
def expected_card_text(job, field):
    """Text a card should show for a field. None means the element must be ABSENT."""
    if field == "description":
        return job.get("description", "TODO")
    if field == "type_badge":
        return job["job_type"]
    if field == "department":
        return job["department"]
    if field == "location":
        return job["location"]
    if field == "work_mode":
        return job.get("work_mode") or None
    if field == "posted":
        return POSTED_PREFIX + format_posted(job["posted_date"])
    if field == "urgent_badge":
        return "Urgent" if job.get("urgent") else None
    if field == "deadline":
        return DEADLINE_PREFIX + format_deadline(job["deadline"]) if job.get("deadline") else None
    if field == "ongoing":
        return "Ongoing until filled" if job.get("ongoing_until_filled") else None
    raise ValueError(f"Unknown card field: {field}")


_FIELD_TO_DATA = {"posted": "posted_date", "work_mode": "work_mode", "ongoing": "ongoing_until_filled"}


@keyword("Any Job Has Card Field")
def any_job_has_card_field(field):
    """False when no job has data for an optional field (posted, work_mode, ongoing).
    Then a test cannot see the element on the page, so it should SKIP."""
    key = _FIELD_TO_DATA.get(field)
    if key is None:
        return True
    return any(job.get(key) for job in get_expected_jobs())


@keyword("Posted Dates Are Newest First")
def posted_dates_are_newest_first(texts):
    dates = []
    for text in texts:
        match = re.search(r"([A-Z][a-z]{2}) (\d{1,2}), (\d{4})", text)
        if not match:
            raise AssertionError(f"Cannot read a posted date from: {text!r}")
        dates.append((int(match.group(3)), _MONTHS.index(match.group(1)), int(match.group(2))))
    return all(a >= b for a, b in zip(dates, dates[1:]))


@keyword("Number From Text")
def number_from_text(text):
    match = re.search(r"\d+", text)
    if not match:
        raise AssertionError(f"No number in: {text!r}")
    return int(match.group(0))
