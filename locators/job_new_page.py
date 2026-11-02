"""Locators of the CMS new job form: /admin/jobs/new.

All of these were checked on the dev site. The form fields have ids (job...Input / job...Editor); the
rest uses visible text and structure (there is no data-testid).
"""

JN_CONTENT = "id:cms-content"
JN_BACK_LINK = "xpath:(//*[@id='cms-content']//a[@href='/admin/jobs'])[1]"
JN_CANCEL = "xpath://*[@id='cms-content']//a[contains(normalize-space(), 'ยกเลิก / กลับหน้ารายการ')]"
JN_BADGE = "xpath://*[@id='cms-content']//h1/preceding-sibling::div[1]"
JN_H1 = "css:#cms-content h1"
JN_SUBTITLE = "css:#cms-content h1 + p"
JN_FORM = "id:jobManagementForm"
JN_SAVE = "xpath://button[normalize-space()='บันทึกตำแหน่งงาน']"
JN_ASIDE = "css:#cms-content aside"

# Fields
JN_TITLE = "id:jobTitleInput"
JN_ABOUT = "id:jobAboutEditor"
JN_RESPONSIBILITIES = "id:jobResponsibilitiesEditor"
JN_QUALIFICATIONS = "id:jobQualificationsEditor"
JN_LOCATION_TEXT = "id:jobLocationTextInput"
JN_LAT = "id:jobLocationLatInput"
JN_LNG = "id:jobLocationLngInput"
JN_MAPS_LINK = "xpath://*[@id='cms-content']//a[contains(@href, 'google.com/maps')]"
JN_DEADLINE = "id:jobDeadlineInput"
JN_DEPT = "id:jobDeptInput"
JN_TYPE = "id:jobEmploymentTypeInput"
JN_TAB = "id:jobTabTypeInput"
JN_WORK_LOCATION = "id:jobWorkLocationInput"
JN_VACANCIES = "id:jobVacanciesInput"
JN_HOT = "id:jobHotInput"
JN_BENEFITS = "css:#jobManagementForm input[name='benefits']"

# Publishing status
JN_PREVIEW = "id:jobStatusPreview"
JN_MANUAL = "id:jobManualOpenToggle"
JN_HIDDEN_MANUAL = "css:#jobManagementForm input[name='manualOpen']"
JN_HIDDEN_HOT = "css:#jobManagementForm input[name='isHot']"

# Editors: (editor id, name of the hidden plain text field, block id)
JN_EDITORS = [("jobAboutEditor", "about", "jobAboutEditorBlock"),
              ("jobResponsibilitiesEditor", "responsibilities", "jobResponsibilitiesEditorBlock"),
              ("jobQualificationsEditor", "qualifications", "jobQualificationsEditorBlock")]
JN_EDITORS_FLAT = [item for row in JN_EDITORS for item in row]
