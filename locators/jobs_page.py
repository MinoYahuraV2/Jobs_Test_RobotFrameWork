"""Locators for the Career - Jobs page, measured on the dev site (https://career-web-dev.eventpass.biz/jobs).

The page has no data-testid, so these use ids, aria-labels, visible text and page structure (not CSS classes).`nA value of "TODO" means: not found on the dev site yet - the test is SKIPPED.

Rules
  * Use SeleniumLibrary strings: "id=...", "css:...", "xpath=...".
  * Templates hold {label} or {group}; they are filled by `Format Locator`.
  * JOB_CARD and everything inside CARD must be XPATH. CARD children are RELATIVE,
    e.g. "xpath=.//*[@data-testid='card-title']".
  * Ask dev for a stable data-testid on each item (suggested names in comments).
    Prefer data-testid over CSS classes or text: it survives design changes.
"""
TODO = "TODO"

# ---------------- Hero / search / sort ----------------
HERO_TITLE = "xpath://h1[contains(normalize-space(), 'Find your')]"  # no id/class on the page, so xpath
HERO_SUBTITLE = "xpath://div[2]/div/p"  # "7 open positions across our teams..." (position-based: may break if layout changes)
SEARCH_INPUT = "id:jobs-search-input-desktop"  # the page also has jobs-search-input-mobile (hidden on desktop)
SORT_DROPDOWN = "xpath://select[@id='jobs-sort-select']"  # a real <select>: choose with Select From List, not Click
LOADING_INDICATOR = TODO  # optional spinner; if set, tests wait for it to vanish

# ---------------- Filters ----------------
# Group keys: departments / job_types / location. Titles on the page: "Departments", "Job types", "Location".
# {group} is turned into the title by lower-casing it and swapping spaces for "_".
_GROUP_BTN = "//aside//button[translate(normalize-space(.),'ABCDEFGHIJKLMNOPQRSTUVWXYZ ','abcdefghijklmnopqrstuvwxyz_')='{key}']"
FILTER_PANEL = "xpath://aside[@aria-label='Filters']"
BTN_CLEAR_FILTERS = "xpath://aside//button[normalize-space()='Clear filters']"  # shown ONLY after a filter is selected
FILTER_GROUP = {k: "xpath:" + _GROUP_BTN.format(key=k) + "/span" for k in ("departments", "job_types", "location")}
FILTER_GROUP_TOGGLE = {k: "xpath:" + _GROUP_BTN.format(key=k) for k in ("departments", "job_types", "location")}
FILTER_GROUP_LIST = {k: "xpath:" + _GROUP_BTN.format(key=k) + "/following-sibling::div" for k in ("departments", "job_types", "location")}
# the checkbox <input> (visually hidden by the page); template {group} {label}
FILTER_OPTION = ("xpath://aside//button[translate(normalize-space(.),'ABCDEFGHIJKLMNOPQRSTUVWXYZ ','abcdefghijklmnopqrstuvwxyz_')='{group}']"
                 "/following-sibling::div//label[normalize-space()='{label}']/input")
SELECTED_FILTER_TAG_ANY = "xpath://span[normalize-space()='Filter jobs:']/following-sibling::span"
SELECTED_FILTER_TAG = "xpath://span[normalize-space()='Filter jobs:']/following-sibling::span[normalize-space()='{label}']"
SELECTED_FILTER_TAG_REMOVE = "xpath://button[@aria-label='Remove filter {label}']"
RESULT_COUNT = "xpath://p[contains(normalize-space(),'found.')]"  # "7 positions found."
EMPTY_STATE = "xpath://h3[normalize-space()='No open positions match your criteria']"

# ---------------- Job cards ----------------
JOB_CARD = "xpath://main//article"
CARD = {  # relative xpath inside one card: article > div(badges) h3 p div(details) div(footer)
    "title": "xpath:.//h3/a",
    "description": "xpath:./p",
    "type_badge": "xpath:./div[1]/span[1]",
    "urgent_badge": "xpath:.//span[normalize-space()='Urgent']",
    "deadline": "xpath:.//span[contains(normalize-space(),'Due')]",
    "ongoing": "xpath:.//span[contains(normalize-space(),'Ongoing')]",  # NOT seen on dev yet (guess)
    "department": "xpath:./div[2]/div[1]/span",
    "location": "xpath:./div[2]/div[2]/span",
    "work_mode": TODO,  # dev data has workMode = null for every job, so nothing to look at yet
    "posted": "xpath:./div[3]/span[1]",  # empty on dev: postedDate = null for every job
    "view_apply": "xpath:.//a[normalize-space()='View & Apply']",
}
DETAIL_TITLE = "xpath://main//article//h1"  # job title on the detail page

# ---------------- Footer ----------------
# The dev footer is in Thai and has fewer links than Figma. TODO = not on the dev site.
FOOTER = "xpath://footer"
FOOTER_SECTION = {"recruitment": "xpath:(//footer//h2)[1]", "contact_hr": "xpath:(//footer//h2)[2]", "company": "xpath:(//footer//h2)[3]"}
FOOTER_COMPANY_INFO = "xpath://footer//address"
FOOTER_LINK = {
    "open_positions": "xpath://footer//a[@href='/jobs']",
    "culture": TODO,  # not on dev footer
    "recruitment_process": TODO,  # not on dev footer
    "faq": TODO,  # not on dev footer
    "go_to_website": "xpath://footer//a[starts-with(@href,'https://www.eventthai.com')]",
    "cookies": TODO,  # on dev this is plain text, not a link
    "terms": TODO,  # on dev this is plain text, not a link
    "privacy": TODO,  # on dev this is plain text, not a link
}
FOOTER_EMAIL_LINK = "xpath://footer//a[starts-with(@href,'mailto:')]"
FOOTER_PHONE_LINK = "xpath://footer//a[starts-with(@href,'tel:')]"
FOOTER_COPYRIGHT_TEXT = "xpath://footer//p[contains(normalize-space(),'All Rights Reserved')]"