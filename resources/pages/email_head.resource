*** Settings ***
Documentation     CMS email draft to Head keywords: /admin/applications/<id>/email?type=head.
...               The suite reads every applicant's draft once (libraries/EmailDraftData.py) and compares it with the
...               profile, so a check runs over ALL applicants.
...               NOTHING IS EVER SENT. The tests that press the send button use a TO address that cannot be valid
...               (Submit Draft That Must Be Rejected refuses to run otherwise) and check afterwards that the HR status
...               and the email log did not change. Real sending is a manual case.
Resource          ../common.resource
Resource          login.resource
Resource          dashboard.resource
Resource          profile.resource
Library           ../../libraries/EmailDraftData.py
Variables         ../../locators/email_draft_page.py
Variables         ../../testdata/email_draft_expected.py


*** Keywords ***
# ================= open / reset =================
Open Draft Browser
    Open Admin Browser
    Login As Admin And Reach Dashboard
    Load Applicants Once
    Load Drafts Once

Load Drafts Once
    ${loaded}=    Get Variable Value    ${HEAD_DRAFTS}    ${None}
    IF    $loaded is None
        ${paths}=    Evaluate    [r['href'] for r in $APPLICANT_ROWS]
        ${drafts}=    Read Drafts    ${paths}    head
        Set Global Variable    ${HEAD_DRAFTS}    ${drafts}
    END

Open Draft
    [Documentation]    Start every test on the Head draft of the first (newest) applicant, on a desktop window.
    Set Window Size    1440    900
    Go To Draft    ${APPLICANT_ROWS}[0][href]

Go To Draft
    [Arguments]    ${path}    ${query}=?type=head
    Go To    ${BASE_URL}${path}/email${query}
    Wait For Draft To Load

Wait For Draft To Load
    Wait For Condition    return document.readyState === 'complete'
    Wait Until Element Is Visible    ${ED_H1}
    Wait Until Element Is Visible    ${ED_SUBJECT}

Current Draft Path
    [Documentation]    The profile path (/admin/applications/<id>) of the draft that is open now.
    ${path}=    Execute Javascript    return location.pathname.replace('/email', '');
    RETURN    ${path}

Current Draft Applicant
    ${path}=    Current Draft Path
    FOR    ${profile}    IN    @{APPLICANT_PROFILES}
        IF    $profile['path'] == $path
            RETURN    ${profile}
        END
    END
    Fail    Applicant ${path} is not in the table that was read at the start

Every Draft Should Pass
    [Arguments]    ${check}
    Should Pass Draft Check    ${check}    ${HEAD_DRAFTS}    ${APPLICANT_PROFILES}

# ================= open page =================
Draft Should Open From The Profile
    Go To Profile    ${APPLICANT_ROWS}[0][href]
    ${profile}=    Current Applicant
    Click In The Middle Of The Screen    ${PF_HEAD_EMAIL}
    Wait Until Location Contains    ${ED_PATH_SUFFIX}    timeout=20s
    Wait For Draft To Load
    Title Should Be    ${ED_TITLE_PREFIX}${profile}[first] ${profile}[last]${ED_TITLE_SUFFIX}
    Element Should Be Visible    ${LOGIN_LOGOUT_BUTTON}

Draft Heading And Subtitle Should Match
    Element Text Should Be    ${ED_H1}    ${ED_H1_TEXT}
    Element Text Should Be    ${ED_SUBTITLE}    ${ED_SUBTITLE_TEXT}

Link Should Return To The Profile
    [Arguments]    ${locator}    ${text}
    ${path}=    Current Draft Path
    Element Text Should Be    ${locator}    ${text}
    Click In The Middle Of The Screen    ${locator}
    Wait For Profile To Load
    Location Should Be    ${BASE_URL}${path}

Draft Should Ask For Login When Logged Out
    ${path}=    Set Variable    ${APPLICANT_ROWS}[0][href]
    TRY
        Delete All Cookies
        Go To    ${BASE_URL}${path}/email?type=head
        Wait Until Location Contains    ${ADMIN_LOGIN_PATH}    timeout=20s
        ${url}=    Get Location
        ${next}=    Evaluate    __import__('urllib.parse').parse.quote($path + '/email', safe='')
        Should Contain    ${url}    next=${next}
        Page Should Not Contain Element    ${ED_SUBJECT}
    FINALLY
        Log In Again
    END

Unknown Applicant Draft Should Show Not Found
    [Arguments]    ${id}
    Go To    ${BASE_URL}/admin/applications/${id}/email?type=head
    Wait Until Element Is Visible    ${PF_NOT_FOUND_BACK}
    Title Should Be    ${PF_NOT_FOUND_TITLE}
    Page Should Contain    ${PF_NOT_FOUND_HEADING}
    Page Should Not Contain Element    ${ED_SUBJECT}

Other Draft Types Should Open The Head Draft
    [Documentation]    Seen on dev: no type, or a type that is not known, still opens the Head draft.
    ${path}=    Set Variable    ${APPLICANT_ROWS}[0][href]
    ${profile}=    Set Variable    ${APPLICANT_PROFILES}[0]
    Go To Draft    ${path}    ${EMPTY}
    Element Text Should Be    ${ED_H1}    ${ED_H1_TEXT}
    FOR    ${type}    IN    @{ED_UNKNOWN_TYPES}
        Go To Draft    ${path}    ?type=${type}
        Element Text Should Be    ${ED_H1}    ${ED_H1_TEXT}
        Title Should Be    ${ED_TITLE_PREFIX}${profile}[first] ${profile}[last]${ED_TITLE_SUFFIX}
    END

Refresh Should Keep The Same Draft
    ${before}=    Get Location
    Reload Page
    Wait For Draft To Load
    Location Should Be    ${before}
    Element Text Should Be    ${ED_H1}    ${ED_H1_TEXT}

# ================= form =================
Form Section Should Be Titled
    Element Should Contain    ${ED_FORM_SECTION}    ${ED_FORM_HEADING}
    Element Should Contain    ${ED_FORM_SECTION}    ${ED_FORM_NOTE}

Form Labels Should Match
    ${labels}=    Execute Javascript
    ...    return [...document.querySelectorAll('#cms-content form label')].map(l => l.textContent.replace(/\\s+/g, ' ').trim());
    Lists Should Be Equal    ${labels}    ${ED_LABEL_TEXTS}

Recipient Boxes Should Start Empty
    Textfield Value Should Be    ${ED_TO}    ${EMPTY}
    Textfield Value Should Be    ${ED_CC}    ${EMPTY}
    Element Attribute Value Should Be    ${ED_TO}    placeholder    ${ED_TO_PLACEHOLDER}
    Element Attribute Value Should Be    ${ED_CC}    placeholder    ${ED_CC_PLACEHOLDER}
    Element Attribute Value Should Be    ${ED_BODY}    placeholder    ${ED_BODY_PLACEHOLDER}

Set Draft Field
    [Documentation]    Put a value in a box the way typing does, so the page sees the change.
    [Arguments]    ${locator}    ${value}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript
    ...    const e = arguments[0]; const set = Object.getOwnPropertyDescriptor(Object.getPrototypeOf(e), 'value').set; set.call(e, arguments[1]); e.dispatchEvent(new Event('input', {bubbles: true}));
    ...    ARGUMENTS    ${element}    ${value}

Boxes Should Be Editable
    Block Saving In This Page
    Input Text    ${ED_TO}    head.test@example.com
    Input Text    ${ED_CC}    cc.test@example.com
    Input Text    ${ED_SUBJECT}    Edited subject
    Input Text    ${ED_BODY}    Edited body
    Textfield Value Should Be    ${ED_TO}    head.test@example.com
    Textfield Value Should Be    ${ED_CC}    cc.test@example.com
    Textfield Value Should Be    ${ED_SUBJECT}    Edited subject
    Textarea Value Should Be    ${ED_BODY}    Edited body
    ${submitted}=    Execute Javascript    return window.__blockedSubmit;
    Should Be Equal As Integers    ${submitted}    0    Typing in the boxes sent the form by itself

Clicking A Label Should Focus Its Box
    ${wrong}=    Execute Javascript
    ...    const bad = []; for (const l of document.querySelectorAll('#cms-content form label')) { if (!l.htmlFor || l.htmlFor === 'emailAutoUpdateStatus') { continue; } l.click(); if (document.activeElement.id !== l.htmlFor) { bad.push(l.textContent.trim() + ' -> ' + document.activeElement.id); } } return bad;
    Should Be Empty    ${wrong}    These labels do not focus their box: ${wrong}

# ================= attachments =================
Attachment Section Should Be Titled
    Element Should Contain    ${ED_ATTACH_SECTION}    ${ED_ATTACH_HEADING}
    Element Should Contain    ${ED_ATTACH_SECTION}    ${ED_ATTACH_NOTE}
    Element Should Contain    ${ED_ATTACH_SECTION}    ${ED_ATTACH_TAG}

Open The Draft Preview
    Click In The Middle Of The Screen    ${ED_VIEW_PDF}
    Wait Until Element Is Visible    ${ED_DIALOG}    timeout=15s
    Wait Until Element Is Visible    ${ED_DIALOG_FRAME}    timeout=15s
    Sleep    1s

Draft Preview Should Show The CV
    ${profile}=    Current Draft Applicant
    Open The Draft Preview
    Element Should Contain    ${ED_DIALOG}    ${profile}[cv]
    ${frame_title}=    Get Element Attribute    ${ED_DIALOG_FRAME}    title
    Should Contain    ${frame_title}    ${profile}[cv]
    ${src}=    Get Element Attribute    ${ED_DIALOG_FRAME}    src
    ${stored}=    Stored File Name    ${profile}[cv]
    Should End With    ${src}    ${stored}

Draft Preview Should Close
    Open The Draft Preview
    Click Element    ${ED_DIALOG_CLOSE}
    Wait Until Page Does Not Contain Element    ${ED_DIALOG}    timeout=10s

# ================= info panel / status after sending =================
Info Panel Should Be Titled
    Element Should Contain    ${ED_ASIDE}    ${ED_INFO_HEADING}
    Element Should Contain    ${ED_ASIDE}    ${ED_INFO_NOTE}
    FOR    ${label}    IN    @{ED_INFO_LABELS}
        Element Should Contain    ${ED_ASIDE}    ${label}
    END
    Element Text Should Be    ${ED_INFO_TYPE}    ${ED_INFO_TYPE_TEXT}

Status After Sending Should Be Shown
    Element Should Contain    ${ED_ASIDE}    ${ED_STATUS_HEADING}
    Element Should Contain    ${ED_ASIDE}    ${ED_STATUS_NOTE}
    Element Should Contain    ${ED_ASIDE}    ${ED_AUTO_UPDATE_TEXT}
    Checkbox Should Be Selected    ${ED_AUTO_UPDATE}
    Element Text Should Be    ${ED_STATUS_AFTER}    ${ED_STATUS_AFTER_TEXT}
    Element Attribute Value Should Be    ${ED_HIDDEN_UPDATE}    value    true

Status After Sending Should Match The Profile List
    [Documentation]    The text under "สถานะที่จะตั้งค่า" should be the same words as the HR status list on the profile.
    ${texts}=    Evaluate    [t for v, t in $PF_STATUS_OPTIONS]
    Should Contain    ${texts}    ${ED_STATUS_AFTER_TEXT}

Turning Off The Status Update Should Be Remembered
    Unselect Checkbox    ${ED_AUTO_UPDATE}
    Element Text Should Be    ${ED_STATUS_AFTER}    ${ED_STATUS_AFTER_OFF}
    Element Attribute Value Should Be    ${ED_HIDDEN_UPDATE}    value    false
    Select Checkbox    ${ED_AUTO_UPDATE}
    Element Text Should Be    ${ED_STATUS_AFTER}    ${ED_STATUS_AFTER_TEXT}
    Element Attribute Value Should Be    ${ED_HIDDEN_UPDATE}    value    true

Send Buttons Should Be Ready
    [Documentation]    Only looked at, never pressed.
    FOR    ${locator}    IN    ${ED_SEND_TOP}    ${ED_SEND_SIDE}
        Element Text Should Be    ${locator}    ${ED_SEND_TEXT}
        Element Should Be Enabled    ${locator}
        Element Attribute Value Should Be    ${locator}    form    emailDraftForm
        Element Attribute Value Should Be    ${locator}    type    submit
    END

# ================= validation (the server must refuse; nothing is sent) =================
Submit Draft That Must Be Rejected
    [Documentation]    Fill the boxes and press send, with a TO that cannot be valid. Refuses to run if the TO could be
    ...                a real address. Afterwards the HR status and the number of log rows must be unchanged.
    [Arguments]    ${to}=${ED_BAD_TO}    ${cc}=${EMPTY}    ${subject}=${None}    ${body}=${None}
    ${could_send}=    Address Could Be Valid    ${to}
    Should Not Be True    ${could_send}    Refusing to press send: TO "${to}" could be a real address
    ${path}=    Current Draft Path
    ${before}=    Applicant State    ${path}
    Set Draft Field    ${ED_TO}    ${to}
    IF    $cc != ''
        Set Draft Field    ${ED_CC}    ${cc}
    END
    IF    $subject is not None
        Set Draft Field    ${ED_SUBJECT}    ${subject}
    END
    IF    $body is not None
        Set Draft Field    ${ED_BODY}    ${body}
    END
    Click In The Middle Of The Screen    ${ED_SEND_TOP}
    Wait Until Element Is Visible    ${ED_BANNER}    timeout=20s
    Sleep    1s
    ${after}=    Applicant State    ${path}
    Lists Should Be Equal    ${after}    ${before}    The refused form still changed the applicant (status/log before ${before}, after ${after})

Box Should Be Marked Invalid
    [Arguments]    ${locator}
    Element Attribute Value Should Be    ${locator}    aria-invalid    true

Empty To Should Be Refused
    Submit Draft That Must Be Rejected    to=${EMPTY}
    Element Text Should Be    ${ED_BANNER}    ${ED_BANNER_TEXT}
    Page Should Contain    ${ED_TO_EMPTY_ERROR}
    Box Should Be Marked Invalid    ${ED_TO}

Spaces Only To Should Be Refused
    Submit Draft That Must Be Rejected    to=${SPACE}${SPACE}${SPACE}
    Page Should Contain    ${ED_TO_EMPTY_ERROR}
    Box Should Be Marked Invalid    ${ED_TO}

Wrong To Should Be Refused
    Submit Draft That Must Be Rejected
    Element Text Should Be    ${ED_BANNER}    ${ED_BANNER_TEXT}
    Page Should Contain    ${ED_TO_BAD_ERROR}
    Box Should Be Marked Invalid    ${ED_TO}

Empty Subject Should Be Refused
    Submit Draft That Must Be Rejected    subject=${EMPTY}
    Page Should Contain    ${ED_SUBJECT_EMPTY_ERROR}
    Box Should Be Marked Invalid    ${ED_SUBJECT}

Empty Body Should Be Refused
    Submit Draft That Must Be Rejected    body=${EMPTY}
    Page Should Contain    ${ED_BODY_EMPTY_ERROR}
    Box Should Be Marked Invalid    ${ED_BODY}

Wrong Cc Should Be Flagged
    [Documentation]    The TO is wrong on purpose so nothing is sent; the CC should be flagged as well.
    Submit Draft That Must Be Rejected    cc=${ED_BAD_CC}
    Box Should Be Marked Invalid    ${ED_CC}

Boxes Should Keep What Was Typed After A Refusal
    Submit Draft That Must Be Rejected    subject=My own subject    body=My own body
    Textfield Value Should Be    ${ED_TO}    ${ED_BAD_TO}
    Textfield Value Should Be    ${ED_SUBJECT}    My own subject
    Textarea Value Should Be    ${ED_BODY}    My own body

# ================= keyboard / layout =================
Draft Tab Order Should Follow The Page
    Set Focus To Element    ${ED_BACK_LINK}
    ${seen}=    Create List
    ${count}=    Get Length    ${ED_TAB_ORDER}
    FOR    ${i}    IN RANGE    ${count}
        IF    ${i} > 0
            Press Keys    NONE    TAB
        END
        ${text}=    Execute Javascript
        ...    const e = document.activeElement; return (e.tagName === 'INPUT' || e.tagName === 'TEXTAREA') ? e.id : e.innerText.trim();
        Append To List    ${seen}    ${text}
    END
    Lists Should Be Equal    ${seen}    ${ED_TAB_ORDER}

Info Panel Should Sit Beside The Form
    ${box}=    Execute Javascript
    ...    const a = document.querySelector('#cms-content aside').getBoundingClientRect(); const s = document.querySelector('#emailDraftTo').closest('section').getBoundingClientRect(); return [a.left, s.right, a.top, s.top];
    Should Be True    ${box}[0] >= ${box}[1]    The info panel is not to the right of the form
    Should Be True    abs(${box}[2] - ${box}[3]) < 120    The info panel does not start at the top of the form

Info Panel Should Sit Below The Form
    [Arguments]    ${width}    ${height}
    Set Window Size    ${width}    ${height}
    Sleep    ${RESULT_SETTLE}
    ${box}=    Execute Javascript
    ...    const a = document.querySelector('#cms-content aside').getBoundingClientRect(); const s = document.querySelector('#emailDraftTo').closest('section').getBoundingClientRect(); return [a.top, s.bottom, a.left, s.left];
    Should Be True    ${box}[0] >= ${box}[1] - 1    The info panel is not below the form
    Should Be True    abs(${box}[2] - ${box}[3]) < 2    The panel and the form do not line up in one column
