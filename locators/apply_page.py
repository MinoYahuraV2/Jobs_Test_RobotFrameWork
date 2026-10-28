"""Locators for the Apply Job form (https://career-web-dev.eventpass.biz/jobs/<job id>/apply), measured on the dev site.

Same rules as the other locator files: the page has no data-testid, so these use ids, aria-labels,
visible text and page structure (never CSS classes). Templates hold {id} / {name} / {text}.
"""

# ---------------- Top of the page ----------------
APPLY_H1 = "xpath://main//h1"
APPLY_JOB_LINE = ("xpath://main//*[contains(normalize-space(),'\u0e2a\u0e21\u0e31\u0e04\u0e23\u0e15\u0e33\u0e41\u0e2b\u0e19\u0e48\u0e07') "
                  "and not(*[contains(normalize-space(),'\u0e2a\u0e21\u0e31\u0e04\u0e23\u0e15\u0e33\u0e41\u0e2b\u0e19\u0e48\u0e07')])]")
CANCEL_LINK = "xpath://main//a[normalize-space()='Cancel']"
REVIEW_BUTTON = "xpath://main//button[normalize-space()='Review Application']"
BREADCRUMB_ITEMS = "xpath://nav[@aria-label='Breadcrumb']//ol/li[not(@aria-hidden='true')]"

# ---------------- Section titles ----------------
SECTION_TITLES_LOC = {
    "personal": "id:personal-info-section-title",
    "resume": "id:resume-portfolio-section-title",
    "source": "id:recruitment-source-section-title",
}

# ---------------- Personal information ----------------
FIELD = {
    "first_name": "id:firstName",
    "last_name": "id:lastName",
    "email": "id:email",
    "phone": "id:phone",
    "salary": "id:expectedSalary",
}
FIELD_LABEL = "xpath://main//input[@id='{id}']/preceding::label[1]"
PHONE_PREFIX = "xpath://main//*[normalize-space()='(+66)']"

# Text of a message (error or hint) anywhere in the form
TEXT_ANYWHERE = 'xpath://main//*[normalize-space()="{text}"]'

# ---------------- Resume and documents ----------------
RESUME_INPUT = "id:resume-input"
ADDITIONAL_INPUT = "id:additional-input"
RESUME_DROPZONE = "xpath://main//label[.//input[@id='resume-input']]"
ADDITIONAL_DROPZONE = "xpath://main//label[.//input[@id='additional-input']]"
REMOVE_FILE = "xpath://main//button[@aria-label='Remove {name}']"
FILE_NAME = 'xpath://main//*[normalize-space()="{name}"]'
PORTFOLIO_INPUT = "id:portfolioUrl"
PORTFOLIO_LABEL = "xpath://main//label[contains(normalize-space(),'Portfolio URL')]"
CLEAR_LINK = "xpath://main//button[normalize-space()='Clear link']"

# ---------------- Recruitment source ----------------
SOURCE_LABEL = "xpath://main//label[normalize-space()='{name}']"
SOURCE_CHECKBOX = "xpath://main//label[normalize-space()='{name}']//input[@type='checkbox']"
SOURCE_QUESTION = "xpath://main//*[contains(normalize-space(),'How did you find this opportunity?')]"
OTHER_INPUT = "id:otherRecruitmentChannel"

# ---------------- Privacy ----------------
PRIVACY_LABEL = "xpath://main//label[contains(normalize-space(),'I agree to the collection')]"
PRIVACY_CHECKBOX = "xpath://main//label[contains(normalize-space(),'I agree to the collection')]//input[@type='checkbox']"

# ---------------- Side panel ----------------
PROGRESS = "xpath://main//*[@role='progressbar']"
SIDE_TITLE = "xpath://main//h2[normalize-space()='Complete Your Profile']"
SIDE_ITEM = "xpath://main//button[starts-with(normalize-space(),'{name}')]"
EXPECT_TITLE = "xpath://main//h2[normalize-space()='What to expect']"
EXPECT_BLOCK = "xpath://main//h2[normalize-space()='What to expect']/parent::*"

# ---------------- Review dialog ----------------
MODAL_TITLE = "id:review-modal-title"
MODAL_BODY = ("xpath://*[@id='review-modal-title']/ancestor::div"
              "[.//button[normalize-space()='Confirm & Submit Application']][1]")
MODAL_BACK = "xpath://button[normalize-space()='Back to Edit']"
MODAL_CLOSE = "xpath://button[@aria-label='Close']"
MODAL_CONFIRM = "xpath://button[normalize-space()='Confirm & Submit Application']"
