*** Settings ***
Documentation     Job card keywords (list, fields, View & Apply).
Resource          ../common.resource


*** Keywords ***
Job Count Should Be
    [Arguments]    ${expected}
    Require Values    ${JOB_CARD}
    ${count}=    Get Element Count    ${JOB_CARD}
    Should Be Equal As Integers    ${count}    ${expected}

Get Card Texts
    [Documentation]    Text of one field from every displayed card, in page order.
    [Arguments]    ${field}
    Require Values    ${JOB_CARD}    ${CARD}[${field}]
    ${count}=    Get Element Count    ${JOB_CARD}
    ${end}=    Evaluate    ${count} + 1
    ${texts}=    Create List
    FOR    ${i}    IN RANGE    1    ${end}
        ${loc}=    Card Child    ${JOB_CARD}    ${i}    ${CARD}[${field}]
        ${text}=    Get Text    ${loc}
        Append To List    ${texts}    ${text.strip()}
    END
    RETURN    ${texts}

Get Displayed Titles
    ${titles}=    Get Card Texts    title
    RETURN    ${titles}

Titles Should Match
    [Arguments]    ${actual}    ${expected}
    ${actual_sorted}=    Evaluate    sorted($actual)
    ${expected_sorted}=    Evaluate    sorted($expected)
    Should Be Equal    ${actual_sorted}    ${expected_sorted}

Job Cards Should Be Displayed
    Require Values    ${JOB_CARD}    ${CARD}[title]    ${CARD}[view_apply]
    ${count}=    Get Element Count    ${JOB_CARD}
    Should Be True    ${count} > 0    No job card is displayed
    ${end}=    Evaluate    ${count} + 1
    FOR    ${i}    IN RANGE    1    ${end}
        FOR    ${field}    IN    title    view_apply
            ${loc}=    Card Child    ${JOB_CARD}    ${i}    ${CARD}[${field}]
            Element Should Be Visible    ${loc}
        END
    END

Displayed Titles Should Match Data
    Require Real Job Data
    ${expected}=    Expected Titles
    ${actual}=    Get Displayed Titles
    Titles Should Match    ${actual}    ${expected}

Card Field Should Match Data
    [Documentation]    For every card, compare one field with the data row of that job.
    ...    Expected None means the element must NOT exist (e.g. no Urgent badge).
    [Arguments]    ${field}
    Require Real Job Data
    ${has}=    Any Job Has Card Field    ${field}
    Skip If    not $has    No job has data for "${field}" yet (empty in the CMS), so it cannot be checked.
    Require Values    ${JOB_CARD}    ${CARD}[title]    ${CARD}[${field}]
    ${titles}=    Get Displayed Titles
    FOR    ${i}    ${title}    IN ENUMERATE    @{titles}    start=1
        ${job}=    Get Job    ${title}
        ${expected}=    Expected Card Text    ${job}    ${field}
        ${loc}=    Card Child    ${JOB_CARD}    ${i}    ${CARD}[${field}]
        IF    $expected is None
            Page Should Not Contain Element    ${loc}
        ELSE
            Require Values    ${expected}
            Element Should Contain    ${loc}    ${expected}
        END
    END

Job Cards Should Not Be Duplicated
    ${titles}=    Get Displayed Titles
    ${unique}=    Evaluate    len(set($titles)) == len($titles)
    Should Be True    ${unique}    Duplicate job cards: ${titles}
    Card Field Should Match Data    department
    Card Field Should Match Data    location

View And Apply Should Open Job Detail
    Require Values    ${JOB_CARD}    ${CARD}[view_apply]    ${JOB_DETAIL_URL_CONTAINS}
    ${button}=    Card Child    ${JOB_CARD}    1    ${CARD}[view_apply]
    Click And Verify Destination    ${button}    ${JOB_DETAIL_URL_CONTAINS}

Opened Detail Should Match Selected Card
    [Arguments]    ${index}
    Require Values    ${JOB_CARD}    ${CARD}[title]    ${CARD}[view_apply]    ${DETAIL_TITLE}
    IF    '${index}' == 'last'
        ${index}=    Get Element Count    ${JOB_CARD}
    END
    ${title_loc}=    Card Child    ${JOB_CARD}    ${index}    ${CARD}[title]
    ${title}=    Get Text    ${title_loc}
    ${button}=    Card Child    ${JOB_CARD}    ${index}    ${CARD}[view_apply]
    Click Element Safe    ${button}
    Element Text Should Match    ${DETAIL_TITLE}    ${title.strip()}    ignore_case=${False}
