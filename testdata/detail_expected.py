"""Expected text for the Job Detail page. Checked against the dev site (https://career-web-dev.eventpass.biz).

Per-job values (title, type, department, vacancies, lists ...) come from testdata/jobs.json.
Values marked ASSUMPTION are the same on every job today; confirm them with the team.
"""
TODO = "TODO"

# The job every single-page test opens first: urgent, has a deadline, has all fields.
DEFAULT_DETAIL_JOB = "Tester AI"

TITLE_SUFFIX = " | EventPass Careers"
APPLY_PAGE_TITLE = "Apply \u2014 {title}" + TITLE_SUFFIX

# ---- Job not found ----
MISSING_JOB_ID = "000000000000000000000000"  # valid shape, no such job
BAD_JOB_ID = "not-a-real-id"
NOT_FOUND_TITLE = "Position not found" + TITLE_SUFFIX
NOT_FOUND_HEADING_TEXT = "This position is no longer open"
NOT_FOUND_BODY_TEXT = "The role may have been filled or closed. Take a look at our other open positions."
NOT_FOUND_BUTTON_TEXT = "See open positions"

# ---- Back link + breadcrumb ----
BACK_TO_JOBS_TEXT = "Back to Jobs"
BREADCRUMB_TEXTS = ["Careers", "Jobs", "Job Details"]

# ---- Header block ----
INFO_LABELS = {"department": "Department", "job_type": "Job Type", "work_location": "Work Location",
               "salary": "Salary", "vacancies": "Vacancies"}
WORK_LOCATION_TEXT = "Bangkok HQ (Pak Kret)"  # ASSUMPTION: same for every job on dev (the card shows a district instead)
SALARY_TEXT = "Based on company's structure"  # ASSUMPTION: fixed text on dev

# ---- Sections ----
SECTION_TITLES = ["Job Description", "Company Benefits", "Contact & Location"]
ABOUT_HEADING_TEXT = "\u0e40\u0e01\u0e35\u0e48\u0e22\u0e27\u0e01\u0e31\u0e1a\u0e07\u0e32\u0e19\u0e19\u0e35\u0e49"

# ---- Contact & Location ----
CONTACT_HEADING_TEXT = "\u0e15\u0e34\u0e14\u0e15\u0e48\u0e2d"
CONTACT_NAME_LINES = ["Human Resource Department", "\u0e1a\u0e23\u0e34\u0e29\u0e31\u0e17 \u0e2d\u0e35\u0e40\u0e27\u0e49\u0e19\u0e17\u0e4c\u0e44\u0e17\u0e22 \u0e08\u0e33\u0e01\u0e31\u0e14"]
CONTACT_ADDRESS_LINES = [
    "47/313 \u0e2d\u0e32\u0e04\u0e32\u0e23\u0e42\u0e04\u0e14\u0e31\u0e04 \u0e0a\u0e31\u0e49\u0e19 5 \u0e16\u0e19\u0e19\u0e1b\u0e4a\u0e2d\u0e1b\u0e1b\u0e39\u0e25\u0e48\u0e32",
    "\u0e15\u0e33\u0e1a\u0e25\u0e1a\u0e49\u0e32\u0e19\u0e43\u0e2b\u0e21\u0e48 \u0e2d\u0e33\u0e40\u0e20\u0e2d\u0e1b\u0e32\u0e01\u0e40\u0e01\u0e23\u0e47\u0e14 \u0e08\u0e31\u0e07\u0e2b\u0e27\u0e31\u0e14\u0e19\u0e19\u0e17\u0e1a\u0e38\u0e23\u0e35 11120",
]
CONTACT_PHONE_TEXT = "095-942-2201"
CONTACT_PHONE_HREF = "tel:+66959422201"
LOCATION_HEADING_TEXT = "\u0e2a\u0e16\u0e32\u0e19\u0e17\u0e35\u0e48\u0e1b\u0e0f\u0e34\u0e1a\u0e31\u0e15\u0e34\u0e07\u0e32\u0e19"
MAP_SRC_PREFIX = "https://maps.google.com/maps"

# ---- Side panel ----
APPLY_HEADING_TEXT = "Ready to apply?"
APPLY_BODY_TEXT = "Our hiring process is straightforward. Most people hear back within 7 business days."
APPLY_NOW_TEXT = "Apply Now"
SHARE_JOB_TEXT = "Share Job"
HIRING_HEADING_TEXT = "Our Hiring Process"
HIRING_STEPS_EXPECTED = [("01", "Application Review"), ("02", "HR Screening"),
                         ("03", "Personality Test / Assessment"), ("04", "Team Interviews"), ("05", "Job Offer")]

# ---- Apply form page (only what the detail page needs) ----
APPLY_PAGE_JOB_TEXT = "\u0e2a\u0e21\u0e31\u0e04\u0e23\u0e15\u0e33\u0e41\u0e2b\u0e19\u0e48\u0e07 {title}"
APPLY_PAGE_BACK_TEXT = "Back to job details"

# ---- JobPosting data for Google (JSON-LD) ----
EMPLOYMENT_TYPE = {"Full-Time": "FULL_TIME", "Part-Time": "PART_TIME", "Contract": "CONTRACTOR", "Internship": "INTERN"}
BAD_ORIGINS = ["localhost", "127.0.0.1"]
THAILAND_UTC_HOURS = 7  # validThrough is stored in UTC; the page shows Thai dates
