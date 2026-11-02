*** Settings ***
Documentation     CMS email draft to the applicant keywords: /admin/applications/<id>/email?type=candidate.
...               Built on email_head.resource (same form, same safety rule): NOTHING IS EVER SENT. The tests that press
...               the send button use a TO that cannot be valid and check that the HR status and email log did not change.
Resource          email_head.resource
Variables         ../../testdata/email_candidate_expected.py


*** Keywords ***
# ================= open / reset =================
Open Candidate Browser
    Open Admin Browser
    Login As Admin And Reach Dashboard
    Load Applicants Once
    Load Candidate Drafts Once

Load Candidate Drafts Once
    ${loaded}=    Get Variable Value    ${CANDIDATE_DRAFTS}    ${None}
    IF    $loaded is None
        ${paths}=    Evaluate    [r['href'] for r in $APPLICANT_ROWS]
        ${drafts}=    Read Drafts    ${paths}    candidate
        Set Global Variable    ${CANDIDATE_DRAFTS}    ${drafts}
    END

Open Candidate Draft
    [Documentation]    Start every test on the draft to the first (newest) applicant, on a desktop window.
    Set Window Size    1440    900
    Go To Draft    ${APPLICANT_ROWS}[0][href]    ?type=candidate

Every Candidate Draft Should Pass
    [Arguments]    ${check}
    Should Pass Draft Check    ${check}    ${CANDIDATE_DRAFTS}    ${APPLICANT_PROFILES}

# ================= open page =================
Candidate Draft Should Open From The Profile
    Go To Profile    ${APPLICANT_ROWS}[0][href]
    ${profile}=    Current Applicant
    Click In The Middle Of The Screen    ${PF_CANDIDATE_EMAIL}
    Wait Until Location Contains    ${EC_PATH_SUFFIX}    timeout=20s
    Wait For Draft To Load
    Title Should Be    ${EC_TITLE_PREFIX}${profile}[first] ${profile}[last]${ED_TITLE_SUFFIX}
    Element Should Be Visible    ${LOGIN_LOGOUT_BUTTON}

Candidate Heading And Subtitle Should Match
    Element Text Should Be    ${ED_H1}    ${EC_H1_TEXT}
    Element Text Should Be    ${ED_SUBTITLE}    ${EC_SUBTITLE_TEXT}

Candidate Draft Should Ask For Login When Logged Out
    ${path}=    Set Variable    ${APPLICANT_ROWS}[0][href]
    TRY
        Delete All Cookies
        Go To    ${BASE_URL}${path}/email?type=candidate
        Wait Until Location Contains    ${ADMIN_LOGIN_PATH}    timeout=20s
        ${url}=    Get Location
        ${next}=    Evaluate    __import__('urllib.parse').parse.quote($path + '/email', safe='')
        Should Contain    ${url}    next=${next}
        Page Should Not Contain Element    ${ED_SUBJECT}
    FINALLY
        Log In Again
    END

Unknown Applicant Candidate Draft Should Show Not Found
    [Arguments]    ${id}
    Go To    ${BASE_URL}/admin/applications/${id}/email?type=candidate
    Wait Until Element Is Visible    ${PF_NOT_FOUND_BACK}
    Title Should Be    ${PF_NOT_FOUND_TITLE}
    Page Should Contain    ${PF_NOT_FOUND_HEADING}
    Page Should Not Contain Element    ${ED_SUBJECT}

Refresh Should Keep The Same Candidate Draft
    ${before}=    Get Location
    Reload Page
    Wait For Draft To Load
    Location Should Be    ${before}
    Element Text Should Be    ${ED_H1}    ${EC_H1_TEXT}

# ================= form =================
Candidate Form Labels Should Match
    ${labels}=    Execute Javascript
    ...    return [...document.querySelectorAll('#cms-content form label')].map(l => l.textContent.replace(/\s+/g, ' ').trim());
    Lists Should Be Equal    ${labels}    ${EC_LABEL_TEXTS}

Template List Should Start With Interview
    ${expected}=    Evaluate    [t for v, t, *rest in $EC_TEMPLATES]
    ${options}=    Get List Items    ${ED_TEMPLATE}
    Lists Should Be Equal    ${options}    ${expected}
    List Selection Should Be    ${ED_TEMPLATE}    ${expected}[0]

Pick Template
    [Documentation]    Choose a template and wait until the subject has changed to its text. Saving is blocked.
    [Arguments]    ${value}
    Select From List By Value    ${ED_TEMPLATE}    ${value}
    Sleep    0.5s

Every Template Should Fill The Draft
    Block Saving In This Page
    ${profile}=    Current Draft Applicant
    ${name}=    Set Variable    ${profile}[first] ${profile}[last]
    ${flat}=    Evaluate    [x for row in $EC_TEMPLATES for x in row]
    FOR    ${value}    ${text}    ${subject}    ${status}    ${target}    ${phrase}    IN    @{flat}
        Pick Template    ${value}
        ${expected_subject}=    Evaluate    $subject.format(job=$profile['job'])
        Textfield Value Should Be    ${ED_SUBJECT}    ${expected_subject}
        ${body}=    Get Value    ${ED_BODY}
        ${greeting}=    Evaluate    $EC_GREETING.format(name=$name)
        Should Start With    ${body}    ${greeting}
        Should Contain    ${body}    ${profile}[job]
        Should Contain    ${body}    ${phrase}
        Should End With    ${body.strip()}    ${ED_BODY_END}
        Textfield Value Should Be    ${ED_TO}    ${profile}[email]
    END
    ${submitted}=    Execute Javascript    return window.__blockedSubmit;
    Should Be Equal As Integers    ${submitted}    0    Choosing a template sent the form by itself

Every Template Should Show Its Status After Sending
    Block Saving In This Page
    ${flat}=    Evaluate    [x for row in $EC_TEMPLATES for x in row]
    FOR    ${value}    ${text}    ${subject}    ${status}    ${target}    ${phrase}    IN    @{flat}
        Pick Template    ${value}
        Element Text Should Be    ${ED_STATUS_AFTER}    ${status}
        ${known}=    Evaluate    $status in [t for v, t in $PF_STATUS_OPTIONS]
        Should Be True    ${known}    '${status}' is not a word in the HR status list on the profile
    END

Every Template Should Send The Right Status Value
    [Documentation]    The hidden value the form sends. Compared with the codes of the HR status list on the profile.
    Block Saving In This Page
    ${codes}=    Evaluate    [v for v, t in $PF_STATUS_OPTIONS]
    ${flat}=    Evaluate    [x for row in $EC_TEMPLATES for x in row]
    FOR    ${value}    ${text}    ${subject}    ${status}    ${target}    ${phrase}    IN    @{flat}
        Pick Template    ${value}
        Element Attribute Value Should Be    ${ED_HIDDEN_TARGET}    value    ${target}
        ${saved}=    Evaluate    $EC_STATUS_ALIASES.get($target, $target)
        Should Contain    ${codes}    ${saved}    Template '${text}' sends '${target}' (saved as '${saved}'), which is not a code in the profile status list ${codes}
    END

Changing Template Should Replace The Text
    [Documentation]    Seen on dev: choosing another template overwrites what HR typed, without a warning.
    Block Saving In This Page
    Set Draft Field    ${ED_SUBJECT}    My own subject
    Set Draft Field    ${ED_BODY}    My own body
    Pick Template    candidate-passed
    ${profile}=    Current Draft Applicant
    ${expected}=    Evaluate    $EC_TEMPLATES[2][2].format(job=$profile['job'])
    Textfield Value Should Be    ${ED_SUBJECT}    ${expected}
    ${body}=    Get Value    ${ED_BODY}
    Should Not Contain    ${body}    My own body

Candidate Draft Should Have No Attachment Section
    Page Should Not Contain    ${ED_ATTACH_HEADING}
    Page Should Not Contain Element    ${ED_VIEW_PDF}

# ================= info panel / status after sending =================
Candidate Info Panel Should Be Titled
    Element Should Contain    ${ED_ASIDE}    ${ED_INFO_HEADING}
    Element Should Contain    ${ED_ASIDE}    ${ED_INFO_NOTE}
    FOR    ${label}    IN    @{ED_INFO_LABELS}
        Element Should Contain    ${ED_ASIDE}    ${label}
    END
    Element Text Should Be    ${ED_INFO_TYPE}    ${EC_INFO_TYPE_TEXT}

Candidate Status After Sending Should Be Shown
    Element Should Contain    ${ED_ASIDE}    ${ED_STATUS_HEADING}
    Element Should Contain    ${ED_ASIDE}    ${ED_STATUS_NOTE}
    Element Should Contain    ${ED_ASIDE}    ${ED_AUTO_UPDATE_TEXT}
    Checkbox Should Be Selected    ${ED_AUTO_UPDATE}
    Element Text Should Be    ${ED_STATUS_AFTER}    ${EC_DEFAULT_STATUS_AFTER}
    Element Attribute Value Should Be    ${ED_HIDDEN_UPDATE}    value    true

Turning Off The Candidate Status Update Should Be Remembered
    Unselect Checkbox    ${ED_AUTO_UPDATE}
    Element Text Should Be    ${ED_STATUS_AFTER}    ${ED_STATUS_AFTER_OFF}
    Element Attribute Value Should Be    ${ED_HIDDEN_UPDATE}    value    false
    Select Checkbox    ${ED_AUTO_UPDATE}
    Element Text Should Be    ${ED_STATUS_AFTER}    ${EC_DEFAULT_STATUS_AFTER}
    Element Attribute Value Should Be    ${ED_HIDDEN_UPDATE}    value    true

Turning Off The Update Should Hide The Template Status
    [Documentation]    With the update off, every template shows '-' and the form sends updateStatus=false.
    Block Saving In This Page
    Unselect Checkbox    ${ED_AUTO_UPDATE}
    ${flat}=    Evaluate    [x for row in $EC_TEMPLATES for x in row]
    FOR    ${value}    ${text}    ${subject}    ${status}    ${target}    ${phrase}    IN    @{flat}
        Pick Template    ${value}
        Element Text Should Be    ${ED_STATUS_AFTER}    ${ED_STATUS_AFTER_OFF}
        Element Attribute Value Should Be    ${ED_HIDDEN_UPDATE}    value    false
    END

# ================= keyboard / layout =================
Candidate Tab Order Should Follow The Page
    Set Focus To Element    ${ED_BACK_LINK}
    ${seen}=    Create List
    ${count}=    Get Length    ${EC_TAB_ORDER}
    FOR    ${i}    IN RANGE    ${count}
        IF    ${i} > 0
            Press Keys    NONE    TAB
        END
        ${text}=    Execute Javascript
        ...    const e = document.activeElement; return (e.tagName === 'INPUT' || e.tagName === 'TEXTAREA' || e.tagName === 'SELECT') ? e.id : e.innerText.trim();
        Append To List    ${seen}    ${text}
    END
    Lists Should Be Equal    ${seen}    ${EC_TAB_ORDER}
