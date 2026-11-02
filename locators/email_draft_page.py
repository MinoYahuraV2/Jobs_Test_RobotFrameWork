"""Locators of the CMS email draft page: /admin/applications/<id>/email?type=head.

All of these were checked on the dev site. The form fields and the info panel have ids; the rest
uses visible text and structure (there is no data-testid).
"""

ED_CONTENT = "id:cms-content"
ED_H1 = "css:#cms-content h1"
ED_SUBTITLE = "css:#cms-content h1 + p"
ED_BACK_LINK = "xpath://*[@id='cms-content']//a[contains(normalize-space(), 'กลับไปหน้าโปรไฟล์ผู้สมัคร')]"
ED_CANCEL = "xpath://*[@id='cms-content']//a[contains(normalize-space(), 'ยกเลิก')]"
ED_FORM = "id:emailDraftForm"
ED_SEND_TOP = "xpath:(//*[@id='cms-content']//button[@type='submit' and @form='emailDraftForm'])[1]"
ED_SEND_SIDE = "xpath:(//*[@id='cms-content']//button[@type='submit' and @form='emailDraftForm'])[2]"
ED_SEND_BUTTONS = "css:#cms-content button[type='submit']"

# Form
ED_FORM_SECTION = "xpath://form[@id='emailDraftForm']//section[.//h2[normalize-space()='รายละเอียดร่างอีเมล']]"
ED_TO = "id:emailDraftTo"
ED_CC = "id:emailDraftCc"
ED_SUBJECT = "id:emailDraftSubject"
ED_BODY = "id:emailDraftBody"
ED_LABELS = "css:#cms-content form label"
ED_BANNER = "css:#cms-content [role='alert']"

# Attachments
ED_ATTACH_SECTION = "xpath://*[@id='cms-content']//h3[normalize-space()='ไฟล์แนบจากใบสมัคร']/ancestor::section[1]"
ED_VIEW_PDF = "xpath:(//*[@id='cms-content']//button[normalize-space()='View PDF'])[1]"
ED_DIALOG = "css:dialog[open]"
ED_DIALOG_FRAME = "css:dialog[open] iframe"
ED_DIALOG_CLOSE = "css:dialog[open] button[aria-label='ปิดหน้าต่าง Preview']"

# Info panel and status after sending
ED_ASIDE = "css:#cms-content aside"
ED_INFO_TYPE = "id:emailDraftRecipientType"
ED_INFO_NAME = "id:emailDraftApplicantName"
ED_INFO_JOB = "id:emailDraftApplicantJob"
ED_INFO_EMAIL = "id:emailDraftApplicantEmail"
ED_INFO_CV = "id:emailDraftCvName"
ED_AUTO_UPDATE = "id:emailAutoUpdateStatus"
ED_STATUS_AFTER = "id:emailDraftStatusAfterSend"
ED_HIDDEN_UPDATE = "css:input[name='updateStatus']"
ED_HIDDEN_TARGET = "css:input[name='targetStatus']"
