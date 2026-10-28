*** Settings ***
Documentation     Apply Job form keywords (open, fill, upload, source, privacy, side panel, review dialog).
...               The tests never press "Confirm & Submit Application": that would create a real application.
Resource          ../common.resource
Resource          detail.resource
Resource          footer.resource
Library           ../../libraries/ApplyHelpers.py
Variables         ../../locators/apply_page.py
Variables         ../../testdata/apply_expected.py


*** Keywords ***
# ================= open / reset =================
Open Apply Form
    [Documentation]    Open the apply form of the default job (the one chosen by DETAIL_JOB_ONLY) on a desktop window.
    ${href}=    Detail Url Of Job    ${DEFAULT_DETAIL_JOB}
    Go To    ${href}/apply
    Set Window Size    1440    1000
    Wait Until Element Is Visible    ${APPLY_H1}

Apply Form Should Be Open
    Wait Until Location Contains    /apply
    Wait Until Element Is Visible    ${APPLY_H1}

Location Should Be Detail Of Default Job
    ${href}=    Detail Url Of Job    ${DEFAULT_DETAIL_JOB}
    ${loc}=    Get Location
    ${loc}=    Evaluate    $loc.rstrip('/')
    Should Be Equal    ${loc}    ${href}

Should Be On Detail Of Default Job
    Wait Until Keyword Succeeds    10s    1s    Location Should Be Detail Of Default Job

# ================= filling =================
Fill Field
    [Arguments]    ${key}    ${value}
    ${loc}=    Set Variable    ${FIELD}[${key}]
    Wait Until Element Is Visible    ${loc}
    Scroll Element Into View    ${loc}
    Input Text    ${loc}    ${value}

Field Value Should Be
    [Arguments]    ${key}    ${expected}
    ${value}=    Get Value    ${FIELD}[${key}]
    Should Be Equal As Strings    ${value}    ${expected}

Fill Valid Personal Info
    FOR    ${key}    IN    first_name    last_name    email    phone    salary
        Fill Field    ${key}    ${APPLICANT}[${key}]
    END

Upload Resume
    [Arguments]    ${kind}=pdf
    ${path}=    Make Test File    ${kind}
    Choose File    ${RESUME_INPUT}    ${path}

Upload Additional
    [Arguments]    ${kind}=pdf
    ${path}=    Make Test File    ${kind}
    Choose File    ${ADDITIONAL_INPUT}    ${path}

Click Hidden Control
    [Documentation]    Click a custom checkbox through its label.
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}
    Scroll Element Into View    ${locator}
    ${status}=    Run Keyword And Return Status    Click Element    ${locator}
    IF    not ${status}
        ${element}=    Get WebElement    ${locator}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}
    END

Select Source
    [Arguments]    ${name}
    ${loc}=    Format Locator    ${SOURCE_LABEL}    name=${name}
    Click Hidden Control    ${loc}

Agree To Privacy
    Click Hidden Control    ${PRIVACY_LABEL}

Fill Whole Form Valid
    [Arguments]    @{sources}
    Fill Valid Personal Info
    Upload Resume    pdf
    ${chosen}=    Create List    @{sources}
    ${count}=    Get Length    ${chosen}
    IF    ${count} == 0
        Append To List    ${chosen}    Facebook
    END
    FOR    ${name}    IN    @{chosen}
        Select Source    ${name}
    END
    Agree To Privacy

Click Review
    Click Element Safe    ${REVIEW_BUTTON}

# ================= messages =================
Text Should Be Shown
    [Arguments]    ${text}
    ${loc}=    Format Locator    ${TEXT_ANYWHERE}    text=${text}
    Wait Until Element Is Visible    ${loc}

Text Should Not Be Shown
    [Arguments]    ${text}
    ${loc}=    Format Locator    ${TEXT_ANYWHERE}    text=${text}
    Wait Until Element Is Not Visible    ${loc}    5s

Messages Should Be Shown
    [Arguments]    @{texts}
    FOR    ${text}    IN    @{texts}
        Text Should Be Shown    ${text}
    END

Field Should Be Marked Invalid
    [Arguments]    ${key}
    Element Attribute Value Should Be    ${FIELD}[${key}]    aria-invalid    true

Field Should Not Be Marked Invalid
    [Arguments]    ${key}
    ${value}=    Get Element Attribute    ${FIELD}[${key}]    aria-invalid
    Should Not Be Equal As Strings    ${value}    true

# ================= labels, placeholders, hints =================
Personal Labels Should Match
    FOR    ${key}    ${expected}    IN    &{FIELD_LABELS}
        ${id}=    Get Element Attribute    ${FIELD}[${key}]    id
        ${loc}=    Format Locator    ${FIELD_LABEL}    id=${id}
        Element Text Should Match    ${loc}    ${expected}    ignore_case=${False}
    END

Placeholders Should Match
    FOR    ${key}    ${expected}    IN    &{FIELD_PLACEHOLDERS}
        Element Attribute Value Should Be    ${FIELD}[${key}]    placeholder    ${expected}
    END

Dropzone Should Show
    [Arguments]    ${locator}    ${hint}
    Element Should Be Shown    ${locator}
    Element Should Contain    ${locator}    ${DROP_TEXT}
    Element Should Contain    ${locator}    ${hint}

# ================= files =================
File Should Be Listed
    [Arguments]    ${name}
    ${loc}=    Format Locator    ${FILE_NAME}    name=${name}
    Wait Until Element Is Visible    ${loc}

File Should Not Be Listed
    [Arguments]    ${name}
    ${loc}=    Format Locator    ${FILE_NAME}    name=${name}
    Wait Until Element Is Not Visible    ${loc}    5s

Remove File
    [Arguments]    ${name}
    ${loc}=    Format Locator    ${REMOVE_FILE}    name=${name}
    Click Hidden Control    ${loc}

# ================= source =================
Source Should Be Checked
    [Arguments]    ${name}
    ${loc}=    Format Locator    ${SOURCE_CHECKBOX}    name=${name}
    Wait Until Keyword Succeeds    5s    0.5s    Checkbox Should Be Selected    ${loc}

Source Should Not Be Checked
    [Arguments]    ${name}
    ${loc}=    Format Locator    ${SOURCE_CHECKBOX}    name=${name}
    Wait Until Keyword Succeeds    5s    0.5s    Checkbox Should Not Be Selected    ${loc}

All Source Options Should Be Shown
    Element Should Be Shown    ${SOURCE_QUESTION}
    FOR    ${group}    ${names}    IN    &{SOURCE_GROUPS}
        Text Should Be Shown    ${group}
        FOR    ${name}    IN    @{names}
            ${loc}=    Format Locator    ${SOURCE_LABEL}    name=${name}
            Element Should Be Shown    ${loc}
        END
    END

# ================= side panel =================
Progress Should Be
    [Arguments]    ${percent}
    Wait Until Keyword Succeeds    5s    0.5s    Element Attribute Value Should Be    ${PROGRESS}    aria-valuenow    ${percent}

Side Item Should Be Done
    [Arguments]    ${name}
    ${loc}=    Format Locator    ${SIDE_ITEM}    name=${name}
    Wait Until Keyword Succeeds    5s    0.5s    Element Should Contain    ${loc}    Done

Side Item Should Not Be Done
    [Arguments]    ${name}
    ${loc}=    Format Locator    ${SIDE_ITEM}    name=${name}
    ${text}=    Get Text    ${loc}
    Should Not Contain    ${text}    Done

Side Panel Should Start Empty
    Element Should Be Shown    ${SIDE_TITLE}
    Progress Should Be    0
    FOR    ${name}    ${subtitle}    IN    &{SIDE_ITEMS}
        ${loc}=    Format Locator    ${SIDE_ITEM}    name=${name}
        Element Should Be Shown    ${loc}
        Element Should Contain    ${loc}    ${subtitle}
    END

What To Expect Should Be Shown
    Element Should Be Shown    ${EXPECT_TITLE}
    FOR    ${line}    IN    @{EXPECT_LINES}
        Element Should Contain    ${EXPECT_BLOCK}    ${line}
    END

# ================= review dialog =================
Review Dialog Should Be Open
    Wait Until Element Is Visible    ${MODAL_TITLE}    20s
    Element Text Should Match    ${MODAL_TITLE}    ${REVIEW_TITLE_TEXT}    ignore_case=${False}

Review Dialog Should Be Closed
    Wait Until Element Is Not Visible    ${MODAL_TITLE}    5s

Review Dialog Should Include
    [Arguments]    @{texts}
    ${text}=    Get Text    ${MODAL_BODY}
    ${text}=    Evaluate    ' '.join($text.split())
    FOR    ${expected}    IN    @{texts}
        Should Contain    ${text}    ${expected}
    END

Open Review Dialog With Valid Form
    [Arguments]    @{sources}
    Fill Whole Form Valid    @{sources}
    Click Review
    Review Dialog Should Be Open

# ================= single checks =================
Apply Form Title Should Name The Job
    ${expected}=    Evaluate    $APPLY_PAGE_TITLE.format(title=$DEFAULT_DETAIL_JOB)
    Title Should Be    ${expected}

Apply Form Should Name The Job
    ${expected}=    Evaluate    $APPLY_PAGE_JOB_TEXT.format(title=$DEFAULT_DETAIL_JOB)
    Element Should Contain    ${APPLY_JOB_LINE}    ${expected}

Unknown Job Apply Form Should Show Not Found
    Go To    ${BASE_URL}${JOBS_PATH}/${UNKNOWN_JOB_ID}/apply
    Wait Until Page Contains    ${NOT_FOUND_HEADING_TEXT}    10s

Breadcrumb Should Show The Apply Path
    ${items}=    Get WebElements    ${BREADCRUMB_ITEMS}
    ${count}=    Get Length    ${items}
    Skip If    ${count} == 0    Dev apply page shows only the "Back to job details" link. Figma shows Careers > Jobs > Job Details > Apply Job. Waiting for the team to confirm.
    ${texts}=    Create List
    FOR    ${item}    IN    @{items}
        ${text}=    Get Text    ${item}
        Append To List    ${texts}    ${text.strip()}
    END
    Should Be Equal    ${texts}    ${BREADCRUMB_TEXTS}

Browser Back From Form Should Return To Detail
    Open Job Detail By Title    ${DEFAULT_DETAIL_JOB}
    Click Element Safe    ${APPLY_NOW}
    Apply Form Should Be Open
    Go Back
    Should Be On Detail Of Default Job

Form Sections Should Be Shown
    FOR    ${key}    ${expected}    IN    &{SECTION_TITLES_TEXT}
        Element Text Should Match    ${SECTION_TITLES_LOC}[${key}]    ${expected}    ignore_case=${False}
    END

Accept Types Should Be
    [Arguments]    ${locator}    ${expected}
    ${accept}=    Get Element Attribute    ${locator}    accept
    Should Be Equal    ${accept}    ${expected}

Portfolio Clear Link Should Clear The Field
    Fill Field Portfolio    ${PORTFOLIO_URL_OK}
    Click Element Safe    ${CLEAR_LINK}
    ${value}=    Get Value    ${PORTFOLIO_INPUT}
    Should Be Equal    ${value}    ${EMPTY}
    Wait Until Element Is Not Visible    ${CLEAR_LINK}    5s

Fill Field Portfolio
    [Arguments]    ${value}
    Wait Until Element Is Visible    ${PORTFOLIO_INPUT}
    Scroll Element Into View    ${PORTFOLIO_INPUT}
    Input Text    ${PORTFOLIO_INPUT}    ${value}

Only One Upload Message Should Be Shown After Empty Submit
    [Documentation]    Resume is required, Additional Documents are optional: only the resume message appears.
    Click Review
    Text Should Be Shown    ${ERR_RESUME_MISSING}
    ${count}=    Get Element Count    xpath://main//*[contains(normalize-space(),'Please upload')][not(*[contains(normalize-space(),'Please upload')])]
    Should Be Equal As Integers    ${count}    1

Progress Should Grow With Each Personal Field
    ${percent}=    Set Variable    ${0}
    FOR    ${key}    IN    first_name    last_name    email    phone    salary
        Fill Field    ${key}    ${APPLICANT}[${key}]
        ${percent}=    Evaluate    ${percent} + 5
        Progress Should Be    ${percent}
    END

Profile Panel Should Be On The Right On Desktop
    Set Window Size    1440    1000
    Reload Page
    Wait Until Element Is Visible    ${APPLY_H1}
    Element Should Be Visible    ${SIDE_TITLE}
    ${fx}=    Get Horizontal Position    ${RESUME_DROPZONE}
    ${fw}=    Get Element Size    ${RESUME_DROPZONE}
    ${sx}=    Get Horizontal Position    ${SIDE_TITLE}
    ${right_edge}=    Evaluate    int($fx) + int($fw[0])
    Should Be True    ${sx} >= ${right_edge} - 1    Side panel (x=${sx}) overlaps the form (right edge ${right_edge}).

Tab Key Should Move Through The Personal Fields
    Click Element Safe    ${FIELD}[first_name]
    ${seen}=    Create List
    FOR    ${n}    IN RANGE    4
        Press Keys    None    TAB
        ${id}=    Execute Javascript    return document.activeElement ? document.activeElement.id : '';
        Append To List    ${seen}    ${id}
    END
    ${expected}=    Create List    lastName    email    phone    expectedSalary
    Should Be Equal    ${seen}    ${expected}

Review Dialog Should Show The Job
    ${job}=    Get Job    ${DEFAULT_DETAIL_JOB}
    ${line}=    Evaluate    $REVIEW_JOB_LINE.format(title=$job['title'], job_type=$job['job_type'])
    Review Dialog Should Include    ${line}

Review Dialog Should Show The Personal Info
    Review Dialog Should Include
    ...    Name: ${APPLICANT}[first_name] ${APPLICANT}[last_name]
    ...    Email: ${APPLICANT}[email]
    ...    Phone: ${PHONE_IN_REVIEW}
    ...    Expected Salary: ${SALARY_SHOWN} THB

Review Dialog Should Show The Documents
    ${resume}=    Test File Name    pdf
    Review Dialog Should Include    Resume/CV: ${resume} 2 KB    Portfolio Link: ${PORTFOLIO_IN_REVIEW}

Apply Form Footer Should Be Shown
    [Documentation]    The apply page has two <footer> tags (the first one is empty), so look at the last one.
    ${footer}=    Set Variable    xpath:(//footer)[last()]
    Element Should Be Shown    ${footer}
    ${text}=    Get Text    ${footer}
    ${year}=    Evaluate    str(__import__('datetime').date.today().year)
    Should Contain    ${text}    ${FOOTER_EMAIL}
    Should Contain    ${text}    ${FOOTER_PHONE}
    Should Contain    ${text}    ${year}
