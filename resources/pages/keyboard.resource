*** Settings ***
Documentation     Keyboard-only use of the Jobs page.
Resource          ../common.resource


*** Keywords ***
Element Should Be Reachable By Tab
    [Arguments]    ${locator}    ${max_tabs}=80
    Require Values    ${locator}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript    document.activeElement.blur(); window.scrollTo(0, 0);
    FOR    ${i}    IN RANGE    ${max_tabs}
        Press Keys    NONE    TAB
        ${focused}=    Execute Javascript    return document.activeElement === arguments[0];    ARGUMENTS    ${element}
        IF    ${focused}    RETURN
    END
    Fail    Not reachable with the TAB key within ${max_tabs} presses: ${locator}

Keyboard Navigation Should Work On Jobs Page
    Require Values    ${FILTER_OPTION}    ${JOB_CARD}    ${CARD}[view_apply]
    ${first_filter}=    Format Locator    ${FILTER_OPTION}    group=departments    label=${FILTER_OPTIONS}[departments][0]
    ${first_apply}=    Card Child    ${JOB_CARD}    1    ${CARD}[view_apply]
    Element Should Be Reachable By Tab    ${SEARCH_INPUT}
    Element Should Be Reachable By Tab    ${SORT_DROPDOWN}
    Element Should Be Reachable By Tab    ${first_filter}
    Element Should Be Reachable By Tab    ${first_apply}
    Element Should Be Reachable By Tab    ${FOOTER_LINK}[open_positions]
    # operate with keys: SPACE toggles a filter, ENTER opens a job
    Element Should Be Reachable By Tab    ${first_filter}
    Press Keys    NONE    SPACE
    Checkbox Should Be Selected    ${first_filter}
    # the Clear filters button only appears after a filter is selected
    Element Should Be Reachable By Tab    ${BTN_CLEAR_FILTERS}
    Go To Jobs Page
    ${before}=    Get Location
    Element Should Be Reachable By Tab    ${first_apply}
    Press Keys    NONE    ENTER
    Wait Until Keyword Succeeds    5x    1s    Location Should Have Changed    ${before}

Location Should Have Changed
    [Arguments]    ${before}
    ${now}=    Get Location
    Should Not Be Equal    ${now}    ${before}
