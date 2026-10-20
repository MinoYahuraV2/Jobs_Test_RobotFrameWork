"""Expected TEXT and link targets. Known values come from the Figma design.
"TODO" = not known yet. Tests that need a TODO value are SKIPPED, not failed.
"""
TODO = "TODO"

# ---- Header ----
NAV_LABELS = {"careers": "Careers", "culture": "Culture", "why_join_us": "Why Join Us", "jobs": "Jobs"}
BTN_EVENTTHAI_TEXT = "Eventthai.com"

# ---- Hero / search / sort ----
HERO_TITLE_TEXT = "Find your next role."
HERO_TITLE_BY_LANG = {"EN": "Find your next role.", "TH": TODO}  # TODO: Thai text from dev
SEARCH_PLACEHOLDER = "Search by job title or keywords..."
SEARCH_NO_MATCH_TEXT = "zzzz-no-such-job-9999"
SORT_OPTION_LABELS = [TODO]  # TODO: all options. Figma shows only the current one, spelled "Lastest" (typo?)
SORT_LABEL_LATEST = TODO  # TODO: exact label of the Latest option

# ---- Filters (from Figma) ----
CLEAR_FILTERS_TEXT = "Clear filters"
FILTER_GROUP_TITLES = {"departments": "DEPARTMENTS", "job_types": "JOB TYPES", "location": "LOCATION"}
FILTER_OPTIONS = {
    "departments": [
        "Management / Executive",
        "Project / Operation",
        "Marketing / Digital / Content",
        "Design / Creative",
        "Tech / IT / Developer",
        "Sales / Business Development",
        "Customer Support / Service",
        "Admin / Support / HR",
        "QA / Technical Support",
        "Production / Creative Media",
    ],
    "job_types": ["Full-Time", "Part-Time", "Contract", "Internship"],
    "location": ["Bangkok HQ", "Chiang Mai"],
}
EMPTY_STATE_TEXT = TODO  # TODO: message when no job matches

# ---- Footer (from Figma) ----
FOOTER_HEADINGS = {"recruitment": "RECRUITMENT", "contact_hr": "CONTACT HR", "company": "COMPANY"}
FOOTER_COMPANY_NAME = "Eventthai Co., Ltd."
FOOTER_LINK_TEXT = {
    "open_positions": "Open Positions",
    "culture": "Culture",
    "recruitment_process": "Recruitment Process",
    "faq": "FAQ",
    "go_to_website": "Go to Website",
    "cookies": "Cookies Policy",
    "terms": "Term and Conditions",
    "privacy": "Privacy Policy",
}
FOOTER_EMAIL = "job@eventthai.com"
FOOTER_PHONE = "095 942 2201"
FOOTER_COPYRIGHT = "© 2026 Eventthai. All Rights Reserved."  # year per Figma; confirm if it must follow the current year

# ---- Where each link must go (part of the URL). All TODO until dev confirms. ----
LINKS = {
    "careers": TODO,
    "culture": TODO,
    "why_join_us": TODO,
    "jobs": TODO,
    "eventthai": "eventthai.com",
    "open_positions": TODO,
    "recruitment_process": TODO,
    "faq": TODO,
    "go_to_website": TODO,
    "cookies": TODO,
    "terms": TODO,
    "privacy": TODO,
}
JOB_DETAIL_URL_CONTAINS = TODO  # TODO: e.g. "/jobs/" once the detail URL pattern is known
