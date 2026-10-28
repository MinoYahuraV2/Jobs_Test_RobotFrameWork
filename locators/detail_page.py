"""Locators for the Job Detail page (https://career-web-dev.eventpass.biz/jobs/<job id>), measured on the dev site.

Same rules as locators/jobs_page.py: no data-testid on the page, so these use ids, aria-labels,
visible text and page structure (never CSS classes). Templates hold {label} / {title}.
"""
TODO = "TODO"

# ---------------- Back link + breadcrumb ----------------
BREADCRUMB = "xpath://nav[@aria-label='Breadcrumb']"
BACK_TO_JOBS = "xpath://nav[@aria-label='Breadcrumb']/a[contains(normalize-space(),'Back to Jobs')]"
BREADCRUMB_ITEMS = "xpath://nav[@aria-label='Breadcrumb']//ol/li[not(@aria-hidden='true')]"
BREADCRUMB_CAREERS = "xpath://nav[@aria-label='Breadcrumb']//ol//a[normalize-space()='Careers']"
BREADCRUMB_JOBS = "xpath://nav[@aria-label='Breadcrumb']//ol//a[normalize-space()='Jobs']"
BREADCRUMB_CURRENT = "xpath://nav[@aria-label='Breadcrumb']//li[@aria-current='page']"
BREADCRUMB_CURRENT_LINK = "xpath://nav[@aria-label='Breadcrumb']//li[@aria-current='page']//a"

# ---------------- Header block of the job ----------------
DETAIL_ARTICLE = "xpath://main//article"
DETAIL_H1 = "xpath://main//article/header//h1"
DETAIL_TYPE_BADGE = "xpath://main//article/header/div[1]/span[1]"
DETAIL_URGENT = "xpath://main//article/header//span[normalize-space()='Urgent']"
DETAIL_DEADLINE = "xpath://main//article/header//span[contains(normalize-space(),'Due')]"
# <dt>Department</dt><dd>Tech / IT / Developer</dd> ... Work Location, Salary, Vacancies
DETAIL_INFO_LABEL = "xpath://main//article/header//dt[contains(normalize-space(),'{label}')]"
DETAIL_INFO_VALUE = "xpath://main//article/header//dt[contains(normalize-space(),'{label}')]/following-sibling::dd[1]"

# ---------------- Sections that open and close (accordion) ----------------
SECTION_BUTTON = "xpath://main//article//h2/button[normalize-space()=\"{title}\"]"
SECTION_PANEL = "xpath://main//article//h2[button[normalize-space()=\"{title}\"]]/following-sibling::div[1]"

# ---------------- Job Description section ----------------
ABOUT_HEADING = "xpath://main//article//h3[normalize-space()='เกี่ยวกับงานนี้']"
ABOUT_TEXT = "xpath://main//article//h3[normalize-space()='เกี่ยวกับงานนี้']/following-sibling::div//p"
RESPONSIBILITIES_HEADING = "xpath://main//article//h3[starts-with(normalize-space(),'ความรับผิดชอบ')]"
RESPONSIBILITIES_ITEMS = "xpath://main//article//h3[starts-with(normalize-space(),'ความรับผิดชอบ')]/following-sibling::div//li"
QUALIFICATIONS_HEADING = "xpath://main//article//h3[starts-with(normalize-space(),'คุณสมบัติ')]"
QUALIFICATIONS_ITEMS = "xpath://main//article//h3[starts-with(normalize-space(),'คุณสมบัติ')]/following-sibling::div//li"

# ---------------- Company Benefits section ----------------
BENEFITS_ITEMS = "xpath://main//article//h2[button[normalize-space()='Company Benefits']]/following-sibling::div[1]//li"

# ---------------- Contact & Location section ----------------
CONTACT_HEADING = "xpath://main//article//h3[normalize-space()='ติดต่อ']"
CONTACT_ADDRESS = "xpath://main//article//address"
CONTACT_PHONE_LINK = "xpath://main//article//address//a[starts-with(@href,'tel:')]"
LOCATION_HEADING = "xpath://main//article//h3[normalize-space()='สถานที่ปฏิบัติงาน']"
LOCATION_TEXT = "xpath://main//article//h3[normalize-space()='สถานที่ปฏิบัติงาน']/following-sibling::div//p"
MAP_FRAME = "xpath://main//article//iframe"

# ---------------- Side panel (apply, share, hiring process) ----------------
ASIDE = "xpath://main//aside"
APPLY_HEADING = "xpath://main//aside//h2[normalize-space()='Ready to apply?']"
APPLY_TEXT = "xpath://main//aside//h2[normalize-space()='Ready to apply?']/following-sibling::p[1]"
APPLY_NOW = "xpath://main//aside//a[normalize-space()='Apply Now']"
SHARE_JOB = "xpath://main//aside//button[contains(normalize-space(),'Share Job')]"
HIRING_HEADING = "xpath://main//aside//h2[normalize-space()='Our Hiring Process']"
HIRING_STEPS = "xpath://main//aside//h2[normalize-space()='Our Hiring Process']/following-sibling::ol/li"
HIRING_STEP_NUMBERS = "xpath://main//aside//h2[normalize-space()='Our Hiring Process']/following-sibling::ol/li/span"

# ---------------- Job not found page ----------------
NOT_FOUND_HEADING = "xpath://main//h1[normalize-space()='This position is no longer open']"
NOT_FOUND_TEXT = "xpath://main//p[contains(normalize-space(),'The role may have been filled or closed')]"
NOT_FOUND_BUTTON = "xpath://main//a[normalize-space()='See open positions']"

# ---------------- Apply form page (/jobs/<id>/apply): only what this page links to ----------------
APPLY_PAGE_HEADING = "xpath://main//h1"
APPLY_PAGE_BACK = "xpath://main//a[normalize-space()='Back to job details']"
