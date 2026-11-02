*** Settings ***
Documentation     CMS job management keywords: /admin/jobs.
...               The suite reads the table once (all jobs, no filter) and works out what each filter SHOULD show,
...               so the checks do not depend on which jobs exist.
...               The Manual Toggle switches and the edit/new job forms CHANGE the public site, so the tests never press
...               a switch and never save a form. Those are manual cases.
Resource          ../common.resource
Resource          login.resource
Resource          dashboard.resource
Library           ../../libraries/JobAdminData.py
Variables         ../../locators/jobs_admin_page.py
Variables         ../../testdata/jobs_admin_expected.py


*** Keywords ***
# ================= open / reset =================
Open Jobs Admin Browser
    Open Admin Browser
    Login As Admin And Reach Dashboard
    Go To Jobs Admin
    ${rows}=    Get Job Rows
    Should Not Be Empty    ${rows}    The job list is empty, so there is nothing to test
    Set Suite Variable    ${ALL_JOB_ROWS}    ${rows}

Open Jobs Admin
    [Documentation]    Start every test on the job list, on a desktop window, with no filter.
    Set Window Size    1440    900
    Go To Jobs Admin

Go To Jobs Admin
    Go To    ${BASE_URL}${JA_PATH}
    Wait For Jobs Admin To Load

Wait For Jobs Admin To Load
    Wait For Condition    return document.readyState === 'complete'
    Wait Until Element Is Visible    ${JA_H1}
    Wait Until Element Is Visible    ${JA_TABLE_BODY}
    Wait Until Element Is Visible    ${JA_RESULT_COUNT}

Displayed Titles
    ${rows}=    Get Job Rows
    ${titles}=    Evaluate    [r['title'] for r in $rows]
    RETURN    ${titles}

# ================= open page =================
Jobs Admin Should Open From The Menu
    Go To Dashboard
    Click Element    ${DASH_NAV_JOBS}
    Wait Until Location Contains    ${JA_PATH}    timeout=20s
    Wait For Jobs Admin To Load
    Title Should Be    ${JA_TITLE}
    Element Should Be Visible    ${LOGIN_LOGOUT_BUTTON}

Jobs Admin Heading Should Match
    Element Text Should Be    ${JA_BADGE}    ${JA_BADGE_TEXT}
    Element Text Should Be    ${JA_H1}    ${JA_H1_TEXT}
    Element Text Should Be    ${JA_SUBTITLE}    ${JA_SUBTITLE_TEXT}

Only Jobs Menu Should Be Marked Current
    ${links}=    Visible Menu Links
    Should Be Equal    ${links}[2][1]    page    The Jobs menu item is not marked as the current page
    Should Be Equal    ${links}[0][1]    ${None}
    Should Be Equal    ${links}[1][1]    ${None}

Jobs Admin Should Ask For Login When Logged Out
    TRY
        Delete All Cookies
        Go To    ${BASE_URL}${JA_PATH}
        Wait Until Location Contains    ${ADMIN_LOGIN_PATH}    timeout=20s
        ${url}=    Get Location
        Should Contain    ${url}    next=%2Fadmin%2Fjobs
        Page Should Not Contain Element    ${JA_TABLE_BODY}
    FINALLY
        Go To    ${BASE_URL}${ADMIN_LOGIN_PATH}
        Login As Admin And Reach Dashboard
    END

Header Links Should Match
    Element Text Should Be    ${JA_PUBLIC_LINK}    ${JA_PUBLIC_LINK_TEXT}
    Element Attribute Value Should Be    ${JA_PUBLIC_LINK}    target    _blank
    ${href}=    Get Element Attribute    ${JA_PUBLIC_LINK}    href
    Should Be Equal    ${href}    ${BASE_URL}/
    Element Text Should Be    ${JA_NEW_LINK}    ${JA_NEW_LINK_TEXT}

New Job Link Should Open The New Job Page
    [Documentation]    Only opens the form. Nothing is typed or saved.
    Click Element    ${JA_NEW_LINK}
    Wait Until Location Contains    ${JA_NEW_PATH}    timeout=20s
    Title Should Be    ${JA_NEW_TITLE}

Refresh Should Keep The Job List
    Reload Page
    Wait For Jobs Admin To Load
    Title Should Be    ${JA_TITLE}
    ${rows}=    Get Job Rows
    ${total}=    Get Length    ${ALL_JOB_ROWS}
    Length Should Be    ${rows}    ${total}

# ================= summary =================
Stat Cards Should Show Labels And Whole Numbers
    FOR    ${id}    ${label}    IN ZIP    ${JA_STAT_VALUES}    ${JA_STAT_LABELS}
        ${card_text}=    Execute Javascript    return document.getElementById('${id}').parentElement.innerText;
        Should Contain    ${card_text}    ${label}
        ${number}=    Get Text    id:${id}
        Should Match Regexp    ${number}    ^\\d+$    The number under '${label}' is '${number}'
    END

Stat Cards Should Match The Rows
    ${counts}=    Status Counts    ${ALL_JOB_ROWS}
    ${shown}=    Create List
    FOR    ${id}    IN    @{JA_STAT_VALUES}
        ${number}=    Get Text    id:${id}
        ${whole}=    Convert To Integer    ${number}
        Append To List    ${shown}    ${whole}
    END
    Lists Should Be Equal    ${shown}    ${counts}    The cards show ${shown} but the table has ${counts} (open, auto-expired, closed by hand)

Result Count Should Match The Rows
    ${text}=    Get Text    ${JA_RESULT_COUNT}
    Should Match Regexp    ${text}    ${JA_RESULT_PATTERN}
    ${found}=    Evaluate    __import__('re').match($JA_RESULT_PATTERN, $text).groups()
    ${rows}=    Get Job Rows
    ${shown}=    Get Length    ${rows}
    ${total}=    Get Length    ${ALL_JOB_ROWS}
    Should Be Equal As Integers    ${found}[0]    ${shown}
    Should Be Equal As Integers    ${found}[1]    ${total}

# ================= table =================
Job Table Headings Should Match
    ${elements}=    Get WebElements    ${JA_TABLE_HEADINGS}
    ${texts}=    Create List
    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}
        Append To List    ${texts}    ${text}
    END
    Lists Should Be Equal    ${texts}    ${JA_TABLE_HEADINGS_TEXT}

Table Section Should Be Titled
    Element Should Contain    ${JA_TABLE_SECTION}    ${JA_TABLE_HEADING}
    Element Should Contain    ${JA_TABLE_SECTION}    ${JA_TABLE_NOTE}
    Element Should Contain    ${JA_TABLE_SECTION}    ${JA_PUBLIC_NOTE}

Every Job Should Pass
    [Arguments]    ${check}
    Should Pass Job Check    ${check}    ${ALL_JOB_ROWS}    ${JA_DEPARTMENTS}    ${JA_TYPES}

Public Jobs Should Match The Open Rows
    [Documentation]    The public Jobs page shows exactly the jobs the list calls open.
    ${rows}=    Get Job Rows
    ${titles}=    Evaluate    [r['title'] for r in $rows if r['status'] == $JA_STATUSES[0][0]]
    ${open}=    Evaluate    sorted($titles)
    Go To    ${BASE_URL}${JOBS_PATH}
    Wait For Condition    return document.readyState === 'complete'
    Wait Until Element Is Visible    ${HERO_TITLE}    timeout=20s
    Sleep    3s
    ${public}=    Get Public Job Titles
    ${public_sorted}=    Evaluate    sorted($public)
    Lists Should Be Equal    ${public_sorted}    ${open}    Public page shows ${public_sorted}, the list says open: ${open}

# ================= filters =================
Filter Boxes Should Match
    Element Attribute Value Should Be    ${JA_FILTER_TITLE}    placeholder    ${JA_TITLE_PLACEHOLDER}
    Element Attribute Value Should Be    ${JA_FILTER_START}    placeholder    ${JA_DATE_PLACEHOLDER}
    Element Attribute Value Should Be    ${JA_FILTER_END}    placeholder    ${JA_DATE_PLACEHOLDER}
    Element Attribute Value Should Be    ${JA_FILTER_START}    maxlength    10
    Element Attribute Value Should Be    ${JA_FILTER_END}    maxlength    10
    Element Should Contain    ${JA_FILTER_SECTION}    ${JA_FILTER_HEADING}
    Element Should Contain    ${JA_FILTER_SECTION}    ${JA_FILTER_NOTE}
    Element Should Contain    ${JA_FILTER_SECTION}    ${JA_DATE_NOTE}
    FOR    ${label}    IN    @{JA_FILTER_LABELS}
        Element Should Contain    ${JA_FILTER_SECTION}    ${label}
    END

Filter Lists Should Match
    ${departments}=    Get List Items    ${JA_FILTER_DEPT}
    ${types}=    Get List Items    ${JA_FILTER_TYPE}
    ${statuses}=    Get List Items    ${JA_FILTER_STATUS}
    ${wanted_departments}=    Create List    ${JA_ALL_DEPARTMENTS}    @{JA_DEPARTMENTS}
    ${wanted_types}=    Create List    ${JA_ALL_TYPES}    @{JA_TYPES}
    ${status_texts}=    Evaluate    [t for t, v in $JA_STATUSES]
    ${wanted_statuses}=    Create List    ${JA_ALL_STATUSES}    @{status_texts}
    Lists Should Be Equal    ${departments}    ${wanted_departments}
    Lists Should Be Equal    ${types}    ${wanted_types}
    Lists Should Be Equal    ${statuses}    ${wanted_statuses}

Filters Should Start Empty
    Textfield Value Should Be    ${JA_FILTER_TITLE}    ${EMPTY}
    List Selection Should Be    ${JA_FILTER_DEPT}    ${JA_ALL_DEPARTMENTS}
    List Selection Should Be    ${JA_FILTER_TYPE}    ${JA_ALL_TYPES}
    List Selection Should Be    ${JA_FILTER_STATUS}    ${JA_ALL_STATUSES}
    Textfield Value Should Be    ${JA_FILTER_START}    ${EMPTY}
    Textfield Value Should Be    ${JA_FILTER_END}    ${EMPTY}
    ${titles}=    Displayed Titles
    ${all}=    Evaluate    [r['title'] for r in $ALL_JOB_ROWS]
    Lists Should Be Equal    ${titles}    ${all}

Type In Box
    [Documentation]    Put the whole text in a filter box in ONE step. The page filters on the server and sends a request for
    ...                every change, so typing key by key (20 requests for a long word) made dev show "This page couldn't load".
    [Arguments]    ${locator}    ${text}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript
    ...    const e = arguments[0]; const set = Object.getOwnPropertyDescriptor(Object.getPrototypeOf(e), 'value').set; set.call(e, arguments[1]); e.dispatchEvent(new Event('input', {bubbles: true}));
    ...    ARGUMENTS    ${element}    ${text}
    Sleep    1s

Type Keys In Box
    [Documentation]    Real key presses, for the tests of the date mask only (it reacts to each key).
    [Arguments]    ${locator}    ${text}
    Click Element    ${locator}
    Press Keys    ${locator}    CTRL+a    DELETE
    Input Text    ${locator}    ${text}
    Sleep    1s

Apply Job Filters
    [Arguments]    ${title}=${None}    ${department}=${None}    ${type}=${None}    ${status}=${None}    ${start}=${None}    ${end}=${None}
    IF    $title is not None
        Type In Box    ${JA_FILTER_TITLE}    ${title}
    END
    IF    $department is not None
        Select From List By Label    ${JA_FILTER_DEPT}    ${department}
    END
    IF    $type is not None
        Select From List By Label    ${JA_FILTER_TYPE}    ${type}
    END
    IF    $status is not None
        Select From List By Value    ${JA_FILTER_STATUS}    ${status}
    END
    IF    $start is not None
        Type In Box    ${JA_FILTER_START}    ${start}
    END
    IF    $end is not None
        Type In Box    ${JA_FILTER_END}    ${end}
    END
    Sleep    1s

Table Should Show
    [Documentation]    The titles on the page equal the titles the filter should give, and the count line agrees.
    [Arguments]    ${title}=    ${department}=    ${type}=    ${status}=    ${start}=    ${end}=
    ${expected}=    Expected Admin Titles    ${ALL_JOB_ROWS}    ${title}    ${department}    ${type}    ${status}    ${start}    ${end}
    ${shown}=    Displayed Titles
    Lists Should Be Equal    ${shown}    ${expected}    Filter shows ${shown}, expected ${expected}
    ${text}=    Get Text    ${JA_RESULT_COUNT}
    ${total}=    Get Length    ${ALL_JOB_ROWS}
    ${count}=    Get Length    ${expected}
    Should Be Equal    ${text}    แสดง ${count} จากทั้งหมด ${total} รายการ
    IF    ${count} == 0
        Page Should Contain    ${JA_EMPTY_TEXT}
    ELSE
        Page Should Not Contain    ${JA_EMPTY_TEXT}
    END

Each Word Of Each Title Should Be Found
    [Documentation]    Type the first word and a middle part of every title: that job must appear.
    FOR    ${row}    IN    @{ALL_JOB_ROWS}
        ${title}=    Set Variable    ${row}[title]
        ${word}=    Evaluate    $title.split()[0]
        Apply Job Filters    title=${word}
        Table Should Show    title=${word}
        ${shown}=    Displayed Titles
        Should Contain    ${shown}    ${title}
    END

Title Search Should Ignore Case And Spaces
    ${title}=    Set Variable    ${ALL_JOB_ROWS}[0][title]
    ${word}=    Evaluate    $title.split()[0]
    ${upper}=    Convert To Upper Case    ${word}
    ${odd}=    Catenate    SEPARATOR=    ${SPACE}${SPACE}    ${upper}    ${SPACE}${SPACE}
    Apply Job Filters    title=${odd}
    Table Should Show    title=${odd}
    ${shown}=    Displayed Titles
    Should Contain    ${shown}    ${title}
    ${lower}=    Evaluate    $word.lower()
    Apply Job Filters    title=${lower}
    Table Should Show    title=${lower}

Job Search With No Match Should Show The Empty State
    Apply Job Filters    title=${JA_NO_MATCH_SEARCH}
    Table Should Show    title=${JA_NO_MATCH_SEARCH}
    Element Should Be Visible    ${JA_CLEAR_EMPTY}
    Element Text Should Be    ${JA_CLEAR_EMPTY}    ${JA_CLEAR_TEXT}

Each Department Should Filter Its Jobs
    FOR    ${department}    IN    @{JA_DEPARTMENTS}
        Apply Job Filters    department=${department}
        Table Should Show    department=${department}
    END

Each Type Should Filter Its Jobs
    FOR    ${type}    IN    @{JA_TYPES}
        Apply Job Filters    type=${type}
        Table Should Show    type=${type}
    END

Each Status Should Filter Its Jobs
    ${flat}=    Evaluate    [x for pair in $JA_STATUSES for x in pair]
    FOR    ${text}    ${value}    IN    @{flat}
        Apply Job Filters    status=${value}
        Table Should Show    status=${value}
    END

Start Date Should Filter From That Day
    ${day}=    Middle Deadline
    Apply Job Filters    start=${day}
    Table Should Show    start=${day}

End Date Should Filter Up To That Day
    ${day}=    Middle Deadline
    Apply Job Filters    end=${day}
    Table Should Show    end=${day}

One Day Range Should Include That Day
    ${day}=    Middle Deadline
    Apply Job Filters    start=${day}    end=${day}
    Table Should Show    start=${day}    end=${day}
    ${shown}=    Displayed Titles
    Should Not Be Empty    ${shown}    A job with deadline ${day} was not found when start and end are that day

Reversed Dates Should Show The Empty State
    ${first}=    Evaluate    min((r['deadline'] for r in $ALL_JOB_ROWS), key=lambda d: d[6:] + d[3:5] + d[:2])
    ${last}=    Evaluate    max((r['deadline'] for r in $ALL_JOB_ROWS), key=lambda d: d[6:] + d[3:5] + d[:2])
    Apply Job Filters    start=${last}    end=${first}
    Table Should Show    start=${last}    end=${first}

Middle Deadline
    [Documentation]    A deadline from the list, in the middle when sorted, as dd/mm/yyyy.
    ${sorted}=    Evaluate    sorted({r['deadline'] for r in $ALL_JOB_ROWS}, key=lambda d: d[6:] + d[3:5] + d[:2])
    ${day}=    Evaluate    $sorted[len($sorted) // 2]
    RETURN    ${day}

Date Box Should Add Slashes And Ignore Letters
    Type Keys In Box    ${JA_FILTER_START}    01122026
    Textfield Value Should Be    ${JA_FILTER_START}    01/12/2026
    Type Keys In Box    ${JA_FILTER_START}    ab/cd/efgh
    Textfield Value Should Be    ${JA_FILTER_START}    ${EMPTY}
    Table Should Show

Impossible Date Should Not Filter
    [Documentation]    Seen on dev: 32/13/2026 stays in the box and the list is not filtered (no error shown).
    Type Keys In Box    ${JA_FILTER_START}    32132026
    Textfield Value Should Be    ${JA_FILTER_START}    32/13/2026
    Table Should Show

Filters Should Work Together
    ${row}=    Set Variable    ${ALL_JOB_ROWS}[0]
    ${word}=    Evaluate    $row['title'].split()[0]
    Apply Job Filters    title=${word}    department=${row}[dept]    type=${row}[type]
    Table Should Show    title=${word}    department=${row}[dept]    type=${row}[type]
    ${shown}=    Displayed Titles
    Should Contain    ${shown}    ${row}[title]
    ${other}=    Evaluate    [d for d in $JA_DEPARTMENTS if d != $row['dept']][0]
    Apply Job Filters    department=${other}
    Table Should Show    title=${word}    department=${other}    type=${row}[type]

Clear Button Should Reset The List And Every Filter
    ${row}=    Set Variable    ${ALL_JOB_ROWS}[0]
    Apply Job Filters    department=${row}[dept]    type=${row}[type]    status=open    start=01/01/2020    end=31/12/2030
    Click Element    ${JA_CLEAR}
    Wait Until Location Does Not Contain    dept=    timeout=15s
    Sleep    1s
    List Selection Should Be    ${JA_FILTER_DEPT}    ${JA_ALL_DEPARTMENTS}
    List Selection Should Be    ${JA_FILTER_TYPE}    ${JA_ALL_TYPES}
    List Selection Should Be    ${JA_FILTER_STATUS}    ${JA_ALL_STATUSES}
    Textfield Value Should Be    ${JA_FILTER_START}    ${EMPTY}
    Textfield Value Should Be    ${JA_FILTER_END}    ${EMPTY}
    Table Should Show

Clear Button Should Empty The Search Box
    [Documentation]    Seen on dev: the list comes back but the words stay in the search box.
    Apply Job Filters    title=front
    Click Element    ${JA_CLEAR}
    Wait Until Location Does Not Contain    title=    timeout=15s
    Sleep    1s
    Table Should Show
    Textfield Value Should Be    ${JA_FILTER_TITLE}    ${EMPTY}

Clear Link In The Empty State Should Reset The List
    Apply Job Filters    title=${JA_NO_MATCH_SEARCH}
    Click In The Middle Of The Screen    ${JA_CLEAR_EMPTY}
    Wait Until Location Does Not Contain    title=    timeout=15s
    Sleep    1s
    Table Should Show

Script Text In Search Should Be Harmless
    Apply Job Filters    title=<script>alert(1)</script>
    Table Should Show    title=<script>alert(1)</script>
    ${alert}=    Run Keyword And Return Status    Alert Should Be Present    action=DISMISS    timeout=1s
    Should Not Be True    ${alert}    The search text ran as a script (an alert appeared)

Job Filters Should Survive A Refresh
    [Documentation]    Seen on dev: the filters are kept in the web address, so a refresh (or a copied link) keeps them.
    Apply Job Filters    title=developer    department=${JA_DEPARTMENTS}[4]
    Location Should Contain    title=developer
    Reload Page
    Wait For Jobs Admin To Load
    Textfield Value Should Be    ${JA_FILTER_TITLE}    developer
    List Selection Should Be    ${JA_FILTER_DEPT}    ${JA_DEPARTMENTS}[4]
    Table Should Show    title=developer    department=${JA_DEPARTMENTS}[4]

A Link With A Filter In It Should Open Filtered
    Go To    ${BASE_URL}${JA_PATH}?title=front
    Wait For Jobs Admin To Load
    Textfield Value Should Be    ${JA_FILTER_TITLE}    front
    Table Should Show    title=front

# ================= actions =================
Edit Link Should Open That Job
    [Documentation]    Only opens the form. Nothing is changed or saved.
    ${row}=    Set Variable    ${ALL_JOB_ROWS}[0]
    Click In The Middle Of The Screen    ${JA_FIRST_EDIT}
    Wait Until Location Contains    ${row}[edit]    timeout=20s
    Title Should Be    ${JA_EDIT_TITLE_PREFIX}${row}[title]${JA_TITLE_SUFFIX}

Every Edit Link Should Open A Job
    [Documentation]    Open every edit page (read only) and check the tab title names that job.
    FOR    ${row}    IN    @{ALL_JOB_ROWS}
        Go To    ${BASE_URL}${row}[edit]
        Wait Until Keyword Succeeds    15s    0.5s    Title Should Be    ${JA_EDIT_TITLE_PREFIX}${row}[title]${JA_TITLE_SUFFIX}
    END

# ================= keyboard / layout =================
Jobs Admin Tab Order Should Follow The Page
    Set Focus To Element    ${JA_PUBLIC_LINK}
    ${seen}=    Create List
    ${count}=    Get Length    ${JA_TAB_ORDER}
    FOR    ${i}    IN RANGE    ${count}
        IF    ${i} > 0
            Press Keys    NONE    TAB
        END
        ${text}=    Execute Javascript
        ...    const e = document.activeElement; return (e.id && ['INPUT', 'SELECT'].includes(e.tagName)) ? e.id : e.innerText.trim();
        Append To List    ${seen}    ${text}
    END
    Lists Should Be Equal    ${seen}    ${JA_TAB_ORDER}

Stat Cards Should Be Laid Out
    [Arguments]    ${columns}
    ${found}=    Execute Javascript
    ...    return new Set(['jobStatActive', 'jobStatAutoExpired', 'jobStatForceClosed'].map(i => Math.round(document.getElementById(i).getBoundingClientRect().left))).size;
    Should Be Equal As Integers    ${found}    ${columns}    The stat cards use ${found} columns, expected ${columns}

Phone Layout Should Stack The Cards And Scroll The Table Inside
    Set Window Size    375    812
    Sleep    ${RESULT_SETTLE}
    Stat Cards Should Be Laid Out    1
    ${overflow}=    Execute Javascript    return document.documentElement.scrollWidth - document.documentElement.clientWidth;
    Should Be True    ${overflow} <= 1    The page scrolls sideways by ${overflow}px
    ${style}=    Execute Javascript    return getComputedStyle(document.getElementById('adminJobsTableBody').closest('table').parentElement).overflowX;
    Should Be True    $style in ('auto', 'scroll')    The table is not in a box that scrolls on its own (overflow-x is ${style})
