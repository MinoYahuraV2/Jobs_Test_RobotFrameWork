*** Settings ***
Documentation     CMS edit job keywords: /admin/jobs/<id>.
...               The page is the same form as /admin/jobs/new, filled with the saved job. Built on job_new.resource
...               (same safety rule) and jobs_admin.resource (the job list).
...               THE TESTS NEVER SAVE A JOB. They open the edit pages, change boxes on the page only, and leave without saving.
...               The only press of the save button is made with the title emptied, which the browser refuses, and
...               Block The Form From Sending stops anything that would still go out. Real saving is a manual case.
Resource          job_new.resource
Resource          jobs_admin.resource
Library           ../../libraries/JobEditData.py
Variables         ../../testdata/job_edit_expected.py


*** Keywords ***
# ================= open / reset =================
Open Edit Browser
    Open Admin Browser
    Login As Admin And Reach Dashboard
    Go To Jobs Admin
    ${rows}=    Get Job Rows
    Should Not Be Empty    ${rows}    The job list is empty, so there is nothing to edit
    ${paths}=    Evaluate    [r['edit'] for r in $rows]
    ${forms}=    Read Job Forms    ${paths}
    Set Suite Variable    ${EDIT_ROWS}    ${rows}
    Set Suite Variable    ${EDIT_FORMS}    ${forms}

Open Edit Form
    [Documentation]    Start every test on the edit page of the first (newest) job, on a desktop window, with sending blocked.
    Set Window Size    1440    1000
    Go To Edit Form    ${EDIT_ROWS}[0][edit]
    Block The Form From Sending

Go To Edit Form
    [Arguments]    ${path}
    Go To    ${BASE_URL}${path}
    Wait For Edit Form To Load

Wait For Edit Form To Load
    Wait For Condition    return document.readyState === 'complete'
    Wait Until Element Is Visible    ${JN_H1}
    Wait Until Element Is Visible    ${JN_TITLE}
    Wait Until Element Is Visible    ${JN_PREVIEW}

Every Job Form Should Pass
    [Arguments]    ${check}
    Should Pass Job Form Check    ${check}    ${EDIT_FORMS}    ${EDIT_ROWS}

First Job Row
    RETURN    ${EDIT_ROWS}[0]

Skip Unless First Job Is Open
    Skip If    $EDIT_ROWS[0]['status'] != 'เปิดรับสมัครอยู่'    The first job is not open, this check needs an open job

# ================= open page =================
Edit Form Should Open From The List
    Go To Jobs Admin
    ${row}=    First Job Row
    Click In The Middle Of The Screen    ${JA_FIRST_EDIT}
    Wait Until Location Contains    ${row}[edit]    timeout=20s
    Wait For Edit Form To Load
    Title Should Be    ${JA_EDIT_TITLE_PREFIX}${row}[title]${JA_TITLE_SUFFIX}
    Element Should Be Visible    ${LOGIN_LOGOUT_BUTTON}

Edit Heading Should Match
    ${row}=    First Job Row
    Element Text Should Be    ${JN_BACK_LINK}    ${JN_BACK_TEXT}
    Element Text Should Be    ${JN_BADGE}    ${JN_BADGE_TEXT}
    Element Text Should Be    ${JN_H1}    ${JA_EDIT_TITLE_PREFIX}${row}[title]
    Element Text Should Be    ${JN_SUBTITLE}    ${JN_SUBTITLE_TEXT}
    Element Text Should Be    ${JN_SAVE}    ${JN_SAVE_TEXT}

Edit Form Should Ask For Login When Logged Out
    ${path}=    Set Variable    ${EDIT_ROWS}[0][edit]
    TRY
        Delete All Cookies
        Go To    ${BASE_URL}${path}
        Wait Until Location Contains    ${ADMIN_LOGIN_PATH}    timeout=20s
        ${url}=    Get Location
        ${next}=    Evaluate    __import__('urllib.parse').parse.quote($path, safe='')
        Should Contain    ${url}    next=${next}
        Page Should Not Contain Element    ${JN_FORM}
    FINALLY
        Go To    ${BASE_URL}${ADMIN_LOGIN_PATH}
        Login As Admin And Reach Dashboard
    END

Unknown Job Edit Page Should Show Not Found
    [Arguments]    ${id}
    Go To    ${BASE_URL}/admin/jobs/${id}
    Wait Until Page Contains    404    timeout=15s
    Title Should Be    ${JE_NOT_FOUND_TITLE}
    Page Should Not Contain Element    ${JN_FORM}

Odd Job Id Should Be Harmless
    Unknown Job Edit Page Should Show Not Found    ${JE_SCRIPT_ID}
    ${alert}=    Run Keyword And Return Status    Alert Should Be Present    action=DISMISS    timeout=1s
    Should Not Be True    ${alert}    The id in the address ran as a script (an alert appeared)

Typed Text Should Be Lost When Leaving Without Saving
    [Documentation]    Change the title, leave by the cancel link, and check the list and the edit page still have the saved title.
    ${row}=    First Job Row
    Set Form Value    ${JN_TITLE}    Typed but never saved
    Click In The Middle Of The Screen    ${JN_CANCEL}
    Wait Until Location Is    ${BASE_URL}${JN_LIST_PATH}    timeout=20s
    Wait Until Element Is Visible    id:adminJobsTableBody
    Page Should Not Contain    Typed but never saved
    Go To Edit Form    ${row}[edit]
    Textfield Value Should Be    ${JN_TITLE}    ${row}[title]

Refresh Should Bring Back The Saved Values
    ${row}=    First Job Row
    Set Form Value    ${JN_TITLE}    Typed before refresh
    Reload Page
    Wait For Edit Form To Load
    Textfield Value Should Be    ${JN_TITLE}    ${row}[title]

# ================= the form shows the saved job =================
Status Box Should Match The List
    ${row}=    First Job Row
    ${lines}=    Preview Lines
    Should Be Equal    ${lines}[0]    ${row}[status]
    ${expected}=    Set Variable If    $row['switch_on'] == 'true'    true    false
    Element Attribute Value Should Be    ${JN_HIDDEN_MANUAL}    value    ${expected}

Form Boxes Should Show The First Job
    ${form}=    Set Variable    ${EDIT_FORMS}[0]
    Textfield Value Should Be    ${JN_TITLE}    ${form}[job_title]
    Textfield Value Should Be    ${JN_DEADLINE}    ${form}[deadline]
    Selected Text Should Be    ${JN_DEPT}    ${form}[dept]
    Selected Text Should Be    ${JN_TYPE}    ${form}[type]
    Selected Text Should Be    ${JN_TAB}    ${form}[tab]
    Textfield Value Should Be    ${JN_WORK_LOCATION}    ${form}[work_location]
    Textfield Value Should Be    ${JN_VACANCIES}    ${form}[vacancies]
    Textarea Value Should Be    ${JN_LOCATION_TEXT}    ${form}[location_text]
    Textfield Value Should Be    ${JN_LAT}    ${form}[lat]
    Textfield Value Should Be    ${JN_LNG}    ${form}[lng]

Ticked Benefits Should Match The Saved Job
    ${form}=    Set Variable    ${EDIT_FORMS}[0]
    ${shown}=    Execute Javascript
    ...    return [...document.querySelectorAll('#jobManagementForm input[name="benefits"]')].filter(i => i.checked).map(i => i.parentElement.innerText.trim());
    Lists Should Be Equal    ${shown}    ${form}[benefits]

Benefits Should Flip When Clicked
    [Documentation]    Click each benefit once and look at the box; nothing is saved.
    ${count}=    Get Element Count    ${JN_BENEFITS}
    FOR    ${i}    IN RANGE    1    ${count} + 1
        ${locator}=    Set Variable    xpath:(//*[@id='jobManagementForm']//input[@name='benefits'])[${i}]
        ${before}=    Execute Javascript    return document.querySelectorAll('#jobManagementForm input[name="benefits"]')[${i} - 1].checked;
        Click In The Middle Of The Screen    ${locator}
        ${after}=    Execute Javascript    return document.querySelectorAll('#jobManagementForm input[name="benefits"]')[${i} - 1].checked;
        Should Not Be Equal    ${before}    ${after}    Benefit ${i} did not change when clicked
    END

Maps Link Should Show The Saved Coordinates
    ${form}=    Set Variable    ${EDIT_FORMS}[0]
    ${href}=    Get Element Attribute    ${JN_MAPS_LINK}    href
    Should Be Equal    ${href}    https://www.google.com/maps?q=${form}[lat],${form}[lng]

Whole Form Should Be Valid
    [Documentation]    A saved job must pass the browser's own checks, or HR could not save it again.
    ${invalid}=    Execute Javascript
    ...    return [...document.getElementById('jobManagementForm').elements].filter(e => e.willValidate && !e.validity.valid).map(e => e.id || e.name);
    Should Be Empty    ${invalid}    The browser says these boxes of the saved job are not valid: ${invalid}

Hidden Text Fields Should Be Filled When The Page Opens
    [Documentation]    Saving without touching the editors must still send their text.
    FOR    ${editor}    ${name}    ${block}    IN    @{JN_EDITORS_FLAT}
        ${shown}=    Get Text    id:${editor}
        ${plain}=    Hidden Value    ${name}
        ${html}=    Hidden Value    ${name}Html
        Should Not Be Empty    ${plain}    The hidden '${name}' field is empty although the editor shows text
        Should Not Be Empty    ${html}    The hidden '${name}Html' field is empty although the editor shows text
        ${squash_shown}=    Evaluate    __import__('re').sub(r'\\s+', '', $shown)
        ${squash_plain}=    Evaluate    __import__('re').sub(r'\\s+', '', $plain)
        Should Be Equal    ${squash_plain}    ${squash_shown}    The hidden '${name}' differs from the editor
    END

Emptied Title Should Be Refused On Edit
    Set Form Value    ${JN_TITLE}    ${EMPTY}
    ${path}=    Execute Javascript    return location.pathname;
    ${blocked_before}=    Execute Javascript    return window.__blockedSubmit;
    Click In The Middle Of The Screen    ${JN_SAVE}
    Sleep    1s
    ${blocked_after}=    Execute Javascript    return window.__blockedSubmit;
    Should Be Equal As Integers    ${blocked_after}    ${blocked_before}    The browser let the form go out with an empty title
    Location Should Be    ${BASE_URL}${path}
    ${invalid}=    Execute Javascript    return document.getElementById('jobTitleInput').matches(':invalid');
    Should Be True    ${invalid}

# ================= behaviours reused from the new job form (need an open Full-Time job) =================
Open Job Status Should Close With The Toggle
    Skip Unless First Job Is Open
    Manual Toggle Should Close The Job

Open Job Past Deadline Should Show Auto Expired
    Skip Unless First Job Is Open
    Past Deadline Should Show Auto Expired

Open Job Today Should Still Be Open
    Skip Unless First Job Is Open
    Today Should Still Be Open

Full Time Job Should Move To The Internship Tab
    Skip If    $EDIT_FORMS[0]['type'] != 'Full-Time'    The first job is not Full-Time
    Internship Type Should Move The Job To The Internship Tab

Urgent Box Should Flip The Hidden Field
    ${form}=    Set Variable    ${EDIT_FORMS}[0]
    ${start}=    Set Variable If    ${form}[hot]    true    false
    ${end}=    Set Variable If    ${form}[hot]    false    true
    Element Attribute Value Should Be    ${JN_HIDDEN_HOT}    value    ${start}
    Js Click    ${JN_HOT}
    Element Attribute Value Should Be    ${JN_HIDDEN_HOT}    value    ${end}
    Js Click    ${JN_HOT}
    Element Attribute Value Should Be    ${JN_HIDDEN_HOT}    value    ${start}
