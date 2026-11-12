*** Settings ***
Documentation     Real application keywords (tests/submit).
...               01_submit sends ONE REAL application to dev: it cannot be deleted from the CMS and it sends a real
...               confirmation email. It SKIPS unless  $env:JOBS_ALLOW_SUBMIT = "yes"  (config/env.py).
...               02_after_submit only LOOKS at the newest application of the test person in the CMS.
Resource          ../common.resource
Resource          apply.resource
Resource          login.resource
Resource          dashboard.resource
Resource          profile.resource
Variables         ../../testdata/submit_expected.py


*** Keywords ***
# ================= send the application (public site) =================
Require Submit Permission
    Skip If    not ${ALLOW_SUBMIT}    Real submission is off. To create a real application on dev set the environment variable JOBS_ALLOW_SUBMIT to yes and run again.

Open Submit Browser
    Require Submit Permission
    Open Jobs Page

Send The Application
    [Documentation]    Suite setup of 01_submit.
    Open Submit Browser
    Submit One Real Application

Link Of Submit Job
    [Documentation]    The apply page of the job named in SUBMIT_JOB_TITLE, found on the live Jobs page (not in jobs.json).
    Go To    ${BASE_URL}${JOBS_PATH}
    Wait For Condition    return document.readyState === 'complete'
    Wait Until Keyword Succeeds    20s    1s    Job Card Of Submit Job Should Exist
    ${href}=    Execute Javascript
    ...    const a = [...document.querySelectorAll('main article h3 a')].find(a => a.innerText.trim() === arguments[0]); return a ? a.getAttribute('href') : null;
    ...    ARGUMENTS    ${SUBMIT_JOB_TITLE}
    RETURN    ${href}

Job Card Of Submit Job Should Exist
    ${titles}=    Execute Javascript    return [...document.querySelectorAll('main article h3 a')].map(a => a.innerText.trim());
    Should Contain    ${titles}    ${SUBMIT_JOB_TITLE}    The public Jobs page has no job called '${SUBMIT_JOB_TITLE}' (it shows ${titles})

Fill The Application
    FOR    ${key}    IN    first_name    last_name    email    phone    salary
        Fill Field    ${key}    ${SUBMIT_APPLICANT}[${key}]
    END
    Upload Resume    pdf
    Select Source    ${SUBMIT_SOURCE}
    Agree To Privacy

Captcha Token Should Be There
    ${token}=    Execute Javascript
    ...    const i = document.querySelector('input[name="cf-turnstile-response"]'); return i ? i.value : '';
    Should Not Be Empty    ${token}    The captcha in the review window is not solved yet

Submit One Real Application
    [Documentation]    Fill the form, open the review window, wait for the captcha, press Confirm ONCE.
    ${href}=    Link Of Submit Job
    Go To    ${BASE_URL}${href}/apply
    Set Window Size    1440    1000
    Wait Until Element Is Visible    ${APPLY_H1}
    Fill The Application
    Click Review
    Review Dialog Should Be Open
    Wait Until Keyword Succeeds    40s    0.5s    Captcha Token Should Be There
    Click Element Safe    ${MODAL_CONFIRM}
    Wait Until Page Contains    ${SUCCESS_TITLE}    timeout=40s

Page Text
    ${text}=    Get Text    css:body
    ${text}=    Evaluate    ' '.join($text.split())
    RETURN    ${text}

Success Page Should Contain
    [Arguments]    ${expected}
    ${text}=    Page Text
    Should Contain    ${text}    ${expected}

Success Message Should Name The Job
    ${expected}=    Evaluate    $SUCCESS_THANKS.format(job=$SUBMIT_JOB_TITLE)
    Success Page Should Contain    ${expected}

Success Message Should Say What Happens Next
    Success Page Should Contain    ${SUCCESS_NEXT}

Success Message Should Name The Email
    ${expected}=    Evaluate    $SUCCESS_EMAIL.format(email=$SUBMIT_APPLICANT['email'])
    Success Page Should Contain    ${expected}

Success Contact Line Should Work
    Success Page Should Contain    ${SUCCESS_CONTACT}
    ${link}=    Set Variable    xpath://a[starts-with(@href, 'tel:')]
    Element Attribute Value Should Be    ${link}    href    ${SUCCESS_PHONE_HREF}

Success Buttons Should Be There
    Element Should Be Visible    xpath://*[normalize-space()='${SUCCESS_BACK_TEXT}']
    Element Should Be Visible    xpath://*[normalize-space()='${SUCCESS_VIEW_TEXT}']

Review Window Should Be Gone
    [Documentation]    After sending, the Confirm button is no longer there, so the same application cannot be sent twice from this window.
    Wait Until Element Is Not Visible    ${MODAL_CONFIRM}    5s

Back To Career Should Open The Home Page
    Click Element Safe    xpath://*[normalize-space()='${SUCCESS_BACK_TEXT}']
    # The site sends "/" on to "/jobs" (HTTP 307), so the browser ends up on the jobs list
    Wait Until Location Is    ${BASE_URL}/jobs    timeout=20s

# ================= look at the new application (CMS, read only) =================
Open Submit Check Browser
    Open Admin Browser
    Login As Admin And Reach Dashboard
    Load Applicants Once
    ${mine}=    Evaluate    [r for r in $APPLICANT_ROWS if r['name'] == $SUBMIT_FULL_NAME and r['email'] == $SUBMIT_APPLICANT['email']]
    Skip If    not ${mine}    No application of ${SUBMIT_FULL_NAME} on the dashboard yet. Run tests/submit/01_submit.robot once with JOBS_ALLOW_SUBMIT=yes.
    ${profile}=    Evaluate    [p for p in $APPLICANT_PROFILES if p['path'] == $mine[0]['href']][0]
    Set Suite Variable    ${NEW_ROW}    ${mine}[0]
    Set Suite Variable    ${NEW_PROFILE}    ${profile}

Open New Application Profile
    Set Window Size    1440    1000
    Go To Profile    ${NEW_ROW}[href]

New Application Should Be On Top Of The Dashboard
    Go To Dashboard
    ${first}=    First Row
    Should Be Equal    ${first}[name]    ${SUBMIT_FULL_NAME}
    Should Be Equal    ${first}[email]    ${SUBMIT_APPLICANT}[email]
    Should Be Equal    ${first}[href]    ${NEW_ROW}[href]

New Application Row Should Be Right
    Should Be Equal    ${NEW_ROW}[job]    ${SUBMIT_JOB_TITLE}
    # HR may have moved the application on since it was sent, so any known status is fine
    ${texts}=    Evaluate    [t for v, t in $PF_STATUS_OPTIONS]
    Should Contain    ${texts}    ${NEW_ROW}[status]
    ${known}=    Create List    @{PF_AI_LABELS}    ${AI_IN_PROGRESS}
    Should Contain    ${known}    ${NEW_ROW}[ai_label]

New Application Date Should Not Be In The Future
    ${when}=    Thai Datetime    ${NEW_PROFILE}[applied]
    ${now}=    Evaluate    __import__('datetime').datetime.now()
    ${age}=    Evaluate    ($now - $when).total_seconds() / 3600
    Should Be True    ${age} > -0.1    The application time ${NEW_PROFILE}[applied] is later than now (${age} hours)

New Application Data Should Match What Was Typed
    Should Be Equal    ${NEW_PROFILE}[first]    ${SUBMIT_APPLICANT}[first_name]
    Should Be Equal    ${NEW_PROFILE}[last]    ${SUBMIT_APPLICANT}[last_name]
    Should Be Equal    ${NEW_PROFILE}[email]    ${SUBMIT_APPLICANT}[email]
    Should Be Equal    ${NEW_PROFILE}[phone]    ${SUBMIT_PHONE_STORED}
    Should Be Equal    ${NEW_PROFILE}[job]    ${SUBMIT_JOB_TITLE}
    Should Be Equal    ${NEW_PROFILE}[salary]    ${SUBMIT_SALARY_STORED}
    ${sources}=    Create List    ${SUBMIT_SOURCE}
    Should Be Equal    ${NEW_PROFILE}[sources]    ${sources}

New Application Consent Should Be Recorded
    Open New Application Profile
    Consent Should Match The Application Time

New Application Files Should Be Right
    Should Be Equal    ${NEW_PROFILE}[cv]    ${SUBMIT_FILE_NAME}
    Should Be Equal    ${NEW_PROFILE}[cv_ext]    ${SUBMIT_FILE_EXT}
    Should Be Empty    ${NEW_PROFILE}[extra]

New Application HR Status Should Be Valid
    # Starts as hr_review, but HR may have changed it since. Any known (value, text) pair is fine
    ${ok}=    Evaluate    ($NEW_PROFILE['status_value'], $NEW_PROFILE['status_label']) in $PF_STATUS_OPTIONS
    Should Be True    ${ok}    Unknown HR status: ${NEW_PROFILE}[status_value] / ${NEW_PROFILE}[status_label]
    Should Be Equal    ${NEW_ROW}[status]    ${NEW_PROFILE}[status_label]    The dashboard row and the profile show different HR statuses

New Application AI Result Should Be Known
    ${known}=    Create List    @{PF_AI_LABELS}    ${AI_IN_PROGRESS}
    Should Contain    ${known}    ${NEW_PROFILE}[ai_label]

Confirmation Email Should Be Logged
    ${rows}=    Set Variable    ${NEW_PROFILE}[log_rows]
    Should Not Be Empty    ${rows}    No email in the log of the new application
    ${reply}=    Set Variable    ${rows}[-1]
    Should Start With    ${reply}[1]    ${AUTO_REPLY_TYPE}
    Should Contain    ${reply}[1]    ${AUTO_REPLY_SUBJECT}
    Should Contain    ${reply}[2]    ${SUBMIT_APPLICANT}[email]
    Should Contain    ${reply}[3]    ${AUTO_REPLY_SENDER}
    ${states}=    Create List    Sent    Failed
    Should Contain    ${states}    ${reply}[4]

Confirmation Email Time Should Follow The Application
    ${rows}=    Set Variable    ${NEW_PROFILE}[log_rows]
    ${sent}=    Thai Datetime    ${rows}[-1][0]
    ${applied}=    Thai Datetime    ${NEW_PROFILE}[applied]
    ${minutes}=    Evaluate    ($sent - $applied).total_seconds() / 60
    Should Be True    -1 <= ${minutes} <= ${AUTO_REPLY_MINUTES}    The email is logged ${minutes} minutes after the application

Head Draft Should Know The New Application
    Open New Application Profile
    Click In The Middle Of The Screen    ${PF_HEAD_EMAIL}
    Wait Until Location Contains    /email?type=head    timeout=20s
    Page Should Contain    ${SUBMIT_FULL_NAME}
    Page Should Contain    ${SUBMIT_JOB_TITLE}
    Page Should Contain    ${SUBMIT_FILE_NAME}

New Application History Should Follow The Rule
    [Documentation]    The page says history is found by first name + last name + phone. Nobody else has this name, so it should be empty.
    ${first}=    Set Variable    ${NEW_PROFILE}[first]
    ${last}=    Set Variable    ${NEW_PROFILE}[last]
    ${phone}=    Set Variable    ${NEW_PROFILE}[phone]
    ${others}=    Evaluate    [p for p in $APPLICANT_PROFILES if p['path'] != $NEW_PROFILE['path'] and (p['first'], p['last'], p['phone']) == ($first, $last, $phone)]
    ${expected}=    Get Length    ${others}
    ${shown}=    Set Variable    ${NEW_PROFILE}[history_count]
    ${shown}=    Set Variable If    $shown is None    0    ${shown}
    Should Be Equal As Integers    ${shown}    ${expected}    The new application shows ${shown} earlier application(s) but only ${expected} other application(s) have the same name and phone

Dashboard Badge Should Match The History
    [Documentation]    The row of the new application says 'เคยสมัคร N ครั้ง' only when N earlier applications exist.
    ${badge}=    Set Variable    ${NEW_ROW}[badge]
    ${found}=    Evaluate    __import__('re').search(r'([0-9]+)', $badge)
    Skip If    $found is None    The row has no 'เคยสมัคร N ครั้ง' badge
    ${shown}=    Set Variable If    $NEW_PROFILE['history_count'] is None    0    ${NEW_PROFILE}[history_count]
    ${number}=    Evaluate    int($found.group(1))
    Should Be Equal As Integers    ${number}    ${shown}    The badge says ${number} but the history lists ${shown}
