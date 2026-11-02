"""Locators of the CMS applicant profile: /admin/applications/<id>.

All of these were checked on the dev site. The page has ids on the five section headings, the
status form and the status list. The rest uses visible text and structure (there is no data-testid).
"""

# Top of the page
PF_CONTENT = "id:cms-content"
PF_H1 = "css:#cms-content h1"
PF_SUBTITLE = "css:#cms-content header p"
PF_BACK_LINK = "xpath://*[@id='cms-content']//header//a[contains(normalize-space(), 'กลับไปหน้าจัดการผู้สมัคร')]"
PF_LIST_BUTTON = "xpath://*[@id='cms-content']//header//a[normalize-space()='รายการผู้สมัคร']"
PF_TOP_SAVE = "xpath://*[@id='cms-content']//header//button[@form='applicant-status-form']"

# Section headings (they have ids)
PF_INFO_HEADING = "id:applicant-info-heading"
PF_HISTORY_HEADING = "id:applicant-history-heading"
PF_FILES_HEADING = "id:applicant-files-heading"
PF_LOG_HEADING = "id:email-history-heading"
PF_STATUS_HEADING = "xpath://*[@id='cms-content']//aside//h2"

# Application info
PF_INFO_SECTION = "xpath://section[@aria-labelledby='applicant-info-heading']"
PF_INFO_LABELS = "css:section[aria-labelledby='applicant-info-heading'] label"

# History
PF_HISTORY_SECTION = "xpath://section[@aria-labelledby='applicant-history-heading']"
PF_SAME_NAME_LINK = "xpath://*[@id='cms-content']//a[normalize-space()='ค้นหาชื่อเดียวกันเพิ่มเติม']"

# Files
PF_FILES_SECTION = "xpath://section[@aria-labelledby='applicant-files-heading']"
PF_VIEW_PDF = "xpath:(//*[@id='cms-content']//button[normalize-space()='View PDF'])[1]"
PF_DIALOG = "css:dialog[open]"
PF_DIALOG_TITLE = "id:pdf-preview-title"
PF_DIALOG_FRAME = "css:dialog[open] iframe"
PF_DIALOG_DOWNLOAD = "xpath://dialog[@open]//a[normalize-space()='ดาวน์โหลด']"
PF_DIALOG_CLOSE = "css:dialog[open] button[aria-label='ปิดหน้าต่าง Preview']"

# Email log
PF_LOG_SECTION = "xpath://section[@aria-labelledby='email-history-heading']"
PF_LOG_HEADINGS = "css:section[aria-labelledby='email-history-heading'] thead th"

# Status panel (right column)
PF_STATUS_FORM = "id:applicant-status-form"
PF_STATUS_SELECT = "id:profileHrStatus"
PF_STATUS_LABEL = "css:label[for='profileHrStatus']"
PF_PANEL_SAVE = "xpath://form[@id='applicant-status-form']//button[@type='submit']"
PF_ASIDE = "css:#cms-content aside"
PF_HEAD_EMAIL = "xpath://form[@id='applicant-status-form']//a[contains(@href, '/email?type=head')]"
PF_CANDIDATE_EMAIL = "xpath://form[@id='applicant-status-form']//a[contains(@href, '/email?type=candidate')]"

# Email draft page (only opened, nothing is sent)
PF_DRAFT_BACK = "xpath://*[@id='cms-content']//a[contains(normalize-space(), 'กลับไปหน้าโปรไฟล์ผู้สมัคร')]"
PF_DRAFT_TO = "css:#cms-content input[name='to']"
PF_DRAFT_SUBJECT = "css:#cms-content input[name='subject']"

# Not found page
PF_NOT_FOUND_BACK = "xpath://*[@id='cms-content']//a[contains(normalize-space(), 'กลับไปหน้ารายการผู้สมัคร')]"
