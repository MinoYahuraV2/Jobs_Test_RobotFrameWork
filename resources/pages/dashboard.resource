*** Settings ***
Documentation     CMS dashboard keywords: /admin/dashboard.
...               The tests read numbers and rows from the page and check that they agree with each other
...               and with the Export file, so they do not depend on which applicants are in the database.
Resource          ../common.resource
Resource          login.resource
Library           OperatingSystem
Library           ../../libraries/DashboardData.py
Variables         ../../locators/dashboard_page.py
Variables         ../../testdata/dashboard_expected.py


*** Keywords ***
# ================= open / reset =================
Open Dashboard Browser
    Open Admin Browser
    Login As Admin And Reach Dashboard

Open Dashboard
    [Documentation]    Start every test logged in, on a desktop window, on the dashboard with no filter.
    Set Window Size    1440    900
    Go To Dashboard

Go To Dashboard
    [Arguments]    ${query}=${EMPTY}
    Go To    ${BASE_URL}${DASH_PATH}${query}
    Wait For Dashboard To Load

Wait For Dashboard To Load
    Wait For Condition    return document.readyState === 'complete'
    Wait Until Element Is Visible    ${DASH_H1}
    Wait Until Element Is Visible    ${DASH_TABLE_SECTION}

Location Should Have Changed
    [Arguments]    ${before}
    ${now}=    Get Location
    Should Not Be Equal    ${now}    ${before}

# ================= filters =================
Submit Dashboard Filters
    [Documentation]    Press the search button and wait until the new page has loaded.
    ${before}=    Get Location
    Click Button    ${DASH_SEARCH_BUTTON}
    Wait Until Keyword Succeeds    15s    0.3s    Location Should Have Changed    ${before}
    Wait For Dashboard To Load

Set Date Filter
    [Arguments]    ${locator}    ${iso_day}
    [Documentation]    Date boxes are typed by the browser in the local format, so set the value directly (YYYY-MM-DD).
    ${element}=    Get WebElement    ${locator}
    Execute Javascript    arguments[0].value = arguments[1];    ARGUMENTS    ${element}    ${iso_day}

Filter Applicants
    [Arguments]    ${name}=${EMPTY}    ${job}=${EMPTY}    ${status}=${EMPTY}    ${date_from}=${EMPTY}    ${date_to}=${EMPTY}
    IF    $name != ''
        Input Text    ${DASH_FILTER_NAME}    ${name}
    END
    IF    $job != ''
        Select From List By Label    ${DASH_FILTER_JOB}    ${job}
    END
    IF    $status != ''
        Select From List By Label    ${DASH_FILTER_STATUS}    ${status}
    END
    IF    $date_from != ''
        Set Date Filter    ${DASH_FILTER_FROM}    ${date_from}
    END
    IF    $date_to != ''
        Set Date Filter    ${DASH_FILTER_TO}    ${date_to}
    END
    Submit Dashboard Filters

First Row
    ${rows}=    Get Table Rows
    Should Not Be Empty    ${rows}    The table has no applicant rows
    RETURN    ${rows}[0]

Total Applicants
    [Documentation]    Number of applicants that match the current filter (from the table footer).
    ${total}=    Get Result Total
    RETURN    ${total}

# ================= open page =================
Top Bar Should Show Brand And User
    Element Text Should Be    ${DASH_BRAND_LINK}    ${DASH_BRAND_TEXT}
    Element Should Be Visible    ${DASH_HEADER_LOGO}
    ${width}=    Execute Javascript    var i = document.querySelector('header img'); return i ? i.naturalWidth : 0;
    Should Be True    ${width} > 0    The logo image in the top bar did not load
    Element Should Be Visible    ${DASH_USER_AREA}
    Element Should Be Visible    ${DASH_USER_AVATAR}
    Element Should Be Visible    ${LOGIN_LOGOUT_BUTTON}

Visible Menu Links
    ${links}=    Execute Javascript
    ...    return [...document.querySelectorAll("nav[aria-label='CMS sections'] a")].filter(a => a.offsetParent !== null).map(a => [a.innerText.trim(), a.getAttribute('aria-current')]);
    RETURN    ${links}

Menu Texts Should Match
    ${links}=    Visible Menu Links
    ${texts}=    Create List
    FOR    ${link}    IN    @{links}
        Append To List    ${texts}    ${link}[0]
    END
    Lists Should Be Equal    ${texts}    ${DASH_NAV_TEXTS}

Only Dashboard Menu Should Be Marked Current
    ${links}=    Visible Menu Links
    Should Be Equal    ${links}[0][1]    page    The Dashboard menu item is not marked as the current page
    Should Be Equal    ${links}[1][1]    ${None}
    Should Be Equal    ${links}[2][1]    ${None}

Header Buttons Should Match
    Element Text Should Be    ${DASH_EXPORT}    ${DASH_EXPORT_TEXT}
    Element Should Be Enabled    ${DASH_EXPORT}
    Element Text Should Be    ${DASH_NEW_JOB}    ${DASH_NEW_JOB_TEXT}
    Element Should Be Visible    ${DASH_NEW_JOB}

Skip Link Should Jump To The Content
    Press Keys    NONE    TAB
    ${text}=    Execute Javascript    return document.activeElement.innerText.trim();
    Should Be Equal    ${text}    ${DASH_SKIP_LINK_TEXT}
    Press Keys    NONE    ENTER
    Wait Until Location Contains    \#cms-content

# ================= summary =================
Total Card Should Match
    ${summary}=    Get Dashboard Summary
    Should Be Equal    ${summary}[total_label]    ${DASH_TOTAL_LABEL}
    Should Be Equal    ${summary}[total_desc]    ${DASH_TOTAL_DESC}

Workflow Summary Should Match
    ${summary}=    Get Dashboard Summary
    Lists Should Be Equal    ${summary}[flow]    ${DASH_FLOW_STEPS}

Status Cards Should Match
    ${summary}=    Get Dashboard Summary
    ${cards}=    Set Variable    ${summary}[cards]
    Length Should Be    ${cards}    ${DASH_STATUS_CARDS.__len__()}
    FOR    ${card}    ${expected}    IN ZIP    ${cards}    ${DASH_STATUS_CARDS}
        Should Be Equal    ${card}[label]    ${expected}[0]
        Should Be Equal    ${card}[desc]    ${expected}[3]
    END

Every Count Should Be A Whole Number
    [Documentation]    Get Dashboard Summary already fails on a number like "1.5" or "-"; also check there are 6 cards.
    ${summary}=    Get Dashboard Summary
    Length Should Be    ${summary}[cards]    6
    Should Be True    ${summary}[total] >= 0

Status Counts Should Add Up To The Total
    ${summary}=    Get Dashboard Summary
    ${sum}=    Evaluate    sum(c['count'] for c in $summary['cards'])
    Should Be Equal As Integers    ${sum}    ${summary}[total]    The six status cards add up to ${sum}, the total card says ${summary}[total]

Total Card Should Match The Table Total
    ${summary}=    Get Dashboard Summary
    ${total}=    Total Applicants
    Should Be Equal As Integers    ${summary}[total]    ${total}

Each Card Should Match Its Filtered List
    ${summary}=    Get Dashboard Summary
    FOR    ${card}    ${expected}    IN ZIP    ${summary}[cards]    ${DASH_STATUS_CARDS}
        Go To Dashboard    ?status=${expected}[2]
        ${total}=    Total Applicants
        Should Be Equal As Integers    ${total}    ${card}[count]    Card '${card}[label]' says ${card}[count] but the filtered list has ${total}
    END

Summary Should Not Change When Filtering
    ${before}=    Get Dashboard Summary
    Go To Dashboard    ?name=${DASH_NO_MATCH_SEARCH}
    ${after}=    Get Dashboard Summary
    Should Be Equal    ${after}    ${before}

# ================= table =================
Table Headings Should Match
    Element Text Should Be    id:recent-heading    ${DASH_TABLE_SECTION_TITLE}
    ${texts}=    Execute Javascript    return [...document.querySelectorAll("#recent-applicants thead th")].map(t => t.textContent.trim());
    Lists Should Be Equal    ${texts}    ${DASH_TABLE_HEADINGS_TEXT}    ignore_case=${True}

First Page Should Have The Right Number Of Rows
    ${rows}=    Get Table Rows
    ${total}=    Total Applicants
    ${expected}=    Evaluate    min($total, ${DASH_PAGE_SIZE})
    Length Should Be    ${rows}    ${expected}

Every Row Should Be Complete
    ${rows}=    Get Table Rows
    Should Not Be Empty    ${rows}
    FOR    ${row}    IN    @{rows}
        Should Not Be Empty    ${row}[date]
        Should Not Be Empty    ${row}[name]
        Should Contain    ${row}[email]    @    Row '${row}[name]' has no email
        Should Not Be Empty    ${row}[job]    Row '${row}[name]' has no position
        Should Not Be Empty    ${row}[ai_label]    Row '${row}[name]' has no AI screening label
        Should Not Be Empty    ${row}[status]    Row '${row}[name]' has no HR status
        Should Not Be Empty    ${row}[href]    Row '${row}[name]' has no profile link
    END

Every Date Should Have The Right Format
    ${rows}=    Get Table Rows
    FOR    ${row}    IN    @{rows}
        Thai Datetime To Iso    ${row}[date]
    END

Rows Should Be Newest First
    ${rows}=    Get Table Rows
    ${dates}=    Create List
    FOR    ${row}    IN    @{rows}
        ${iso}=    Thai Datetime To Iso    ${row}[date]
        Append To List    ${dates}    ${iso}
    END
    ${sorted}=    Evaluate    sorted($dates, reverse=True)
    Lists Should Be Equal    ${dates}    ${sorted}    The rows are not sorted from newest to oldest

No Application Time Should Be In The Future
    [Documentation]    The computer clock is Bangkok time, the same zone the site should show.
    ${rows}=    Get Table Rows
    ${late}=    Times In The Future    ${rows}
    Should Be Empty    ${late}    These application times are later than now (the page may show the time +7 hours): ${late}

Every Status Should Be A Known Status
    ${rows}=    Get Table Rows
    FOR    ${row}    IN    @{rows}
        Should Contain    ${DASH_STATUS_TEXTS}    ${row}[status]    Unknown HR status in the table
    END

Every AI Screening Cell Should Be Valid
    ${rows}=    Get Table Rows
    FOR    ${row}    IN    @{rows}
        Should Contain    ${DASH_AI_LABELS}    ${row}[ai_label]
        Should Match Regexp    ${row}[ai_score]    ${DASH_AI_SCORE_PATTERN}
        ${number}=    Get Regexp Matches    ${row}[ai_score]    (\\d+)%    1
        IF    $number
            Should Be True    0 <= ${number}[0] <= 100    The AI score ${row}[ai_score] is out of range
        END
    END

Every Applicant Badge Should Match
    ${rows}=    Get Table Rows
    FOR    ${row}    IN    @{rows}
        Should Match Regexp    ${row}[badge]    ${DASH_BADGE_PATTERN}
    END

Profile Links Should Name The Applicant
    ${rows}=    Get Table Rows
    FOR    ${row}    IN    @{rows}
        Should Be Equal    ${row}[aria]    ${DASH_PROFILE_LINK_TEXT} ${row}[name] ${row}[job]
    END

Click In The Middle Of The Screen
    [Documentation]    A floating badge covers the bottom corner of the page, so scroll the item to the middle first.
    [Arguments]    ${locator}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript    arguments[0].scrollIntoView({block: 'center', behavior: 'instant'});    ARGUMENTS    ${element}
    Click Element    ${locator}

Open The First Profile
    ${row}=    First Row
    Click In The Middle Of The Screen    ${DASH_TABLE_FIRST_PROFILE}
    Wait Until Location Contains    /admin/applications/    timeout=20s
    ${url}=    Get Location
    Should Match Regexp    ${url}    ${DASH_APPLICATION_PATH_PATTERN}
    Wait Until Page Contains    ${row}[name]    timeout=20s

Profile Links Should Be Different
    ${rows}=    Get Table Rows
    ${links}=    Evaluate    [r['href'] for r in $rows]
    ${unique}=    Evaluate    len(set($links))
    Length Should Be    ${links}    ${unique}

# ================= filter form =================
Filter Fields Should Match
    ${placeholder}=    Get Element Attribute    ${DASH_FILTER_NAME}    placeholder
    Should Be Equal    ${placeholder}    ${DASH_SEARCH_PLACEHOLDER}
    Element Attribute Value Should Be    ${DASH_FILTER_NAME}    type    search
    Element Attribute Value Should Be    ${DASH_FILTER_NAME}    maxlength    ${DASH_SEARCH_MAXLENGTH}
    Element Attribute Value Should Be    ${DASH_FILTER_FROM}    type    date
    Element Attribute Value Should Be    ${DASH_FILTER_TO}    type    date
    Element Text Should Be    ${DASH_SEARCH_BUTTON}    ค้นหา

Job List Should Start With All Jobs
    ${items}=    Get List Items    ${DASH_FILTER_JOB}
    Should Be Equal    ${items}[0]    ${DASH_ALL_JOBS_TEXT}
    Should Be True    len($items) >= 2    The position list has no position besides 'all'

Status List Should Match
    ${items}=    Get List Items    ${DASH_FILTER_STATUS}
    Lists Should Be Equal    ${items}    ${DASH_STATUS_OPTIONS}

Filters Should Be Empty By Default
    Textfield Value Should Be    ${DASH_FILTER_NAME}    ${EMPTY}
    ${job}=    Get Selected List Label    ${DASH_FILTER_JOB}
    ${status}=    Get Selected List Label    ${DASH_FILTER_STATUS}
    Should Be Equal    ${job}    ${DASH_ALL_JOBS_TEXT}
    Should Be Equal    ${status}    ${DASH_ALL_STATUS_TEXT}
    Textfield Value Should Be    ${DASH_FILTER_FROM}    ${EMPTY}
    Textfield Value Should Be    ${DASH_FILTER_TO}    ${EMPTY}

Search By Part Of A Name Should Find That Applicant
    ${first}=    First Row
    ${word}=    Evaluate    max($first['name'].split(), key=len)
    Filter Applicants    name=${word}
    Location Should Contain    name=
    ${rows}=    Get Table Rows
    Should Not Be Empty    ${rows}
    FOR    ${row}    IN    @{rows}
        ${text}=    Evaluate    ($row['name'] + ' ' + $row['email']).lower()
        Should Contain    ${text}    ${word.lower()}    Row '${row}[name]' does not contain the search word
    END
    ${emails}=    Evaluate    [r['email'] for r in $rows]
    Should Contain    ${emails}    ${first}[email]

Search By Email Should Find Only That Email
    ${first}=    First Row
    Filter Applicants    name=${first}[email]
    ${rows}=    Get Table Rows
    Should Not Be Empty    ${rows}
    FOR    ${row}    IN    @{rows}
        Should Be Equal    ${row}[email]    ${first}[email]
    END

Dashboard Search Should Ignore Letter Case
    ${first}=    First Row
    ${upper}=    Evaluate    $first['email'].upper()
    Filter Applicants    name=${first}[email]
    ${total_normal}=    Total Applicants
    Go To Dashboard
    Filter Applicants    name=${upper}
    ${total_upper}=    Total Applicants
    Should Be True    ${total_normal} >= 1
    Should Be Equal As Integers    ${total_upper}    ${total_normal}

Spaces Only Should Not Filter
    ${before}=    Total Applicants
    Filter Applicants    name=${SPACE * 3}
    ${after}=    Total Applicants
    Should Be Equal As Integers    ${after}    ${before}

Search With No Match Should Show The Empty State
    Filter Applicants    name=${DASH_NO_MATCH_SEARCH}
    Empty State Should Be Shown

Empty State Should Be Shown
    Page Should Contain    ${DASH_EMPTY_TITLE}
    Page Should Contain    ${DASH_EMPTY_HINT}
    Page Should Contain Element    ${DASH_CLEAR_FILTERS_EMPTY}
    ${rows}=    Get Table Rows
    Length Should Be    ${rows}    0
    ${total}=    Total Applicants
    Should Be Equal As Integers    ${total}    0

Each Position Filter Should Only Show That Position
    ${all}=    Total Applicants
    ${items}=    Get List Items    ${DASH_FILTER_JOB}
    ${positions}=    Set Variable    ${items}[1:]
    ${sum}=    Set Variable    ${0}
    FOR    ${position}    IN    @{positions}
        Go To Dashboard
        Filter Applicants    job=${position}
        ${rows}=    Get Table Rows
        FOR    ${row}    IN    @{rows}
            Should Be Equal    ${row}[job]    ${position}
        END
        ${total}=    Total Applicants
        ${sum}=    Evaluate    ${sum} + ${total}
    END
    Should Be Equal As Integers    ${sum}    ${all}    The positions add up to ${sum} but there are ${all} applicants

Each Status Filter Should Only Show That Status
    FOR    ${text}    IN    @{DASH_STATUS_TEXTS}
        Go To Dashboard
        Filter Applicants    status=${text}
        ${rows}=    Get Table Rows
        FOR    ${row}    IN    @{rows}
            Should Be Equal    ${row}[status]    ${text}
        END
    END

Position And Status Filters Should Work Together
    ${first}=    First Row
    Filter Applicants    job=${first}[job]    status=${first}[status]
    ${rows}=    Get Table Rows
    Should Not Be Empty    ${rows}
    FOR    ${row}    IN    @{rows}
        Should Be Equal    ${row}[job]    ${first}[job]
        Should Be Equal    ${row}[status]    ${first}[status]
    END
    ${emails}=    Evaluate    [r['email'] + r['date'] for r in $rows]
    Should Contain    ${emails}    ${first}[email]${first}[date]

One Day Filter Should Only Show That Day
    ${first}=    First Row
    ${iso}=    Thai Datetime To Iso    ${first}[date]
    ${day}=    Set Variable    ${iso}[:10]
    Filter Applicants    date_from=${day}    date_to=${day}
    ${rows}=    Get Table Rows
    Should Not Be Empty    ${rows}
    FOR    ${row}    IN    @{rows}
        ${row_iso}=    Thai Datetime To Iso    ${row}[date]
        Should Be Equal    ${row_iso}[:10]    ${day}
    END
    ${dates}=    Evaluate    [r['date'] for r in $rows]
    Should Contain    ${dates}    ${first}[date]

Future Dates Should Show The Empty State
    Filter Applicants    date_from=2099-01-01
    Empty State Should Be Shown

Start Date After End Date Should Show The Empty State
    [Documentation]    The list is empty. The footer must also agree (no "page 1 of 2" with 0 results).
    Filter Applicants    date_from=2099-01-01    date_to=2000-01-01
    Empty State Should Be Shown
    ${footer}=    Get Table Footer
    ${pages}=    Pages For    ${footer}[total]
    Should Be Equal As Integers    ${footer}[pages]    ${pages}    The footer says ${footer}[pages] pages for ${footer}[total] results

Dashboard Clear Filters Should Reset Everything
    ${all}=    Total Applicants
    ${first}=    First Row
    Filter Applicants    name=${first}[email]    status=${first}[status]
    Click Element    ${DASH_CLEAR_FILTERS_TOP}
    Wait Until Keyword Succeeds    15s    0.5s    Filters Should Be Cleared    ${all}

Filters Should Be Cleared
    [Arguments]    ${all}
    Wait For Dashboard To Load
    Filters Should Be Empty By Default
    ${total}=    Total Applicants
    Should Be Equal As Integers    ${total}    ${all}
    ${location}=    Get Location
    Should Not Contain    ${location}    name=

Clear Button In The Empty State Should Reset Everything
    ${all}=    Total Applicants
    Filter Applicants    name=${DASH_NO_MATCH_SEARCH}
    Empty State Should Be Shown
    Click In The Middle Of The Screen    ${DASH_CLEAR_FILTERS_EMPTY}
    Wait Until Keyword Succeeds    15s    0.5s    Filters Should Be Cleared    ${all}

Filters Should Survive A Refresh
    ${first}=    First Row
    Filter Applicants    name=${first}[email]    status=${first}[status]
    ${total}=    Total Applicants
    Textfield Value Should Be    ${DASH_FILTER_NAME}    ${first}[email]
    ${status}=    Get Selected List Label    ${DASH_FILTER_STATUS}
    Should Be Equal    ${status}    ${first}[status]
    Reload Page
    Wait For Dashboard To Load
    Textfield Value Should Be    ${DASH_FILTER_NAME}    ${first}[email]
    ${status}=    Get Selected List Label    ${DASH_FILTER_STATUS}
    Should Be Equal    ${status}    ${first}[status]
    ${after}=    Total Applicants
    Should Be Equal As Integers    ${after}    ${total}

Enter In The Search Box Should Search
    ${first}=    First Row
    Input Text    ${DASH_FILTER_NAME}    ${first}[email]
    ${before}=    Get Location
    Press Keys    ${DASH_FILTER_NAME}    ENTER
    Wait Until Keyword Succeeds    15s    0.3s    Location Should Have Changed    ${before}
    Wait For Dashboard To Load
    Location Should Contain    name=
    ${rows}=    Get Table Rows
    Should Not Be Empty    ${rows}

Search With A Script Tag Should Be Harmless
    Filter Applicants    name=<script>alert(1)</script>
    Alert Should Not Be Present
    Empty State Should Be Shown

Search With SQL Text Should Find Nobody
    Filter Applicants    name=' OR '1'='1
    Empty State Should Be Shown

Search Box Should Stop At The Maximum Length
    ${long}=    Evaluate    'a' * ${DASH_LONG_SEARCH_LENGTH}
    Input Text    ${DASH_FILTER_NAME}    ${long}
    ${value}=    Get Value    ${DASH_FILTER_NAME}
    ${length}=    Get Length    ${value}
    Should Be Equal As Integers    ${length}    ${DASH_SEARCH_MAXLENGTH}

Unknown Filter Values Should Be Ignored
    ${all}=    Total Applicants
    Go To Dashboard    ?status=not-a-status&job=not-a-job
    ${total}=    Total Applicants
    Should Be Equal As Integers    ${total}    ${all}

# ================= paging =================
Footer Should Agree With The Table
    ${footer}=    Get Table Footer
    ${rows}=    Get Table Rows
    ${pages}=    Pages For    ${footer}[total]
    Should Be Equal As Integers    ${footer}[pages]    ${pages}
    ${expected}=    Evaluate    min(${footer}[total], ${DASH_PAGE_SIZE})
    Length Should Be    ${rows}    ${expected}
    Should Be Equal As Integers    ${footer}[page]    1

Require More Than One Page
    ${footer}=    Get Table Footer
    Skip If    ${footer}[pages] < 2    There is only one page of applicants (needs more than ${DASH_PAGE_SIZE})
    RETURN    ${footer}

Previous Should Be Off On The First Page
    Require More Than One Page
    Element Attribute Value Should Be    ${DASH_PAGER_PREV}    aria-disabled    true
    Element Attribute Value Should Be    ${DASH_PAGER_NEXT}    aria-disabled    false

Next Should Open The Second Page
    ${footer}=    Require More Than One Page
    ${first_page}=    Get Table Rows
    Click In The Middle Of The Screen    ${DASH_PAGER_NEXT}
    Wait Until Location Contains    page=2
    Wait For Dashboard To Load
    ${now}=    Get Table Footer
    Should Be Equal As Integers    ${now}[page]    2
    ${rows}=    Get Table Rows
    ${expected}=    Evaluate    min(${DASH_PAGE_SIZE}, ${footer}[total] - ${DASH_PAGE_SIZE})
    Length Should Be    ${rows}    ${expected}
    ${first_links}=    Evaluate    [r['href'] for r in $first_page]
    FOR    ${row}    IN    @{rows}
        Should Not Contain    ${first_links}    ${row}[href]    The same applicant is on page 1 and page 2
    END

Next Should Be Off On The Last Page
    ${footer}=    Require More Than One Page
    Go To Dashboard    ?page=${footer}[pages]
    Element Attribute Value Should Be    ${DASH_PAGER_NEXT}    aria-disabled    true
    Element Attribute Value Should Be    ${DASH_PAGER_PREV}    aria-disabled    false

Previous Should Return To The First Page
    Require More Than One Page
    ${first}=    First Row
    Go To Dashboard    ?page=2
    Click In The Middle Of The Screen    ${DASH_PAGER_PREV}
    Wait Until Keyword Succeeds    15s    0.5s    Footer Should Be On Page    1
    ${again}=    First Row
    Should Be Equal    ${again}[href]    ${first}[href]

Footer Should Be On Page
    [Arguments]    ${page}
    ${footer}=    Get Table Footer
    Should Be Equal As Integers    ${footer}[page]    ${page}

Pages Should Continue In Date Order
    Require More Than One Page
    ${page_one}=    Get Table Rows
    Go To Dashboard    ?page=2
    ${page_two}=    Get Table Rows
    ${last_one}=    Thai Datetime To Iso    ${page_one}[-1][date]
    ${first_two}=    Thai Datetime To Iso    ${page_two}[0][date]
    Should Be True    '${last_one}' >= '${first_two}'    Page 2 starts with a newer application than page 1 ends with

Page Past The End Should Not Break
    [Documentation]    Today it shows the empty state. Either that or the last page is acceptable; an error is not.
    Go To Dashboard    ?page=9999
    Element Should Be Visible    ${DASH_H1}
    Element Should Be Visible    ${DASH_TABLE_SECTION}
    Page Should Not Contain    Application error
    Page Should Not Contain    Internal Server Error

Bad Page Numbers Should Open The First Page
    ${first}=    First Row
    FOR    ${bad}    IN    0    abc    -1
        Go To Dashboard    ?page=${bad}
        ${footer}=    Get Table Footer
        Should Be Equal As Integers    ${footer}[page]    1    page=${bad} did not open the first page
        ${row}=    First Row
        Should Be Equal    ${row}[href]    ${first}[href]
    END

# ================= actions / Export =================
Download Export
    ${folder}=    Set Download Folder    ${EXECDIR}${/}${DASH_DOWNLOAD_FOLDER}
    Click Button    ${DASH_EXPORT}
    ${file}=    Wait For Download    ${folder}
    RETURN    ${file}

Read Export
    ${file}=    Download Export
    ${book}=    Read Export Workbook    ${file}
    RETURN    ${book}

Export Should Download A Dated Excel File
    ${file}=    Download Export
    ${name}=    Evaluate    os.path.basename($file)    modules=os
    Should Match Regexp    ${name}    ${DASH_EXPORT_FILE_PATTERN}
    ${stamp}=    Evaluate    re.match($DASH_EXPORT_FILE_PATTERN, $name).group(1)    modules=re
    ${days}=    Evaluate    abs((datetime.datetime.strptime($stamp, '%Y%m%d') - datetime.datetime.now()).days)    modules=datetime
    Should Be True    ${days} <= 1    The file is dated ${stamp}, which is not today
    ${size}=    Get File Size    ${file}
    Should Be True    ${size} > 1000    The Export file is too small (${size} bytes)
    Location Should Contain    ${DASH_PATH}

Export Should Have The Expected Sheets And Columns
    ${book}=    Read Export
    Lists Should Be Equal    ${book}[sheets]    ${DASH_EXPORT_SHEETS}
    Should Not Be Empty    ${book}[applicants]
    ${columns}=    Evaluate    list($book['applicants'][0].keys())
    Lists Should Be Equal    ${columns}    ${DASH_EXPORT_APPLICANT_COLUMNS}

Export Summary Should Match The Cards
    ${summary}=    Get Dashboard Summary
    ${book}=    Read Export
    Should Be Equal As Integers    ${book}[summary][${DASH_TOTAL_LABEL}]    ${summary}[total]
    FOR    ${card}    ${name}    IN ZIP    ${summary}[cards]    ${DASH_EXPORT_SUMMARY_NAMES}
        Should Be Equal As Integers    ${book}[summary][${name}]    ${card}[count]    Export says ${book}[summary][${name}] for '${name}' but the card says ${card}[count]
    END

Export Should List Every Applicant
    ${total}=    Total Applicants
    ${first}=    First Row
    ${book}=    Read Export
    Length Should Be    ${book}[applicants]    ${total}
    Should Be Equal    ${book}[applicants][0][อีเมล]    ${first}[email]
    Should Be Equal    ${book}[applicants][0][สถานะ]    ${first}[status]
    Should Be Equal    ${book}[applicants][0][ตำแหน่งที่สมัคร]    ${first}[job]

Export Time Should Match The Table
    [Documentation]    The first applicant must show the same date and time in the table and in the file.
    ${first}=    First Row
    ${book}=    Read Export
    ${table_time}=    Thai Datetime To Iso    ${first}[date]
    ${file_time}=    Export Datetime To Iso    ${book}[applicants][0][วันที่สมัคร]
    Should Be Equal    ${table_time}    ${file_time}    The table shows ${table_time} but the Export file shows ${file_time}

Position List Should Match The Export
    ${items}=    Get List Items    ${DASH_FILTER_JOB}
    ${book}=    Read Export
    ${titles}=    Evaluate    sorted(j['ชื่อตำแหน่ง'] for j in $book['jobs'])
    ${options}=    Evaluate    sorted($items[1:])
    Lists Should Be Equal    ${options}    ${titles}

New Job Button Should Open The New Job Page
    Click Element    ${DASH_NEW_JOB}
    Wait Until Location Contains    ${DASH_NEW_JOB_PATH}    timeout=20s

Jobs Menu Should Open The Jobs Page
    Click Element    ${DASH_NAV_JOBS}
    Wait Until Location Contains    ${DASH_JOBS_PATH}    timeout=20s
    ${location}=    Get Location
    Should Not Contain    ${location}    /new

Applicants Menu Should Jump To The Table
    Click Element    ${DASH_NAV_APPLICANTS}
    Wait Until Location Contains    \#recent-applicants
    Element Should Be Visible    ${DASH_TABLE_SECTION}
    Location Should Contain    ${DASH_PATH}

Brand Link Should Return To The Dashboard
    Go To    ${BASE_URL}${DASH_JOBS_PATH}
    Wait Until Element Is Visible    ${DASH_BRAND_LINK}
    Click Element    ${DASH_BRAND_LINK}
    Dashboard Should Be Open

# ================= keyboard / layout =================
Filter Form Tab Order Should Follow The Form
    Click Element    ${DASH_FILTER_NAME}
    Press Keys    NONE    TAB
    ${first}=    Execute Javascript    return document.activeElement.id;
    Press Keys    NONE    TAB
    ${second}=    Execute Javascript    return document.activeElement.id;
    Should Be Equal    ${first}    filter-job
    Should Be Equal    ${second}    filter-status
    ${reached}=    Set Variable    ${False}
    FOR    ${i}    IN RANGE    12
        Press Keys    NONE    TAB
        ${text}=    Execute Javascript    return document.activeElement.innerText.trim();
        IF    $text == 'ค้นหา'
            ${reached}=    Set Variable    ${True}
            BREAK
        END
    END
    Should Be True    ${reached}    The search button cannot be reached with the Tab key

Card Grid Should Be Laid Out
    [Arguments]    ${columns}    ${rows}
    ${layout}=    Execute Javascript
    ...    const cards = [...document.querySelectorAll("section[aria-label='สรุปสถานะผู้สมัคร'] [data-slot='card']")].slice(1).map(c => c.getBoundingClientRect());
    ...    return [new Set(cards.map(r => Math.round(r.left))).size, new Set(cards.map(r => Math.round(r.top))).size];
    Should Be Equal As Integers    ${layout}[0]    ${columns}    The status cards use ${layout}[0] columns, expected ${columns}
    Should Be Equal As Integers    ${layout}[1]    ${rows}    The status cards use ${layout}[1] rows, expected ${rows}

Page Should Not Scroll Sideways
    [Arguments]    ${width}    ${height}
    Set Window Size    ${width}    ${height}
    Sleep    ${RESULT_SETTLE}
    ${overflow}=    Execute Javascript    return document.documentElement.scrollWidth - document.documentElement.clientWidth;
    Should Be True    ${overflow} <= 1    The page scrolls sideways by ${overflow}px at ${width}px wide

Phone Menu Should Open
    Set Window Size    375    812
    Sleep    ${RESULT_SETTLE}
    Element Should Be Visible    ${DASH_MOBILE_MENU_BUTTON}
    Click Element    ${DASH_MOBILE_MENU_BUTTON}
    Wait Until Element Is Visible    ${DASH_MOBILE_NAV}
    ${count}=    Get Element Count    css:\#cms-mobile-navigation a
    Should Be True    ${count} >= 3    The phone menu has only ${count} links
