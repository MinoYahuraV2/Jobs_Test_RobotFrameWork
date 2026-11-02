*** Settings ***
Documentation     CMS new job form keywords: /admin/jobs/new.
...               THE TESTS NEVER SAVE A JOB. A saved job appears on the public Jobs page and cannot be deleted from
...               the CMS. Every press of the save button here is made with the title empty, which the browser refuses
...               (Browser Should Refuse To Send), and Block The Form From Sending stops anything that would still go out.
...               Real saving and the checks that need the server to say no are manual cases.
Resource          ../common.resource
Resource          login.resource
Resource          dashboard.resource
Library           DateTime
Variables         ../../locators/job_new_page.py
Variables         ../../testdata/job_new_expected.py


*** Keywords ***
# ================= open / reset =================
Open New Job Browser
    Open Admin Browser
    Login As Admin And Reach Dashboard

Open New Job Form
    [Documentation]    Start every test on an empty form, on a desktop window, with sending blocked.
    Set Window Size    1440    1000
    Go To New Job Form
    Block The Form From Sending

Go To New Job Form
    Go To    ${BASE_URL}${JN_PATH}
    Wait For New Job Form To Load

Wait For New Job Form To Load
    Wait For Condition    return document.readyState === 'complete'
    Wait Until Element Is Visible    ${JN_H1}
    Wait Until Element Is Visible    ${JN_TITLE}
    Wait Until Element Is Visible    ${JN_PREVIEW}

Block The Form From Sending
    [Documentation]    Safety net: from now on the form cannot go to the server, whatever a test presses.
    Execute Javascript
    ...    window.__blockedSubmit = 0; document.addEventListener('submit', function (e) { e.preventDefault(); e.stopImmediatePropagation(); window.__blockedSubmit += 1; }, true);

Set Form Value
    [Documentation]    Put a value in a box the way typing does, so the page sees the change.
    [Arguments]    ${locator}    ${value}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript
    ...    const e = arguments[0]; const set = Object.getOwnPropertyDescriptor(Object.getPrototypeOf(e), 'value').set; set.call(e, arguments[1]); e.dispatchEvent(new Event('input', {bubbles: true})); e.dispatchEvent(new Event('change', {bubbles: true}));
    ...    ARGUMENTS    ${element}    ${value}
    Sleep    0.3s

Js Click
    [Documentation]    Click a styled checkbox that is drawn by the page (the real box is hidden).
    [Arguments]    ${locator}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}
    Sleep    0.3s

Preview Lines
    ${lines}=    Execute Javascript
    ...    return document.getElementById('jobStatusPreview').innerText.split('\\n').map(s => s.trim()).filter(Boolean);
    RETURN    ${lines}

Preview Should Show
    [Arguments]    ${status}
    ${lines}=    Preview Lines
    Should Be Equal    ${lines}[0]    ${status}[0]
    Should Be Equal    ${lines}[-1]    ${status}[1]

Day From Today
    [Arguments]    ${days}
    ${day}=    Get Current Date    result_format=%Y-%m-%d    increment=${days} days
    RETURN    ${day}

# ================= open page =================
New Job Form Should Open From The List
    Go To    ${BASE_URL}${JN_LIST_PATH}
    Wait Until Element Is Visible    id:adminJobsTableBody
    Click Element    xpath://*[@id='cms-content']//a[@href='${JN_PATH}']
    Wait Until Location Contains    ${JN_PATH}    timeout=20s
    Wait For New Job Form To Load
    Title Should Be    ${JN_TITLE_TEXT}
    Element Should Be Visible    ${LOGIN_LOGOUT_BUTTON}

New Job Heading Should Match
    Element Text Should Be    ${JN_BACK_LINK}    ${JN_BACK_TEXT}
    Element Text Should Be    ${JN_BADGE}    ${JN_BADGE_TEXT}
    Element Text Should Be    ${JN_H1}    ${JN_H1_TEXT}
    Element Text Should Be    ${JN_SUBTITLE}    ${JN_SUBTITLE_TEXT}

Jobs Menu Should Be The Current Page
    ${links}=    Visible Menu Links
    Should Be Equal    ${links}[2][1]    page    The Jobs menu item is not marked as the current page

New Job Form Should Ask For Login When Logged Out
    TRY
        Delete All Cookies
        Go To    ${BASE_URL}${JN_PATH}
        Wait Until Location Contains    ${ADMIN_LOGIN_PATH}    timeout=20s
        ${url}=    Get Location
        Should Contain    ${url}    next=%2Fadmin%2Fjobs%2Fnew
        Page Should Not Contain Element    ${JN_FORM}
    FINALLY
        Go To    ${BASE_URL}${ADMIN_LOGIN_PATH}
        Login As Admin And Reach Dashboard
    END

Link Should Return To The Job List
    [Arguments]    ${locator}    ${text}
    Element Text Should Be    ${locator}    ${text}
    Click In The Middle Of The Screen    ${locator}
    Wait Until Location Is    ${BASE_URL}${JN_LIST_PATH}    timeout=20s
    Wait Until Element Is Visible    id:adminJobsTableBody

Leaving The Form Should Not Create A Job
    [Documentation]    Fill in the form, leave by the cancel link, and check the job list is unchanged.
    Go To    ${BASE_URL}${JN_LIST_PATH}
    Wait Until Element Is Visible    id:adminJobsTableBody
    ${before}=    Get Text    id:adminJobResultCount
    Go To New Job Form
    Block The Form From Sending
    Input Text    ${JN_TITLE}    A job that must never be saved
    Click In The Middle Of The Screen    ${JN_CANCEL}
    Wait Until Location Is    ${BASE_URL}${JN_LIST_PATH}    timeout=20s
    Wait Until Element Is Visible    id:adminJobsTableBody
    ${after}=    Get Text    id:adminJobResultCount
    Should Be Equal    ${after}    ${before}
    Page Should Not Contain    A job that must never be saved

Refresh Should Give An Empty Form
    Input Text    ${JN_TITLE}    Typed before refresh
    Reload Page
    Wait For New Job Form To Load
    Textfield Value Should Be    ${JN_TITLE}    ${EMPTY}

# ================= form defaults =================
Section Headings And Notes Should Show
    FOR    ${text}    IN    ${JN_LOCATION_HEADING}    ${JN_LOCATION_NOTE}    ${JN_STATUS_HEADING}    ${JN_MANUAL_TITLE}
    ...    ${JN_MANUAL_NOTE}    ${JN_DEADLINE_NOTE}    ${JN_METADATA_HEADING}    ${JN_INTERN_NOTE}    ${JN_URGENT_TEXT}
    ...    ${JN_BENEFITS_HEADING}    ${JN_BENEFITS_NOTE}
        Element Should Contain    ${JN_CONTENT}    ${text}
    END
    Element Text Should Be    ${JN_SAVE}    ${JN_SAVE_TEXT}
    Element Text Should Be    ${JN_CANCEL}    ${JN_CANCEL_TEXT}

Field Labels Should Match
    ${labels}=    Execute Javascript
    ...    return [...document.querySelectorAll('#cms-content label[for]')].map(l => l.textContent.replace(/\\s+/g, ' ').trim()).filter(t => t !== '');
    Lists Should Be Equal    ${labels}    ${JN_LABELS}

Title Should Start Empty
    Textfield Value Should Be    ${JN_TITLE}    ${EMPTY}
    Element Attribute Value Should Be    ${JN_TITLE}    placeholder    ${JN_TITLE_PLACEHOLDER}

Other Fields Should Start With Defaults
    Selected Text Should Be    ${JN_DEPT}    ${JN_DEFAULT_DEPT}
    Selected Text Should Be    ${JN_TYPE}    ${JN_DEFAULT_TYPE}
    Selected Text Should Be    ${JN_TAB}    ${JN_DEFAULT_TAB}
    Textfield Value Should Be    ${JN_WORK_LOCATION}    ${JN_DEFAULT_WORK_LOCATION}
    Textfield Value Should Be    ${JN_VACANCIES}    ${JN_DEFAULT_VACANCIES}
    Textarea Value Should Be    ${JN_LOCATION_TEXT}    ${JN_DEFAULT_LOCATION_TEXT}
    Textfield Value Should Be    ${JN_LAT}    ${JN_DEFAULT_LAT}
    Textfield Value Should Be    ${JN_LNG}    ${JN_DEFAULT_LNG}
    Checkbox Should Not Be Selected    ${JN_HOT}
    Checkbox Should Be Selected    ${JN_MANUAL}

Selected Text Should Be
    [Arguments]    ${locator}    ${text}
    ${selected}=    Get Selected List Label    ${locator}
    Should Be Equal    ${selected}    ${text}

Default Deadline Should Be Thirty Days Away
    ${expected}=    Day From Today    ${JN_DEFAULT_DEADLINE_DAYS}
    Textfield Value Should Be    ${JN_DEADLINE}    ${expected}

Sample Text Should Be In The Editors
    [Documentation]    Seen on dev: the three editors start with sample sentences, not empty.
    ${about}=    Get Text    ${JN_ABOUT}
    ${resp}=    Get Text    ${JN_RESPONSIBILITIES}
    ${qual}=    Get Text    ${JN_QUALIFICATIONS}
    Should Contain    ${about}    ${JN_DEFAULT_ABOUT_START}
    Should Contain    ${resp}    ${JN_DEFAULT_RESP_START}
    Should Contain    ${qual}    ${JN_DEFAULT_QUAL_START}

Lists Should Have The Right Choices
    ${departments}=    Get List Items    ${JN_DEPT}
    ${types}=    Get List Items    ${JN_TYPE}
    ${tabs}=    Get List Items    ${JN_TAB}
    Lists Should Be Equal    ${departments}    ${JN_DEPARTMENTS}
    Lists Should Be Equal    ${types}    ${JN_TYPES}
    Lists Should Be Equal    ${tabs}    ${JN_TABS}

Benefits Should Be Listed And Unticked
    ${labels}=    Execute Javascript
    ...    return [...document.querySelectorAll('#jobManagementForm input[name="benefits"]')].map(i => [i.parentElement.innerText.trim(), i.checked]);
    ${names}=    Evaluate    [n for n, c in $labels]
    ${ticked}=    Evaluate    [n for n, c in $labels if c]
    Lists Should Be Equal    ${names}    ${JN_BENEFIT_NAMES}
    Should Be Empty    ${ticked}    These benefits are ticked before anyone chose: ${ticked}

Benefits Should Be Tickable
    ${count}=    Get Element Count    ${JN_BENEFITS}
    FOR    ${i}    IN RANGE    1    ${count} + 1
        ${locator}=    Set Variable    xpath:(//*[@id='jobManagementForm']//input[@name='benefits'])[${i}]
        Click In The Middle Of The Screen    ${locator}
        Checkbox Should Be Selected    ${locator}
    END
    Click In The Middle Of The Screen    xpath:(//*[@id='jobManagementForm']//input[@name='benefits'])[1]
    Checkbox Should Not Be Selected    xpath:(//*[@id='jobManagementForm']//input[@name='benefits'])[1]

Required Fields Should Be Marked Required
    ${missing}=    Execute Javascript
    ...    const ids = ['jobTitleInput', 'jobLocationTextInput', 'jobLocationLatInput', 'jobLocationLngInput', 'jobDeadlineInput', 'jobDeptInput', 'jobEmploymentTypeInput', 'jobTabTypeInput', 'jobWorkLocationInput', 'jobVacanciesInput']; return ids.filter(i => !document.getElementById(i).required);
    Should Be Empty    ${missing}    These fields have a star but the browser does not require them: ${missing}
    Element Attribute Value Should Be    ${JN_VACANCIES}    min    1

# ================= editors =================
Editors Should Sync The Hidden Fields
    [Documentation]    What is typed in each editor reaches the plain text field and the HTML field that are sent.
    FOR    ${editor}    ${name}    ${block}    IN    @{JN_EDITORS_FLAT}
        Focus Editor And Clear    ${editor}
        Press Keys    NONE    Typed in ${name}
        Sleep    0.4s
        ${plain}=    Hidden Value    ${name}
        ${html}=    Hidden Value    ${name}Html
        Should Be Equal    ${plain}    Typed in ${name}
        Should Contain    ${html}    Typed in ${name}
    END

Focus Editor And Clear
    [Arguments]    ${editor}
    Execute Javascript    const e = document.getElementById(arguments[0]); e.scrollIntoView({block: 'center'}); e.focus();    ARGUMENTS    ${editor}
    Sleep    0.3s
    Press Keys    NONE    CTRL+a    DELETE
    Sleep    0.3s

Hidden Value
    [Arguments]    ${name}
    ${value}=    Execute Javascript    return document.querySelector('#jobManagementForm input[name="' + arguments[0] + '"]').value;    ARGUMENTS    ${name}
    RETURN    ${value}

Special Characters Should Be Escaped
    Focus Editor And Clear    jobAboutEditor
    Press Keys    NONE    ${JN_SCRIPT_TEXT}
    Sleep    0.4s
    ${plain}=    Hidden Value    about
    ${html}=    Hidden Value    aboutHtml
    Should Be Equal    ${plain}    ${JN_SCRIPT_TEXT}
    Should Contain    ${html}    &lt;script&gt;
    Should Not Contain    ${html}    <script>
    ${alert}=    Run Keyword And Return Status    Alert Should Be Present    action=DISMISS    timeout=1s
    Should Not Be True    ${alert}    The text ran as a script (an alert appeared)

Press Toolbar Button
    [Arguments]    ${editor_block}    ${label}
    Execute Javascript
    ...    const b = document.querySelector('#' + arguments[0] + ' button[aria-label="' + arguments[1] + '"]'); b.click();
    ...    ARGUMENTS    ${editor_block}    ${label}
    Sleep    0.4s

Bold Button Should Make Text Bold
    Focus Editor And Clear    jobAboutEditor
    Press Keys    NONE    Bold words
    Press Keys    NONE    CTRL+a
    Press Toolbar Button    jobAboutEditorBlock    ตัวหนา
    ${html}=    Hidden Value    aboutHtml
    Should Match Regexp    ${html}    <(b|strong)>Bold words</(b|strong)>

List Buttons Should Make Lists
    Focus Editor And Clear    jobAboutEditor
    Press Keys    NONE    One item
    Press Keys    NONE    CTRL+a
    Press Toolbar Button    jobAboutEditorBlock    รายการแบบจุด
    ${html}=    Hidden Value    aboutHtml
    Should Contain    ${html}    <ul>
    Should Contain    ${html}    One item
    Press Toolbar Button    jobAboutEditorBlock    รายการแบบตัวเลข
    ${html}=    Hidden Value    aboutHtml
    Should Contain    ${html}    <ol>

Heading Choice Should Make A Heading
    Focus Editor And Clear    jobAboutEditor
    Press Keys    NONE    A heading
    Press Keys    NONE    CTRL+a
    Execute Javascript
    ...    const s = document.querySelector('#jobAboutEditorBlock select[aria-label="รูปแบบข้อความ (Font Format)"]'); s.value = 'h2'; s.dispatchEvent(new Event('change', {bubbles: true}));
    Sleep    0.4s
    ${html}=    Hidden Value    aboutHtml
    Should Contain    ${html}    <h2>

Emptying An Editor Should Empty The Hidden Fields
    FOR    ${editor}    ${name}    ${block}    IN    @{JN_EDITORS_FLAT}
        Focus Editor And Clear    ${editor}
        ${plain}=    Hidden Value    ${name}
        Should Be Empty    ${plain}    The ${name} field still holds '${plain}' after the editor was emptied
    END

Every Editor Should Have Its Toolbar
    FOR    ${editor}    ${name}    ${block}    IN    @{JN_EDITORS_FLAT}
        ${buttons}=    Execute Javascript
        ...    return [...document.querySelectorAll('#' + arguments[0] + ' button')].map(b => b.getAttribute('aria-label'));
        ...    ARGUMENTS    ${block}
        ${lists}=    Execute Javascript
        ...    return [...document.querySelectorAll('#' + arguments[0] + ' select')].map(b => b.getAttribute('aria-label'));
        ...    ARGUMENTS    ${block}
        Lists Should Be Equal    ${buttons}    ${JN_TOOLBAR_BUTTONS}
        Lists Should Be Equal    ${lists}    ${JN_TOOLBAR_LISTS}
        Element Should Contain    id:${block}    ${JN_REQUIRED_TAG}
    END

# ================= publishing status =================
Default Status Should Be Open
    Preview Should Show    ${JN_STATUS_OPEN}
    Element Attribute Value Should Be    ${JN_HIDDEN_MANUAL}    value    true

Manual Toggle Should Close The Job
    Js Click    ${JN_MANUAL}
    Preview Should Show    ${JN_STATUS_FORCE}
    Element Attribute Value Should Be    ${JN_HIDDEN_MANUAL}    value    false
    Js Click    ${JN_MANUAL}
    Preview Should Show    ${JN_STATUS_OPEN}
    Element Attribute Value Should Be    ${JN_HIDDEN_MANUAL}    value    true

Past Deadline Should Show Auto Expired
    ${day}=    Day From Today    -1
    Set Form Value    ${JN_DEADLINE}    ${day}
    Preview Should Show    ${JN_STATUS_EXPIRED}

Today Should Still Be Open
    ${day}=    Day From Today    0
    Set Form Value    ${JN_DEADLINE}    ${day}
    Preview Should Show    ${JN_STATUS_OPEN}

Past Deadline Should Win Over The Manual Toggle
    [Documentation]    Seen on dev: with the toggle off AND a past date the preview says auto-expired.
    ${day}=    Day From Today    -1
    Set Form Value    ${JN_DEADLINE}    ${day}
    Js Click    ${JN_MANUAL}
    Preview Should Show    ${JN_STATUS_EXPIRED}

Deadline Box Should Need A Date
    Set Form Value    ${JN_DEADLINE}    ${EMPTY}
    ${missing}=    Execute Javascript    return document.getElementById('jobDeadlineInput').validity.valueMissing;
    Should Be True    ${missing}    An empty closing date is accepted by the browser

# ================= metadata =================
Internship Type Should Move The Job To The Internship Tab
    Select From List By Label    ${JN_TYPE}    Internship
    Selected Text Should Be    ${JN_TAB}    ${JN_INTERN_TAB}
    Select From List By Label    ${JN_TYPE}    Full-Time
    Selected Text Should Be    ${JN_TAB}    ${JN_DEFAULT_TAB}

Urgent Box Should Set The Hidden Field
    Element Attribute Value Should Be    ${JN_HIDDEN_HOT}    value    false
    Js Click    ${JN_HOT}
    Element Attribute Value Should Be    ${JN_HIDDEN_HOT}    value    true
    Js Click    ${JN_HOT}
    Element Attribute Value Should Be    ${JN_HIDDEN_HOT}    value    false

Vacancies Box Should Take Whole Numbers From One
    FOR    ${value}    ${valid}    IN    1    ${True}    5    ${True}    0    ${False}    -3    ${False}    1.5    ${False}
        Set Form Value    ${JN_VACANCIES}    ${value}
        ${ok}=    Execute Javascript    return document.getElementById('jobVacanciesInput').validity.valid;
        Should Be Equal    ${ok}    ${valid}    Vacancies '${value}': the browser says valid=${ok}, expected ${valid}
    END

Coordinates Should Take Decimal Numbers
    FOR    ${value}    ${valid}    IN    13.5    ${True}    -45.25    ${True}    100    ${True}
        Set Form Value    ${JN_LAT}    ${value}
        ${ok}=    Execute Javascript    return document.getElementById('jobLocationLatInput').validity.valid;
        Should Be Equal    ${ok}    ${valid}    Latitude '${value}': valid=${ok}
    END
    Set Form Value    ${JN_LAT}    abc
    ${text}=    Get Value    ${JN_LAT}
    Should Be Empty    ${text}    The latitude box kept letters: '${text}'

Maps Link Should Follow The Coordinates
    Set Form Value    ${JN_LAT}    13.5
    Set Form Value    ${JN_LNG}    100.25
    ${href}=    Get Element Attribute    ${JN_MAPS_LINK}    href
    Should Be Equal    ${href}    https://www.google.com/maps?q=13.5,100.25
    Element Attribute Value Should Be    ${JN_MAPS_LINK}    target    _blank
    ${rel}=    Get Element Attribute    ${JN_MAPS_LINK}    rel
    Should Contain    ${rel}    noopener
    Set Form Value    ${JN_LAT}    ${EMPTY}
    Page Should Not Contain Element    ${JN_MAPS_LINK}

# ================= validation (the browser refuses; nothing is sent) =================
Browser Should Refuse To Send
    [Documentation]    Press save with the title empty. The browser must stop it before any form is sent.
    ${blocked_before}=    Execute Javascript    return window.__blockedSubmit;
    ${empty}=    Execute Javascript    return document.getElementById('jobTitleInput').value === '';
    Should Be True    ${empty}    Refusing to press save: the title is not empty
    Click In The Middle Of The Screen    ${JN_SAVE}
    Sleep    1s
    ${blocked_after}=    Execute Javascript    return window.__blockedSubmit;
    Should Be Equal As Integers    ${blocked_after}    ${blocked_before}    The browser let the form go out with an empty title
    Location Should Be    ${BASE_URL}${JN_PATH}

Empty Title Should Be Refused
    Browser Should Refuse To Send
    ${invalid}=    Execute Javascript    return document.getElementById('jobTitleInput').matches(':invalid');
    Should Be True    ${invalid}

Each Required Box Left Empty Should Be Invalid
    [Documentation]    Empty one box at a time and ask the browser; nothing is pressed.
    FOR    ${locator}    IN    ${JN_LOCATION_TEXT}    ${JN_LAT}    ${JN_LNG}    ${JN_DEADLINE}    ${JN_WORK_LOCATION}    ${JN_VACANCIES}
        Set Form Value    ${locator}    x
        Set Form Value    ${locator}    ${EMPTY}
        ${element}=    Get WebElement    ${locator}
        ${missing}=    Execute Javascript    return arguments[0].validity.valueMissing;    ARGUMENTS    ${element}
        Should Be True    ${missing}    ${locator} can be left empty
    END

Whole Form Should Be Invalid Only Because Of The Title
    [Documentation]    Everything else is filled by default, so the title is the only thing the browser should complain about.
    ${invalid}=    Execute Javascript
    ...    return [...document.getElementById('jobManagementForm').elements].filter(e => e.willValidate && !e.validity.valid).map(e => e.id || e.name);
    Lists Should Be Equal    ${invalid}    ${{['jobTitleInput']}}

# ================= keyboard / layout =================
Main Fields Should Follow The Tab Order
    Execute Javascript    document.getElementById('jobTitleInput').focus();
    ${seen}=    Create List
    FOR    ${i}    IN RANGE    120
        ${id}=    Execute Javascript    return document.activeElement.id;
        IF    $id in $JN_TAB_ORDER and $id not in $seen
            Append To List    ${seen}    ${id}
        END
        IF    $id == 'jobHotInput'
            BREAK
        END
        Press Keys    NONE    TAB
    END
    Lists Should Be Equal    ${seen}    ${JN_TAB_ORDER}

Status Panel Should Sit Beside The Form
    ${box}=    Execute Javascript
    ...    const a = document.querySelector('#cms-content aside').getBoundingClientRect(); const s = document.getElementById('jobTitleInput').getBoundingClientRect(); return [a.left, s.right];
    Should Be True    ${box}[0] >= ${box}[1]    The side panel is not to the right of the form fields

Status Panel Should Sit Below The Form
    [Arguments]    ${width}    ${height}
    Set Window Size    ${width}    ${height}
    Sleep    ${RESULT_SETTLE}
    ${box}=    Execute Javascript
    ...    const a = document.querySelector('#cms-content aside').getBoundingClientRect(); const s = document.getElementById('jobLocationLngInput').getBoundingClientRect(); return [a.top, s.bottom];
    Should Be True    ${box}[0] >= ${box}[1]    The side panel is not below the form fields
