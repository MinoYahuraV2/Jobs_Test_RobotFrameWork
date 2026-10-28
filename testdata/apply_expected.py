"""Expected text and test data for the Apply Job form, measured on the dev site (2026-10-28).

Where the dev site and the Figma design disagree, the value here follows the DEV site and the
case carries the tag `assumption`. The differences are listed in NOTES.md.
"""

# ---- Data typed into the form. Fake person; never submitted. ----
APPLICANT = {
    "first_name": "สมชาย",
    "last_name": "ใจดี",
    "email": "somchai.test@example.com",
    "phone": "0812345678",
    "salary": "30000",
}
SALARY_SHOWN = "30,000"
PHONE_IN_REVIEW = "(+66) 812345678"
PORTFOLIO_URL_OK = "https://example.com"
PORTFOLIO_IN_REVIEW = "example.com"

# ---- Page texts ----
FORM_H1_TEXT = "แบบฟอร์มสมัครงาน"           # Figma: Job Application Form
SECTION_TITLES_TEXT = {
    "personal": "ข้อมูลผู้สมัคร",             # Figma: Personal Information
    "resume": "Resume & Portfolio",
    "source": "Recruitment Source",
}
BREADCRUMB_TEXTS = ["Careers", "Jobs", "Job Details", "Apply Job"]
BACK_TEXT = "Back to job details"

# ---- Personal information ----
FIELD_LABELS = {                            # Figma: First name * / Last name * / Email address * ...
    "first_name": "ชื่อภาษาไทย *",
    "last_name": "นามสกุลภาษาไทย *",
    "email": "อีเมล *",
    "phone": "เบอร์โทรศัพท์ *",
    "salary": "เงินเดือนที่คาดหวัง (THB) *",
}
FIELD_PLACEHOLDERS = {                      # Figma: Enter your firstname / ... / 08X-XXX-XXXX
    "first_name": "เช่น อารยา",
    "last_name": "เช่น สมิทธิ์",
    "email": "john@example.com",
    "phone": "081-234-5678",
    "salary": "เช่น 30,000",
}
ERR_FIRST_NAME = "First name is required."
ERR_LAST_NAME = "Last name is required."
ERR_EMAIL = "Enter a valid email address."
ERR_PHONE = "Enter a valid phone number."
ERR_SALARY = "Enter your expected salary in THB."
PERSONAL_ERRORS = [ERR_FIRST_NAME, ERR_LAST_NAME, ERR_EMAIL, ERR_PHONE, ERR_SALARY]

# ---- Resume and documents ----
DROP_TEXT = "Drop your files here or browse"
RESUME_HINT = "Supports only PDF, DOC, DOCX (Maximum size: 5MB)"
ADDITIONAL_HINT = "Supports ZIP, RAR, PDF, JPG, PNG (Attach more than one file, up to 10MB each)"
RESUME_ACCEPT = ".pdf,.doc,.docx"
ADDITIONAL_ACCEPT = ".zip,.rar,.pdf,.jpg,.jpeg,.png"
ERR_RESUME_MISSING = "Please upload your Resume / CV."
ERR_FILE_TYPE = "cv.txt: file type not supported."
ERR_FILE_BIG = "big.pdf is larger than 5 MB."
PORTFOLIO_LABEL_TEXT = "Portfolio URL (Optional)"
PORTFOLIO_PLACEHOLDER = "https://"
ERR_PORTFOLIO = "Enter a full URL (https://…)."

# ---- Recruitment source ----
SOURCE_GROUPS = {                           # Figma: X / Company Website / Other
    "Social Media": ["Facebook", "TikTok", "Instagram", "X (Twitter)"],
    "Website / Job Platform": ["JobsDB", "JobThai", "Jobtopgun", "LinkedIn", "Fastwork"],
    "Direct Channel / Other": ["เว็บไซต์ของบริษัท", "อื่น ๆ"],
}
SOURCE_OTHER = "อื่น ๆ"
OTHER_PLACEHOLDER = "e.g. Friend recommendation, job fair…"
ERR_SOURCE = "Please select at least one option."
ERR_OTHER = "Please tell us where you heard about us."

# ---- Privacy ----
PRIVACY_TEXT = ("I agree to the collection and processing of my personal data and application "
                "documents for recruitment and evaluation purposes.")
ERR_PRIVACY = "Please agree to the privacy terms to continue."

# ---- Side panel ----
SIDE_ITEMS = {
    "Personal information": "Name & contact details",
    "Resume & Portfolio": "Upload your documents",
    "Recruitment Source": "How you found this job",
    "Privacy Consent": "Terms & data protection",
}
EXPECT_LINES = [
    "Response within 5 business days",
    "No ghosting — we close every loop",
    "Salary shared early in the process",
    "2–3 interview rounds total",
]

# ---- Review dialog ----
REVIEW_TITLE_TEXT = "Review Application"
REVIEW_JOB_LINE = "Apply for: {title} ({job_type})"
UNKNOWN_JOB_ID = "000000000000000000000000"

# ---- Footer (same as the Jobs page) ----
FOOTER_EMAIL = "job@eventthai.com"
FOOTER_PHONE = "095 942 2201"
