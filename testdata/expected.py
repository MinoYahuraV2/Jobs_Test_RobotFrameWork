"""Expected TEXT and link targets. Checked against the dev site (https://career-web-dev.eventpass.biz) where noted, else from Figma.
"TODO" = not known yet. Tests that need a TODO value are SKIPPED, not failed.
"""
TODO = "TODO"

# ---- Display rule by number of jobs (from the designer) ----
# 1 to 5 jobs  -> Search bar, Filter and Filter tags are hidden; only job cards show.
# 6+ jobs      -> Search bar and Filter show automatically.
MIN_JOBS_FOR_SEARCH_FILTER = 6
SORT_HIDDEN_WHEN_FEW = True  # ASSUMPTION: Sort also hides with 1-5 jobs (Figma 2-job page has no Sort). Confirm.

# ---- Hero / search / sort ----
HERO_TITLE_TEXT = "Find your next role."
SEARCH_PLACEHOLDER = "Search by job title or keywords..."
SEARCH_NO_MATCH_TEXT = "zzzz-no-such-job-9999"
# Sort is a real <select>. Text on the page (checked on dev) -> value in the HTML.
SORT_OPTION_LABELS = ["Sort: Latest", "Sort: Oldest", "Sort: Title (A-Z)"]
SORT_OPTION_VALUES = {"Sort: Latest": "latest", "Sort: Oldest": "oldest", "Sort: Title (A-Z)": "title_asc"}
SORT_LABEL_LATEST = "Sort: Latest"

# ---- Filters ----
CLEAR_FILTERS_TEXT = "Clear filters"
FILTER_GROUP_TITLES = {"departments": "DEPARTMENTS", "job_types": "JOB TYPES", "location": "LOCATION"}
# Options come from the database, so they change. These are what the dev site showed on 2026-11-04.
# Figma options (Contract, Internship, Bangkok HQ, Chiang Mai ...) are not on dev: those cases SKIP.
FILTER_OPTIONS = {
    "departments": ["บริหาร (Management / Executive)", "Marketing / Digital / Content", "Tech / IT / Developer"],
    "job_types": ["Full-Time"],
    "location": ["Bangkok HQ", "Bangkok HQ (Pak Kret)"],
}

EMPTY_STATE_TEXT = "No open positions match your criteria"  # heading of the empty state
EMPTY_STATE_BUTTON_TEXT = "Clear all filters"  # button inside the empty state (not the same as the panel button)

JOB_DETAIL_URL_CONTAINS = "/jobs/"  # detail page is /jobs/<id>
