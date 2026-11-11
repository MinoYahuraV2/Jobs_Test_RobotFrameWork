*** Settings ***
Documentation     CMS applicant profile keywords: /admin/applications/<id>.
...               The suite reads the applicant table once, then downloads every profile page in one go
...               (libraries/ProfileData.py) so a check can run over ALL applicants, not just the first.
...               Nothing here saves a status or sends an email. Tests that change a status are manual.
Resource          ../common.resource
Resource          login.resource
Resource          dashboard.resource
Library           OperatingSystem
Library           ../../libraries/ProfileData.py
Variables         ../../locators/profile_page.py
Variables         ../../testdata/profile_expected.py


*** Keywords ***
# ================= open / reset =================
Open Profile Browser
    Open Admin Browser
    Login As Admin And Reach Dashboard
    Load Applicants Once

Load Applicants Once
    [Documentation]    Read the table and every profile once per test run and keep them in global variables.
    ${loaded}=    Get Variable Value    ${APPLICANT_ROWS}    ${None}
    IF    $loaded is None
        ${rows}=    Collect All Applicant Rows
        ${paths}=    Evaluate    [r['href'] for r in $rows]
        ${profiles}=    Read Profiles    ${paths}
        Set Global Variable    ${APPLICANT_ROWS}    ${rows}
        Set Global Variable    ${APPLICANT_PROFILES}    ${profiles}
    END

Collect All Applicant Rows
    Go To Dashboard
    ${footer}=    Get Table Footer
    ${last}=    Evaluate    ${footer}[pages] + 1
    ${rows}=    Create List
    FOR    ${page}    IN RANGE    1    ${last}
        IF    ${page} > 1
            Go To Dashboard    ?page=${page}
        END
        ${page_rows}=    Get Table Rows
        Append To List    ${rows}    @{page_rows}
    END
    Should Not Be Empty    ${rows}    The dashboard has no applicants, so there is no profile to test
    RETURN    ${rows}

Open Profile
    [Documentation]    Start every test on the first (newest) applicant's profile, on a desktop window.
    Set Window Size    1440    900
    Go To Profile    ${APPLICANT_ROWS}[0][href]

Go To Profile
    [Arguments]    ${path}
    Go To    ${BASE_URL}${path}
    Wait For Profile To Load

Wait For Profile To Load
    Wait For Condition    return document.readyState === 'complete'
    Wait Until Element Is Visible    ${PF_H1}
    Wait Until Element Is Visible    ${PF_STATUS_SELECT}

Log In Again
    Go To    ${BASE_URL}${ADMIN_LOGIN_PATH}
    Login As Admin And Reach Dashboard

Open Profile With
    [Documentation]    Open the first applicant that has this kind of data. SKIP when dev has none.
    [Arguments]    ${what}
    ${found}=    Should Have Profiles With    ${APPLICANT_PROFILES}    ${what}
    Go To Profile    ${found}[0][path]
    RETURN    ${found}[0]

Current Applicant
    [Documentation]    The profile dict (from the download) of the applicant open now.
    ${path}=    Execute Javascript    return location.pathname;
    FOR    ${profile}    IN    @{APPLICANT_PROFILES}
        IF    $profile['path'] == $path
            RETURN    ${profile}
        END
    END
    Fail    Applicant ${path} is not in the table that was read at the start

# ================= checks over every applicant =================
Every Profile Should Pass
    [Arguments]    ${check}
    Should Pass Profile Check    ${check}    ${APPLICANT_PROFILES}    ${APPLICANT_ROWS}

Every Status List Should Match
    Should Pass Profile Check    status_options    ${APPLICANT_PROFILES}    ${APPLICANT_ROWS}    ${PF_STATUS_OPTIONS}

Every Profile Needs
    [Arguments]    ${what}    ${check}
    Should Have Profiles With    ${APPLICANT_PROFILES}    ${what}
    Every Profile Should Pass    ${check}

Repeat Applicants Should Show Their History
    [Arguments]    ${what}=listed
    Repeat Applicants Should Show History    ${APPLICANT_PROFILES}    ${what}

# ================= open page =================
Profile Should Open From The Table
    Go To Dashboard
    ${row}=    First Row
    Open The First Profile
    Wait For Profile To Load
    Title Should Be    ${PF_TITLE_PREFIX}${row}[name]${PF_TITLE_SUFFIX}
    Element Should Be Visible    ${LOGIN_LOGOUT_BUTTON}

Heading And Subtitle Should Match
    Element Text Should Be    ${PF_H1}    ${PF_H1_TEXT}
    Element Text Should Be    ${PF_SUBTITLE}    ${PF_SUBTITLE_TEXT}

Title Should Name The Applicant
    ${profile}=    Current Applicant
    Title Should Be    ${PF_TITLE_PREFIX}${profile}[first] ${profile}[last]${PF_TITLE_SUFFIX}

Page Should Have Five Sections In Order
    ${found}=    Execute Javascript
    ...    return [document.querySelectorAll('#cms-content h1').length, [...document.querySelectorAll('#cms-content h2')].map(h => h.textContent.trim())];
    Should Be Equal As Integers    ${found}[0]    1    The page has ${found}[0] main headings (h1), expected 1
    Lists Should Be Equal    ${found}[1]    ${PF_SECTION_HEADINGS}

Link Should Return To The Applicant Table
    [Arguments]    ${locator}
    Click In The Middle Of The Screen    ${locator}
    Wait Until Location Contains    ${PF_LIST_PATH}    timeout=20s
    Location Should Contain    ${PF_LIST_FRAGMENT}
    Wait Until Element Is Visible    ${DASH_TABLE_SECTION}

Profile Should Ask For Login When Logged Out
    ${path}=    Set Variable    ${APPLICANT_ROWS}[0][href]
    TRY
        Delete All Cookies
        Go To    ${BASE_URL}${path}
        Wait Until Location Contains    ${ADMIN_LOGIN_PATH}    timeout=20s
        ${url}=    Get Location
        ${next}=    Evaluate    __import__('urllib.parse').parse.quote($path, safe='')
        Should Contain    ${url}    next=${next}
        Page Should Not Contain Element    ${PF_STATUS_SELECT}
    FINALLY
        Log In Again
    END

Unknown Applicant Should Show Not Found
    [Arguments]    ${id}
    Go To    ${BASE_URL}/admin/applications/${id}
    Wait Until Element Is Visible    ${PF_NOT_FOUND_BACK}
    Title Should Be    ${PF_NOT_FOUND_TITLE}
    Page Should Contain    ${PF_NOT_FOUND_HEADING}
    Page Should Contain    ${PF_NOT_FOUND_TEXT}
    Element Text Should Be    ${PF_NOT_FOUND_BACK}    ${PF_NOT_FOUND_BACK_TEXT}
    Page Should Not Contain Element    ${PF_STATUS_SELECT}

Odd Applicant Id Should Be Harmless
    Unknown Applicant Should Show Not Found    ${PF_SCRIPT_ID}
    ${alert}=    Run Keyword And Return Status    Alert Should Be Present    action=DISMISS    timeout=1s
    Should Not Be True    ${alert}    The id in the address ran as a script (an alert appeared)

Not Found Back Link Should Open The Applicant Table
    Go To    ${BASE_URL}/admin/applications/${PF_FAKE_ID}
    Wait Until Element Is Visible    ${PF_NOT_FOUND_BACK}
    Link Should Return To The Applicant Table    ${PF_NOT_FOUND_BACK}

Refresh Should Keep The Same Applicant
    ${before}=    Get Location
    Reload Page
    Wait For Profile To Load
    Location Should Be    ${before}
    Title Should Name The Applicant

# ================= application info =================
Section Should Be Titled
    [Arguments]    ${heading_locator}    ${heading}    ${section_locator}    @{texts}
    Element Text Should Be    ${heading_locator}    ${heading}
    FOR    ${text}    IN    @{texts}
        Element Should Contain    ${section_locator}    ${text}
    END

Info Section Should Be Titled
    Section Should Be Titled    ${PF_INFO_HEADING}    ${PF_SECTION_HEADINGS}[0]    ${PF_INFO_SECTION}
    ...    ${PF_INFO_NOTE}    ${PF_APPLIED_PREFIX}

Info Labels Should Match
    ${labels}=    Execute Javascript
    ...    return [...document.querySelectorAll("section[aria-labelledby='applicant-info-heading'] label")].map(l => l.textContent.trim());
    Lists Should Be Equal    ${labels}    ${PF_INFO_LABEL_TEXTS}

Consent Should Match The Application Time
    [Documentation]    Read in the browser: the downloaded page does not always carry the consent time.
    ${consent}=    Execute Javascript
    ...    const l = [...document.querySelectorAll('label')].find(x => x.textContent.trim() === 'Consent Form'); return l.nextElementSibling.innerText.replace(/\\s+/g, ' ').trim();
    ${applied}=    Execute Javascript
    ...    const s = [...document.querySelectorAll('span')].find(x => x.textContent.trim().startsWith('วันที่สมัคร:')); return s.textContent.replace('วันที่สมัคร:', '').trim();
    Should Start With    ${consent}    ยินยอมแล้ว
    Should End With    ${consent}    ${applied}

Info Fields Should Be Read Only
    ${count}=    Execute Javascript
    ...    return document.querySelectorAll("section[aria-labelledby='applicant-info-heading'] input, section[aria-labelledby='applicant-info-heading'] textarea, section[aria-labelledby='applicant-info-heading'] select, section[aria-labelledby='applicant-info-heading'] [contenteditable='true']").length;
    Should Be Equal As Integers    ${count}    0    The application info has ${count} editable control(s)

# ================= history =================
History Section Should Be Titled
    Section Should Be Titled    ${PF_HISTORY_HEADING}    ${PF_SECTION_HEADINGS}[1]    ${PF_HISTORY_SECTION}
    ...    ${PF_HISTORY_NOTE}    ${PF_HISTORY_BUTTON}

Same Name Link Should Open The Applicant Table
    Link Should Return To The Applicant Table    ${PF_SAME_NAME_LINK}

# ================= files =================
Files Section Should Be Titled
    Section Should Be Titled    ${PF_FILES_HEADING}    ${PF_SECTION_HEADINGS}[2]    ${PF_FILES_SECTION}
    ...    ${PF_FILES_NOTE}    ${PF_CV_TITLE}    ${PF_CV_TAG}    ${PF_EXTRA_TITLE}    ${PF_EXTRA_TAG}    ${PF_ZIP_NOTE}

Open The Preview
    Click In The Middle Of The Screen    ${PF_VIEW_PDF}
    Wait Until Element Is Visible    ${PF_DIALOG}    timeout=15s
    Wait Until Element Is Visible    ${PF_DIALOG_FRAME}    timeout=15s
    Sleep    1s

Preview Should Show The CV
    ${profile}=    Current Applicant
    Open The Preview
    Element Should Contain    ${PF_DIALOG_TITLE}    ${PF_PREVIEW_TITLE_PREFIX}
    Element Should Contain    ${PF_DIALOG}    ${profile}[cv]
    ${frame_title}=    Get Element Attribute    ${PF_DIALOG_FRAME}    title
    Should Contain    ${frame_title}    ${profile}[cv]
    ${src}=    Get Element Attribute    ${PF_DIALOG_FRAME}    src
    ${src}=    Without Viewer Options    ${src}
    ${stored}=    Stored File Name    ${profile}[cv]
    Should End With    ${src}    ${stored}

Without Viewer Options
    [Documentation]    The frame address may end with a PDF viewer option such as "#zoom=150". It is not part of the file address.
    [Arguments]    ${url}
    ${clean}=    Evaluate    $url.split('#')[0]
    RETURN    ${clean}

Stored File Name
    [Documentation]    The site keeps the file under a cleaned name: spaces and brackets are removed from the web address.
    [Arguments]    ${name}
    ${stored}=    Evaluate    __import__('re').sub(r'[^A-Za-z0-9._-]', '', $name)
    RETURN    ${stored}

Preview Download Link Should Match The Frame
    ${profile}=    Current Applicant
    Open The Preview
    ${src}=    Get Element Attribute    ${PF_DIALOG_FRAME}    src
    ${href}=    Get Element Attribute    ${PF_DIALOG_DOWNLOAD}    href
    ${download}=    Get Element Attribute    ${PF_DIALOG_DOWNLOAD}    download
    ${src}=    Without Viewer Options    ${src}
    ${href}=    Without Viewer Options    ${href}
    Should Be Equal    ${href}    ${src}
    Should Be Equal    ${download}    ${profile}[cv]

Preview File Should Be A Real Pdf
    Open The Preview
    ${src}=    Get Element Attribute    ${PF_DIALOG_FRAME}    src
    Pdf Should Be Real    ${src}

Close Button Should Close The Preview
    Open The Preview
    Click Element    ${PF_DIALOG_CLOSE}
    Wait Until Page Does Not Contain Element    ${PF_DIALOG}    timeout=10s

Escape Key Should Close The Preview
    Open The Preview
    Press Keys    NONE    ESCAPE
    Wait Until Page Does Not Contain Element    ${PF_DIALOG}    timeout=10s

# ================= email log =================
Log Section Should Be Titled
    Open Profile With    log_rows
    Section Should Be Titled    ${PF_LOG_HEADING}    ${PF_SECTION_HEADINGS}[3]    ${PF_LOG_SECTION}
    ...    ${PF_LOG_NOTE}    ${PF_LOG_TAG}
    ${headings}=    Get Table Headings Text    ${PF_LOG_HEADINGS}
    Lists Should Be Equal    ${headings}    ${PF_LOG_HEADINGS_TEXT}

Get Table Headings Text
    [Arguments]    ${locator}
    ${elements}=    Get WebElements    ${locator}
    ${texts}=    Create List
    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}
        Append To List    ${texts}    ${text}
    END
    RETURN    ${texts}

Log Recipient Should Be A Mail Link
    ${profile}=    Open Profile With    log_rows
    ${links}=    Execute Javascript
    ...    return [...document.querySelectorAll("section[aria-labelledby='email-history-heading'] tbody a[href^='mailto:']")].map(a => [a.getAttribute('href'), a.textContent.trim()]);
    Should Not Be Empty    ${links}    No mail link in the log
    FOR    ${link}    IN    @{links}
        Should Be Equal    ${link}[0]    mailto:${profile}[email]
        Should Be Equal    ${link}[1]    ${profile}[email]
    END

# ================= status panel =================
Status Panel Should Be Titled
    Element Text Should Be    ${PF_STATUS_HEADING}    ${PF_SECTION_HEADINGS}[4]
    Element Should Contain    ${PF_ASIDE}    ${PF_STATUS_NOTE}
    Element Should Contain    ${PF_ASIDE}    ${PF_AI_NOTE}
    Element Should Contain    ${PF_ASIDE}    ${PF_HR_NOTE}
    Element Should Contain    ${PF_ASIDE}    ผลประเมิน AI
    Element Should Contain    ${PF_ASIDE}    คะแนน AI

Failed AI Should Explain Itself
    Open Profile With    failed_ai
    Element Should Contain    ${PF_ASIDE}    ${PF_AI_FAILED_NOTE}
    Element Should Contain    ${PF_ASIDE}    ${PF_AI_FAILED}

Block Saving In This Page
    [Documentation]    Safety net: from now on the status form cannot be sent, so a test can never change a status.
    Execute Javascript
    ...    window.__blockedSubmit = 0; document.addEventListener('submit', function (e) { e.preventDefault(); e.stopImmediatePropagation(); window.__blockedSubmit += 1; }, true);

Pick A Different Status
    [Documentation]    Choose another option in the list WITHOUT saving. Returns the value that was saved before.
    ${before}=    Get Selected List Value    ${PF_STATUS_SELECT}
    ${other}=    Set Variable If    $before == 'passed'    failed    passed
    Select From List By Value    ${PF_STATUS_SELECT}    ${other}
    RETURN    ${before}

Changing Status Without Saving Should Not Keep It
    ${path}=    Execute Javascript    return location.pathname;
    Block Saving In This Page
    ${before}=    Pick A Different Status
    ${other}=    Get Selected List Value    ${PF_STATUS_SELECT}
    Should Not Be Equal    ${other}    ${before}
    Sleep    1s
    ${submitted}=    Execute Javascript    return window.__blockedSubmit;
    Should Be Equal As Integers    ${submitted}    0    Choosing a status sent the form by itself (it tried to save)
    Reload Page
    Wait For Profile To Load
    ${after}=    Get Selected List Value    ${PF_STATUS_SELECT}
    Should Be Equal    ${after}    ${before}    The status changed to ${after} without pressing Save
    Location Should Contain    ${path}

Status List Should Work With The Keyboard
    Block Saving In This Page
    ${before}=    Get Selected List Value    ${PF_STATUS_SELECT}
    Set Focus To Element    ${PF_STATUS_SELECT}
    Press Keys    NONE    ARROW_DOWN
    ${now}=    Get Selected List Value    ${PF_STATUS_SELECT}
    Should Not Be Equal    ${now}    ${before}    The arrow key did not change the status list
    ${submitted}=    Execute Javascript    return window.__blockedSubmit;
    Should Be Equal As Integers    ${submitted}    0
    Reload Page
    Wait For Profile To Load
    ${after}=    Get Selected List Value    ${PF_STATUS_SELECT}
    Should Be Equal    ${after}    ${before}    The status changed to ${after} without pressing Save

Save Buttons Should Be Ready
    Element Text Should Be    ${PF_TOP_SAVE}    ${PF_SAVE_TEXT}
    Element Text Should Be    ${PF_PANEL_SAVE}    ${PF_SAVE_TEXT}
    Element Should Be Enabled    ${PF_TOP_SAVE}
    Element Should Be Enabled    ${PF_PANEL_SAVE}
    Element Attribute Value Should Be    ${PF_TOP_SAVE}    form    applicant-status-form
    Element Attribute Value Should Be    ${PF_TOP_SAVE}    type    submit
    Element Attribute Value Should Be    ${PF_PANEL_SAVE}    type    submit

Status List Should Have A Label
    Element Text Should Be    ${PF_STATUS_LABEL}    สถานะ HR
    Element Attribute Value Should Be    ${PF_STATUS_SELECT}    name    status

AI Result Should Not Be Editable
    ${found}=    Execute Javascript
    ...    const f = document.getElementById('applicant-status-form'); return [f.querySelectorAll("input:not([type='hidden']), textarea").length, f.querySelectorAll('select').length];
    Should Be Equal As Integers    ${found}[0]    0    The status form has ${found}[0] text boxes, the AI result should not be editable
    Should Be Equal As Integers    ${found}[1]    1    The status form has ${found}[1] lists, expected only the HR status list

# ================= next steps =================
Next Steps Should Be Titled
    Element Should Contain    ${PF_ASIDE}    ${PF_NEXT_TITLE}
    Element Should Contain    ${PF_ASIDE}    ${PF_NEXT_NOTE}
    Element Text Should Be    ${PF_HEAD_EMAIL}    ${PF_HEAD_EMAIL_TEXT}
    Element Text Should Be    ${PF_CANDIDATE_EMAIL}    ${PF_CANDIDATE_EMAIL_TEXT}

Head Draft Should Open
    ${profile}=    Current Applicant
    Click In The Middle Of The Screen    ${PF_HEAD_EMAIL}
    Wait Until Location Contains    /email?type=head    timeout=20s
    Wait Until Element Is Visible    ${PF_DRAFT_SUBJECT}
    Title Should Be    ${PF_HEAD_DRAFT_TITLE}: ${profile}[first] ${profile}[last]${PF_TITLE_SUFFIX}
    Page Should Contain    ${profile}[email]
    Page Should Contain    ${profile}[job]

Candidate Draft Should Open
    ${profile}=    Current Applicant
    Click In The Middle Of The Screen    ${PF_CANDIDATE_EMAIL}
    Wait Until Location Contains    /email?type=candidate    timeout=20s
    Wait Until Element Is Visible    ${PF_DRAFT_SUBJECT}
    Title Should Be    ${PF_CANDIDATE_DRAFT_TITLE}: ${profile}[first] ${profile}[last]${PF_TITLE_SUFFIX}
    Page Should Contain    ${profile}[job]
    FOR    ${template}    IN    @{PF_CANDIDATE_TEMPLATES}
        Page Should Contain    ${template}
    END
    ${to}=    Get Value    ${PF_DRAFT_TO}
    Should Contain    ${to}    ${profile}[email]    The TO box does not hold the applicant's email

Draft Back Link Should Return To The Profile
    ${path}=    Execute Javascript    return location.pathname;
    Go To    ${BASE_URL}${path}/email?type=candidate
    Wait Until Element Is Visible    ${PF_DRAFT_BACK}
    Click Element    ${PF_DRAFT_BACK}
    Wait For Profile To Load
    Location Should Contain    ${path}

# ================= keyboard / layout =================
Tab Order Should Follow The Page
    Set Focus To Element    ${PF_BACK_LINK}
    ${seen}=    Create List
    ${count}=    Get Length    ${PF_TAB_ORDER}
    # One extra stop: an applicant with a history has the history table (a scrollable region) in the Tab order
    FOR    ${i}    IN RANGE    ${count} + 1
        IF    ${i} > 0
            Press Keys    NONE    TAB
        END
        ${text}=    Execute Javascript    return (document.activeElement.innerText || document.activeElement.getAttribute('aria-label') || '').trim();
        IF    not $text.startswith('${PF_HISTORY_TABLE_START}')
            Append To List    ${seen}    ${text}
        END
    END
    ${seen}=    Evaluate    $seen[:${count}]
    Lists Should Be Equal    ${seen}    ${PF_TAB_ORDER}

Panel Should Sit Beside The Sections
    [Documentation]    Wide screen: the status panel is in a right-hand column.
    ${box}=    Execute Javascript
    ...    const a = document.querySelector('#cms-content aside').getBoundingClientRect(); const s = document.querySelector('section[aria-labelledby="applicant-info-heading"]').getBoundingClientRect(); return [a.left, s.right, a.top, s.top];
    Should Be True    ${box}[0] >= ${box}[1]    The status panel is not to the right of the sections
    Should Be True    abs(${box}[2] - ${box}[3]) < 120    The status panel does not start at the top of the sections

Panel Should Sit Below The Sections
    [Documentation]    Tablet width: one column, the status panel after the last section.
    [Arguments]    ${width}    ${height}
    Set Window Size    ${width}    ${height}
    Sleep    ${RESULT_SETTLE}
    ${box}=    Execute Javascript
    ...    const a = document.querySelector('#cms-content aside').getBoundingClientRect(); const s = document.querySelector('section[aria-labelledby="email-history-heading"]').getBoundingClientRect(); return [a.top, s.bottom, a.left, s.left];
    Should Be True    ${box}[0] >= ${box}[1] - 1    The status panel is not below the last section
    Should Be True    abs(${box}[2] - ${box}[3]) < 2    The panel and the sections do not line up in one column
