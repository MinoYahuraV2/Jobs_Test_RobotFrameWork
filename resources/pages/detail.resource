*** Settings ***
Documentation     Job Detail page keywords (open, header, sections, contact, apply/share, SEO, layout).
Resource          ../common.resource
Resource          job_cards.resource
Resource          footer.resource
Library           ../../libraries/DetailHelpers.py
Variables         ../../locators/detail_page.py
Variables         ../../testdata/detail_expected.py


*** Keywords ***
# ================= open / reset =================
Get Detail Urls
    [Documentation]    {job title: detail URL} for every card on the Jobs page. Read once per test file.
    ${cached}=    Get Variable Value    ${DETAIL_URLS}    ${None}
    IF    $cached is not None    RETURN    ${cached}
    Go To Jobs Page
    Require Values    ${JOB_CARD}    ${CARD}[title]
    ${urls}=    Create Dictionary
    ${count}=    Get Element Count    ${JOB_CARD}
    ${end}=    Evaluate    ${count} + 1
    FOR    ${i}    IN RANGE    1    ${end}
        ${loc}=    Card Child    ${JOB_CARD}    ${i}    ${CARD}[title]
        ${title}=    Get Text    ${loc}
        ${href}=    Get Element Attribute    ${loc}    href
        ${clean}=    Evaluate    $title.strip()
        Set To Dictionary    ${urls}    ${clean}    ${href}
    END
    IF    $DETAIL_JOB_ONLY
        ${keep}=    Evaluate    {k: v for k, v in $urls.items() if k == $DETAIL_JOB_ONLY}
        ${urls}=    Set Variable    ${keep}
    END
    Set Suite Variable    ${DETAIL_URLS}    ${urls}
    RETURN    ${urls}

Detail Url Of Job
    [Arguments]    ${title}
    ${urls}=    Get Detail Urls
    Skip If    $title not in $urls    "${title}" is not on the Jobs page right now (changed in the CMS?).
    RETURN    ${urls}[${title}]

Open Job Detail By Title
    [Arguments]    ${title}
    ${href}=    Detail Url Of Job    ${title}
    Go To    ${href}
    Wait Until Element Is Visible    ${DETAIL_H1}

Open Default Detail Page
    Open Job Detail By Title    ${DEFAULT_DETAIL_JOB}

Open Detail Page Of Job With Id
    [Arguments]    ${job_id}
    Go To    ${BASE_URL}${JOBS_PATH}/${job_id}

Location Should Be Jobs List
    ${loc}=    Get Location
    Should Match Regexp    ${loc}    ^https?://[^/]+${JOBS_PATH}/?$

Location Should Be Careers Home
    ${loc}=    Get Location
    Should Match Regexp    ${loc}    ^https?://[^/]+(${JOBS_PATH})?/?$

Location Should Be A Job Detail
    ${loc}=    Get Location
    Should Match Regexp    ${loc}    ^https?://[^/]+${JOBS_PATH}/[^/]+$

Require Real Detail Data
    Require Real Job Data
    ${urls}=    Get Detail Urls
    Skip If    not $urls    No job to test on the Jobs page (DETAIL_JOB_ONLY = "${DETAIL_JOB_ONLY}").

Card Is Selected
    [Documentation]    True when card ${i} is the job chosen by DETAIL_JOB_ONLY (or when no job is chosen).
    [Arguments]    ${i}
    IF    not $DETAIL_JOB_ONLY    RETURN    ${True}
    ${loc}=    Card Child    ${JOB_CARD}    ${i}    ${CARD}[title]
    ${name}=    Get Text    ${loc}
    ${same}=    Evaluate    $name.strip() == $DETAIL_JOB_ONLY
    RETURN    ${same}

# ================= run one check on every job =================
Every Job Detail Field Should Match
    [Documentation]    Open the detail page of every job on the Jobs page and check one field against the data.
    [Arguments]    ${field}
    Require Real Detail Data
    ${urls}=    Get Detail Urls
    FOR    ${title}    ${href}    IN    &{urls}
        ${job}=    Get Job    ${title}
        Go To    ${href}
        Wait Until Element Is Visible    ${DETAIL_H1}
        Detail Field Should Match    ${job}    ${field}
    END

Detail Field Should Match
    [Arguments]    ${job}    ${field}
    IF    '${field}' == 'title'
        ${count}=    Get Element Count    ${DETAIL_H1}
        Should Be Equal As Integers    ${count}    1
        Element Text Should Match    ${DETAIL_H1}    ${job}[title]    ignore_case=${False}
    ELSE IF    '${field}' == 'tab_title'
        Title Should Be    ${job}[title]${TITLE_SUFFIX}
    ELSE IF    '${field}' == 'type_badge'
        Element Text Should Match    ${DETAIL_TYPE_BADGE}    ${job}[job_type]    ignore_case=${False}
    ELSE IF    '${field}' == 'urgent'
        ${expected}=    Expected Card Text    ${job}    urgent_badge
        IF    $expected is None
            Page Should Not Contain Element    ${DETAIL_URGENT}
        ELSE
            Element Text Should Match    ${DETAIL_URGENT}    ${expected}    ignore_case=${False}
        END
    ELSE IF    '${field}' == 'deadline'
        ${expected}=    Expected Card Text    ${job}    deadline
        IF    $expected is None
            Page Should Not Contain Element    ${DETAIL_DEADLINE}
        ELSE
            Element Text Should Include    ${DETAIL_DEADLINE}    ${expected}
        END
    ELSE IF    '${field}' == 'department'
        Detail Info Should Be    department    ${job}[department]
    ELSE IF    '${field}' == 'job_type'
        Detail Info Should Be    job_type    ${job}[job_type]
    ELSE IF    '${field}' == 'work_location'
        Detail Info Should Be    work_location    ${WORK_LOCATION_TEXT}
    ELSE IF    '${field}' == 'salary'
        Detail Info Should Be    salary    ${SALARY_TEXT}
    ELSE IF    '${field}' == 'vacancies'
        Skip If    'vacancies' not in $job    jobs.json has no vacancies for this job.
        ${expected}=    Evaluate    str($job['vacancies'])
        Detail Info Should Be    vacancies    ${expected}
    ELSE IF    '${field}' == 'about'
        Element Text Should Match    ${ABOUT_HEADING}    ${ABOUT_HEADING_TEXT}    ignore_case=${False}
        Element Text Should Match    ${ABOUT_TEXT}    ${job}[description]    ignore_case=${False}
    ELSE IF    '${field}' == 'responsibilities'
        Skip If    'responsibilities' not in $job    jobs.json has no responsibilities for this job.
        Element Should Be Visible    ${RESPONSIBILITIES_HEADING}
        Detail List Should Match    ${RESPONSIBILITIES_ITEMS}    ${job}[responsibilities]
    ELSE IF    '${field}' == 'qualifications'
        Skip If    'qualifications' not in $job    jobs.json has no qualifications for this job.
        Element Should Be Visible    ${QUALIFICATIONS_HEADING}
        Detail List Should Match    ${QUALIFICATIONS_ITEMS}    ${job}[qualifications]
    ELSE IF    '${field}' == 'benefits'
        Skip If    'benefits' not in $job    jobs.json has no benefits for this job.
        Detail List Should Match    ${BENEFITS_ITEMS}    ${job}[benefits]
    ELSE IF    '${field}' == 'location'
        Element Text Should Match    ${LOCATION_HEADING}    ${LOCATION_HEADING_TEXT}    ignore_case=${False}
        Element Text Should Match    ${LOCATION_TEXT}    ${job}[location]    ignore_case=${False}
    ELSE IF    '${field}' == 'seo_meta'
        ${meta}=    Get Meta Description
        ${ok}=    Description Matches Meta    ${job}[description]    ${meta}
        Should Be True    ${ok}    meta description does not match the job description: ${meta}
    ELSE IF    '${field}' == 'seo_title'
        ${posting}=    Get Job Posting Data
        Should Be Equal    ${posting}[title]    ${job}[title]
    ELSE IF    '${field}' == 'seo_type'
        ${posting}=    Get Job Posting Data
        ${expected}=    Evaluate    $EMPLOYMENT_TYPE[$job['job_type']]
        Should Be Equal    ${posting}[employmentType]    ${expected}
    ELSE IF    '${field}' == 'seo_openings'
        Skip If    'vacancies' not in $job    jobs.json has no vacancies for this job.
        ${posting}=    Get Job Posting Data
        Should Be Equal As Integers    ${posting}[totalJobOpenings]    ${job}[vacancies]
    ELSE IF    '${field}' == 'seo_valid'
        Skip If    not $job['deadline']    This job has no deadline.
        ${posting}=    Get Job Posting Data
        ${thai_day}=    Thai Day Text    ${posting}[validThrough]    ${THAILAND_UTC_HOURS}
        ${expected}=    Expected Card Text    ${job}    deadline
        Should Be Equal    Due ${thai_day}    ${expected}
    ELSE
        Fail    Unknown detail field: ${field}
    END

Detail Info Should Be
    [Arguments]    ${key}    ${expected}
    ${label}=    Set Variable    ${INFO_LABELS}[${key}]
    ${label_loc}=    Format Locator    ${DETAIL_INFO_LABEL}    label=${label}
    ${value_loc}=    Format Locator    ${DETAIL_INFO_VALUE}    label=${label}
    Element Should Be Visible    ${label_loc}
    Element Text Should Match    ${value_loc}    ${expected}    ignore_case=${False}

Detail List Should Match
    [Arguments]    ${locator}    ${expected}
    ${items}=    Get WebElements    ${locator}
    ${texts}=    Create List
    FOR    ${item}    IN    @{items}
        ${text}=    Get Text    ${item}
        ${clean}=    Evaluate    ' '.join($text.split())
        Append To List    ${texts}    ${clean}
    END
    ${want}=    Evaluate    [' '.join(str(x).split()) for x in $expected]
    Should Be Equal    ${texts}    ${want}

# ================= opening the page =================
View And Apply Of Card Should Open Detail
    [Arguments]    ${index}    ${use_title_link}=${False}
    Go To Jobs Page
    Require Values    ${JOB_CARD}    ${CARD}[title]    ${CARD}[view_apply]
    ${title_loc}=    Card Child    ${JOB_CARD}    ${index}    ${CARD}[title]
    ${title}=    Get Text    ${title_loc}
    IF    ${use_title_link}
        ${link}=    Set Variable    ${title_loc}
    ELSE
        ${link}=    Card Child    ${JOB_CARD}    ${index}    ${CARD}[view_apply]
    END
    Click Element Safe    ${link}
    Wait Until Element Is Visible    ${DETAIL_H1}
    Location Should Be A Job Detail
    Element Text Should Match    ${DETAIL_H1}    ${title.strip()}    ignore_case=${False}

First Card Should Open Detail
    [Arguments]    ${use_title_link}=${False}
    Get Detail Urls
    View And Apply Of Card Should Open Detail    1    ${use_title_link}

Every Card Should Open Its Detail
    Require Values    ${JOB_CARD}
    Go To Jobs Page
    ${count}=    Get Element Count    ${JOB_CARD}
    Skip If    ${count} == 0    No job is shown on the Jobs page.
    ${end}=    Evaluate    ${count} + 1
    FOR    ${i}    IN RANGE    1    ${end}
        Go To Jobs Page
        ${selected}=    Card Is Selected    ${i}
        IF    not ${selected}    CONTINUE
        View And Apply Of Card Should Open Detail    ${i}
    END

Detail Page Should Open By Direct Url
    ${href}=    Detail Url Of Job    ${DEFAULT_DETAIL_JOB}
    Go To    about:blank
    Go To    ${href}
    Wait Until Element Is Visible    ${DETAIL_H1}
    Element Text Should Match    ${DETAIL_H1}    ${DEFAULT_DETAIL_JOB}    ignore_case=${False}

Detail Url With Trailing Slash Should Open
    ${href}=    Detail Url Of Job    ${DEFAULT_DETAIL_JOB}
    Go To    ${href}/
    Wait Until Element Is Visible    ${DETAIL_H1}
    Element Text Should Match    ${DETAIL_H1}    ${DEFAULT_DETAIL_JOB}    ignore_case=${False}

Browser Back Should Return To Jobs
    Go To Jobs Page
    Require Values    ${JOB_CARD}    ${CARD}[view_apply]
    ${link}=    Card Child    ${JOB_CARD}    1    ${CARD}[view_apply]
    Click Element Safe    ${link}
    Wait Until Element Is Visible    ${DETAIL_H1}
    Go Back
    Wait Until Keyword Succeeds    10s    1s    Location Should Be Jobs List

# ================= job not found =================
Unknown Job Should Show Not Found
    [Arguments]    ${job_id}
    Open Detail Page Of Job With Id    ${job_id}
    Wait Until Element Is Visible    ${NOT_FOUND_HEADING}
    Element Text Should Match    ${NOT_FOUND_HEADING}    ${NOT_FOUND_HEADING_TEXT}    ignore_case=${False}
    Page Should Not Contain Element    ${DETAIL_H1}

Not Found Page Title Should Be Correct
    Open Detail Page Of Job With Id    ${MISSING_JOB_ID}
    Wait Until Element Is Visible    ${NOT_FOUND_HEADING}
    Title Should Be    ${NOT_FOUND_TITLE}

Not Found Page Should Explain
    Open Detail Page Of Job With Id    ${MISSING_JOB_ID}
    Wait Until Element Is Visible    ${NOT_FOUND_HEADING}
    Element Text Should Match    ${NOT_FOUND_TEXT}    ${NOT_FOUND_BODY_TEXT}    ignore_case=${False}

Not Found Button Should Open Jobs List
    Open Detail Page Of Job With Id    ${MISSING_JOB_ID}
    Wait Until Element Is Visible    ${NOT_FOUND_BUTTON}
    Element Text Should Match    ${NOT_FOUND_BUTTON}    ${NOT_FOUND_BUTTON_TEXT}    ignore_case=${False}
    Click Element Safe    ${NOT_FOUND_BUTTON}
    Wait Until Keyword Succeeds    10s    1s    Location Should Be Jobs List

# ================= back link + breadcrumb =================
Back To Jobs Should Be Displayed
    Element Should Be Shown    ${BACK_TO_JOBS}
    Element Text Should Include    ${BACK_TO_JOBS}    ${BACK_TO_JOBS_TEXT}

Back To Jobs Should Open Jobs List
    Click Element Safe    ${BACK_TO_JOBS}
    Wait Until Keyword Succeeds    10s    1s    Location Should Be Jobs List

Breadcrumb Should Show Path
    Element Should Be Shown    ${BREADCRUMB}
    ${items}=    Get WebElements    ${BREADCRUMB_ITEMS}
    ${texts}=    Create List
    FOR    ${item}    IN    @{items}
        ${text}=    Get Text    ${item}
        ${clean}=    Evaluate    ' '.join($text.split())
        Append To List    ${texts}    ${clean}
    END
    Should Be Equal    ${texts}    ${BREADCRUMB_TEXTS}

Breadcrumb Last Item Should Be Current Page
    Element Text Should Match    ${BREADCRUMB_CURRENT}    ${BREADCRUMB_TEXTS}[-1]    ignore_case=${False}
    Page Should Not Contain Element    ${BREADCRUMB_CURRENT_LINK}

Breadcrumb Jobs Link Should Open Jobs List
    Click Element Safe    ${BREADCRUMB_JOBS}
    Wait Until Keyword Succeeds    10s    1s    Location Should Be Jobs List

Breadcrumb Careers Link Should Open Careers Home
    Click Element Safe    ${BREADCRUMB_CAREERS}
    Wait Until Keyword Succeeds    10s    1s    Location Should Be Careers Home

# ================= header consistency with the card =================
Detail Header Should Match Its Card
    [Documentation]    Type, Urgent, deadline and department on the detail page equal the card on the Jobs page.
    Require Real Detail Data
    Go To Jobs Page
    ${count}=    Get Element Count    ${JOB_CARD}
    ${end}=    Evaluate    ${count} + 1
    FOR    ${i}    IN RANGE    1    ${end}
        Go To Jobs Page
        ${selected}=    Card Is Selected    ${i}
        IF    not ${selected}    CONTINUE
        ${title_loc}=    Card Child    ${JOB_CARD}    ${i}    ${CARD}[title]
        ${title}=    Get Text    ${title_loc}
        ${href}=    Get Element Attribute    ${title_loc}    href
        ${type_loc}=    Card Child    ${JOB_CARD}    ${i}    ${CARD}[type_badge]
        ${card_type}=    Get Text    ${type_loc}
        ${dept_loc}=    Card Child    ${JOB_CARD}    ${i}    ${CARD}[department]
        ${card_dept}=    Get Text    ${dept_loc}
        ${urgent_loc}=    Card Child    ${JOB_CARD}    ${i}    ${CARD}[urgent_badge]
        ${card_urgent}=    Get Element Count    ${urgent_loc}
        ${due_loc}=    Card Child    ${JOB_CARD}    ${i}    ${CARD}[deadline]
        ${card_due_count}=    Get Element Count    ${due_loc}
        ${card_due}=    Set Variable    ${EMPTY}
        IF    ${card_due_count} > 0
            ${card_due}=    Get Text    ${due_loc}
        END
        Go To    ${href}
        Wait Until Element Is Visible    ${DETAIL_H1}
        Element Text Should Match    ${DETAIL_TYPE_BADGE}    ${card_type.strip()}    ignore_case=${False}
        Detail Info Should Be    department    ${card_dept.strip()}
        ${detail_urgent}=    Get Element Count    ${DETAIL_URGENT}
        Should Be Equal As Integers    ${detail_urgent}    ${card_urgent}    Urgent badge differs for ${title}
        ${detail_due_count}=    Get Element Count    ${DETAIL_DEADLINE}
        Should Be Equal As Integers    ${detail_due_count}    ${card_due_count}    Deadline differs for ${title}
        IF    ${card_due_count} > 0
            Element Text Should Match    ${DETAIL_DEADLINE}    ${card_due.strip()}    ignore_case=${False}
        END
    END

Description Should Match Its Card
    Require Real Detail Data
    Go To Jobs Page
    ${count}=    Get Element Count    ${JOB_CARD}
    ${end}=    Evaluate    ${count} + 1
    FOR    ${i}    IN RANGE    1    ${end}
        Go To Jobs Page
        ${selected}=    Card Is Selected    ${i}
        IF    not ${selected}    CONTINUE
        ${title_loc}=    Card Child    ${JOB_CARD}    ${i}    ${CARD}[title]
        ${href}=    Get Element Attribute    ${title_loc}    href
        ${desc_loc}=    Card Child    ${JOB_CARD}    ${i}    ${CARD}[description]
        ${card_desc}=    Get Text    ${desc_loc}
        Go To    ${href}
        Wait Until Element Is Visible    ${DETAIL_H1}
        Element Text Should Match    ${ABOUT_TEXT}    ${card_desc.strip()}    ignore_case=${False}
    END

# ================= sections that open and close =================
Sections Should Be Displayed
    FOR    ${title}    IN    @{SECTION_TITLES}
        ${button}=    Format Locator    ${SECTION_BUTTON}    title=${title}
        Element Should Be Shown    ${button}
    END

Section State Should Be
    [Arguments]    ${title}    ${expanded}
    ${button}=    Format Locator    ${SECTION_BUTTON}    title=${title}
    ${panel}=    Format Locator    ${SECTION_PANEL}    title=${title}
    Element Attribute Value Should Be    ${button}    aria-expanded    ${expanded}
    IF    '${expanded}' == 'true'
        Wait Until Element Is Visible    ${panel}
    ELSE
        Wait Until Element Is Not Visible    ${panel}
    END

All Sections Should Start Expanded
    FOR    ${title}    IN    @{SECTION_TITLES}
        Section State Should Be    ${title}    true
    END

Toggle Section
    [Arguments]    ${title}
    ${button}=    Format Locator    ${SECTION_BUTTON}    title=${title}
    Click Element Safe    ${button}

Section Should Collapse And Expand
    [Arguments]    ${title}
    Section State Should Be    ${title}    true
    Toggle Section    ${title}
    Section State Should Be    ${title}    false
    Toggle Section    ${title}
    Section State Should Be    ${title}    true

Collapsing One Section Should Not Affect Others
    FOR    ${title}    IN    @{SECTION_TITLES}
        Open Default Detail Page
        Toggle Section    ${title}
        FOR    ${other}    IN    @{SECTION_TITLES}
            IF    '${other}' == '${title}'
                Section State Should Be    ${other}    false
            ELSE
                Section State Should Be    ${other}    true
            END
        END
    END

Collapse All Then Expand All Should Restore Content
    ${before}=    Get Text    ${DETAIL_ARTICLE}
    FOR    ${title}    IN    @{SECTION_TITLES}
        Toggle Section    ${title}
    END
    FOR    ${title}    IN    @{SECTION_TITLES}
        Section State Should Be    ${title}    false
    END
    FOR    ${title}    IN    @{SECTION_TITLES}
        Toggle Section    ${title}
    END
    FOR    ${title}    IN    @{SECTION_TITLES}
        Section State Should Be    ${title}    true
    END
    ${after}=    Get Text    ${DETAIL_ARTICLE}
    Should Be Equal    ${after}    ${before}

Section Should Toggle With Key
    [Arguments]    ${key}
    FOR    ${title}    IN    @{SECTION_TITLES}
        ${button}=    Format Locator    ${SECTION_BUTTON}    title=${title}
        Scroll Element Into View    ${button}
        Set Focus To Element    ${button}
        Press Keys    None    ${key}
        Section State Should Be    ${title}    false
        Press Keys    None    ${key}
        Section State Should Be    ${title}    true
    END

Sections Should Be Expanded Again After Reload
    Toggle Section    ${SECTION_TITLES}[0]
    Section State Should Be    ${SECTION_TITLES}[0]    false
    Reload Page
    Wait Until Element Is Visible    ${DETAIL_H1}
    All Sections Should Start Expanded

# ================= contact + location =================
Contact Names Should Be Correct
    Element Text Should Match    ${CONTACT_HEADING}    ${CONTACT_HEADING_TEXT}    ignore_case=${False}
    FOR    ${line}    IN    @{CONTACT_NAME_LINES}
        Element Text Should Include    ${CONTACT_ADDRESS}    ${line}
    END

Contact Address Should Be Correct
    FOR    ${line}    IN    @{CONTACT_ADDRESS_LINES}
        Element Text Should Include    ${CONTACT_ADDRESS}    ${line}
    END

Contact Phone Should Be Correct And Clickable
    Element Text Should Match    ${CONTACT_PHONE_LINK}    ${CONTACT_PHONE_TEXT}    ignore_case=${False}
    ${href}=    Get Element Attribute    ${CONTACT_PHONE_LINK}    href
    Should Be Equal    ${href}    ${CONTACT_PHONE_HREF}

Map Should Be Displayed For The Job
    Element Should Be Shown    ${MAP_FRAME}
    ${title}=    Get Element Attribute    ${MAP_FRAME}    title
    Should Contain    ${title}    ${DEFAULT_DETAIL_JOB}
    ${size}=    Get Element Size    ${MAP_FRAME}
    Should Be True    ${size}[1] > 100    Map is too small: ${size}

Map Should Come From Google Maps
    ${src}=    Get Element Attribute    ${MAP_FRAME}    src
    Should Start With    ${src}    ${MAP_SRC_PREFIX}

# ================= side panel =================
Apply Message Should Be Displayed
    Element Text Should Match    ${APPLY_HEADING}    ${APPLY_HEADING_TEXT}    ignore_case=${False}
    Element Text Should Match    ${APPLY_TEXT}    ${APPLY_BODY_TEXT}    ignore_case=${False}

Apply Now Should Link To Apply Form
    Element Should Be Shown    ${APPLY_NOW}
    Element Text Should Match    ${APPLY_NOW}    ${APPLY_NOW_TEXT}    ignore_case=${False}
    ${url}=    Get Location
    ${expected}=    Evaluate    $url.rstrip('/') + '/apply'
    ${href}=    Get Element Attribute    ${APPLY_NOW}    href
    Should Be Equal    ${href}    ${expected}

Apply Form Should Open For Job
    [Arguments]    ${title}
    Click Element Safe    ${APPLY_NOW}
    Wait Until Location Contains    /apply
    Wait Until Element Is Visible    ${APPLY_PAGE_HEADING}
    ${expected_title}=    Evaluate    $APPLY_PAGE_TITLE.format(title=$title)
    Title Should Be    ${expected_title}
    ${expected_text}=    Evaluate    $APPLY_PAGE_JOB_TEXT.format(title=$title)
    Page Should Contain    ${expected_text}

Apply Now Should Open Form Of This Job
    Apply Form Should Open For Job    ${DEFAULT_DETAIL_JOB}

Apply Now Of Every Job Should Open Its Own Form
    Require Real Detail Data
    ${urls}=    Get Detail Urls
    FOR    ${title}    ${href}    IN    &{urls}
        Go To    ${href}
        Wait Until Element Is Visible    ${DETAIL_H1}
        Apply Form Should Open For Job    ${title}
    END

Apply Form Back Link Should Return To Detail
    ${before}=    Get Location
    Click Element Safe    ${APPLY_NOW}
    Wait Until Location Contains    /apply
    Wait Until Element Is Visible    ${APPLY_PAGE_BACK}
    Element Text Should Match    ${APPLY_PAGE_BACK}    ${APPLY_PAGE_BACK_TEXT}    ignore_case=${False}
    Click Element Safe    ${APPLY_PAGE_BACK}
    Wait Until Element Is Visible    ${DETAIL_H1}
    ${after}=    Get Location
    Should Be Equal    ${after.rstrip('/')}    ${before.rstrip('/')}

Share Job Button Should Be Displayed
    Element Should Be Shown    ${SHARE_JOB}
    Element Text Should Include    ${SHARE_JOB}    ${SHARE_JOB_TEXT}

Share Job Click Should Keep The Page
    ${before}=    Get Location
    Click Element Safe    ${SHARE_JOB}
    Sleep    1s
    ${after}=    Get Location
    Should Be Equal    ${after}    ${before}
    Element Should Be Visible    ${SHARE_JOB}
    Element Should Be Enabled    ${SHARE_JOB}
    Element Should Be Visible    ${DETAIL_H1}

Hiring Process Should List All Steps In Order
    Element Text Should Match    ${HIRING_HEADING}    ${HIRING_HEADING_TEXT}    ignore_case=${False}
    ${items}=    Get WebElements    ${HIRING_STEPS}
    ${texts}=    Create List
    FOR    ${item}    IN    @{items}
        ${text}=    Get Text    ${item}
        ${squeezed}=    Evaluate    ''.join($text.split())
        Append To List    ${texts}    ${squeezed}
    END
    ${want}=    Evaluate    [''.join((n + s).split()) for n, s in $HIRING_STEPS_EXPECTED]
    Should Be Equal    ${texts}    ${want}

Hiring Process Numbers Should Be In Order
    ${items}=    Get WebElements    ${HIRING_STEP_NUMBERS}
    ${texts}=    Create List
    FOR    ${item}    IN    @{items}
        ${text}=    Get Text    ${item}
        Append To List    ${texts}    ${text.strip()}
    END
    ${want}=    Evaluate    [n for n, s in $HIRING_STEPS_EXPECTED]
    Should Be Equal    ${texts}    ${want}

# ================= footer on the detail page (same keywords as the Jobs page) =================
Footer Open Positions Link Should Open Jobs List
    Footer Link Should Navigate    open_positions
    Wait Until Keyword Succeeds    10s    1s    Location Should Be Jobs List

# ================= SEO data =================
Get Meta Description
    ${meta}=    Execute Javascript    var m = document.querySelector('meta[name="description"]'); return m ? m.content : '';
    RETURN    ${meta}

Get Job Posting Data
    ${raw}=    Execute Javascript    var s = document.querySelector('script[type="application/ld+json"]'); return s ? s.textContent : '';
    Should Not Be Empty    ${raw}    The page has no JobPosting data (application/ld+json).
    ${data}=    Evaluate    __import__('json').loads($raw)
    RETURN    ${data}

Job Posting Should Use The Real Website Address
    ${posting}=    Get Job Posting Data
    ${bad}=    Create List
    ${candidates}=    Create List    ${posting}[url]    ${posting}[hiringOrganization][sameAs]
    FOR    ${address}    IN    @{candidates}
        FOR    ${word}    IN    @{BAD_ORIGINS}
            IF    $word in $address    Append To List    ${bad}    ${address}
        END
    END
    Should Be Empty    ${bad}    JobPosting uses a development address instead of the website: ${bad}

# ================= layout + keyboard =================
Side Panel Should Be On The Right On Desktop
    Set Window Size    1440    1000
    Reload Page
    Wait Until Element Is Visible    ${DETAIL_H1}
    Element Should Be Visible    ${ASIDE}
    ${ax}=    Get Horizontal Position    ${DETAIL_ARTICLE}
    ${aw}=    Get Element Size    ${DETAIL_ARTICLE}
    ${sx}=    Get Horizontal Position    ${ASIDE}
    ${right_edge}=    Evaluate    int($ax) + int($aw[0])
    Should Be True    ${sx} >= ${right_edge} - 1    Side panel (x=${sx}) overlaps the content (right edge ${right_edge}).

Tab Key Should Visit The Page In Order
    Reload Page
    Wait Until Element Is Visible    ${DETAIL_H1}
    ${seen}=    Create List
    FOR    ${n}    IN RANGE    20
        Press Keys    None    TAB
        ${label}=    Execute Javascript    var e = document.activeElement; return ((e && (e.innerText || e.getAttribute('aria-label'))) || (e ? e.tagName : '')).trim().slice(0, 40);
        Append To List    ${seen}    ${label}
    END
    ${expected}=    Create List    ${BACK_TO_JOBS_TEXT}    Careers    Jobs    @{SECTION_TITLES}    ${CONTACT_PHONE_TEXT}    ${APPLY_NOW_TEXT}    ${SHARE_JOB_TEXT}
    ${ok}=    Items Appear In Order    ${seen}    ${expected}
    Should Be True    ${ok}    Tab order is not as expected. Visited: ${seen}
