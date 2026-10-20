"""Locators for the Career - Jobs page. EVERY value starts as "TODO".

Fill them in here, in this one file, when dev ships the page. No test changes needed.

Rules
  * Use SeleniumLibrary strings: "id=...", "css:...", "xpath=...".
  * Templates hold {label} or {group}; they are filled by `Format Locator`.
  * JOB_CARD and everything inside CARD must be XPATH. CARD children are RELATIVE,
    e.g. "xpath=.//*[@data-testid='card-title']".
  * Ask dev for a stable data-testid on each item (suggested names in comments).
    Prefer data-testid over CSS classes or text: it survives design changes.
"""
TODO = "TODO"

# ---------------- Header ----------------
LOGO = TODO  # data-testid="logo"
NAV = {"careers": TODO, "culture": TODO, "why_join_us": TODO, "jobs": TODO}  # "nav-careers" ...
BTN_EVENTTHAI = TODO  # "btn-eventthai"
LANG_SWITCH = {"EN": TODO, "TH": TODO}  # "lang-en", "lang-th"

# ---------------- Hero / search / sort ----------------
HERO_TITLE = TODO  # "hero-title"
HERO_SUBTITLE = TODO  # "hero-subtitle"
SEARCH_INPUT = TODO  # "search-input"
SORT_DROPDOWN = TODO  # "sort-dropdown"
SORT_OPTION = TODO  # template {label}, "sort-option-{label}"
LOADING_INDICATOR = TODO  # optional spinner; if set, tests wait for it to vanish

# ---------------- Filters ----------------
FILTER_PANEL = TODO  # "filter-panel"
BTN_CLEAR_FILTERS = TODO  # "btn-clear-filters"
FILTER_GROUP = {"departments": TODO, "job_types": TODO, "location": TODO}  # group title
FILTER_GROUP_TOGGLE = {"departments": TODO, "job_types": TODO, "location": TODO}  # the chevron
FILTER_GROUP_LIST = {"departments": TODO, "job_types": TODO, "location": TODO}  # the options box
FILTER_OPTION = TODO  # template {group} {label}: the checkbox, "filter-{group}-{label}"
SELECTED_FILTER_TAG_ANY = TODO  # every selected-filter tag
SELECTED_FILTER_TAG = TODO  # template {label}
SELECTED_FILTER_TAG_REMOVE = TODO  # template {label}: the "x" button
RESULT_COUNT = TODO  # "result-count" ("7 positions found.")
EMPTY_STATE = TODO  # "empty-state"

# ---------------- Job cards ----------------
JOB_CARD = TODO  # xpath of ALL cards, e.g. "xpath=//*[@data-testid='job-card']"
CARD = {  # relative xpath inside one card
    "title": TODO,
    "description": TODO,
    "type_badge": TODO,
    "urgent_badge": TODO,
    "deadline": TODO,
    "ongoing": TODO,
    "department": TODO,
    "location": TODO,
    "work_mode": TODO,
    "posted": TODO,
    "view_apply": TODO,
}
DETAIL_TITLE = TODO  # job title on the detail page

# ---------------- Footer ----------------
FOOTER = TODO
FOOTER_SECTION = {"recruitment": TODO, "contact_hr": TODO, "company": TODO}  # section headings
FOOTER_COMPANY_INFO = TODO
FOOTER_LINK = {
    "open_positions": TODO,
    "culture": TODO,
    "recruitment_process": TODO,
    "faq": TODO,
    "go_to_website": TODO,
    "cookies": TODO,
    "terms": TODO,
    "privacy": TODO,
}
FOOTER_EMAIL_LINK = TODO
FOOTER_PHONE_LINK = TODO
FOOTER_COPYRIGHT_TEXT = TODO
