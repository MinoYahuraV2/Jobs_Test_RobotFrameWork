*** Settings ***
Documentation     Filter panel keywords. Rule assumed: OR inside a group, AND across groups
...               (see libraries/JobData.py - confirm with the team).
Resource          ../common.resource
Resource          job_cards.resource


*** Keywords ***
Filter Panel Should Be Displayed On The Left
    Element Should Be Shown    ${FILTER_PANEL}
    Require Values    ${JOB_CARD}
    ${panel_x}=    Get Horizontal Position    ${FILTER_PANEL}
    ${card_x}=    Get Horizontal Position    ${JOB_CARD}
    Should Be True    ${panel_x} < ${card_x}    Filter panel is not on the left of the job list
    FOR    ${group}    ${title}    IN    &{FILTER_GROUP_TITLES}
        Element Text Should Match    ${FILTER_GROUP}[${group}]    ${title}
    END

Clear Filters Button Should Be Displayed
    [Documentation]    On the dev site the button appears only AFTER a filter is selected, so select one first.
    Require Values    ${BTN_CLEAR_FILTERS}    ${FILTER_OPTIONS}[departments]
    ${visible}=    Run Keyword And Return Status    Element Should Be Visible    ${BTN_CLEAR_FILTERS}
    IF    not ${visible}
        Select Filter Option    departments    ${FILTER_OPTIONS}[departments][0]
    END
    Element Text Should Match    ${BTN_CLEAR_FILTERS}    ${CLEAR_FILTERS_TEXT}

Filter Group Should Collapse And Expand
    [Arguments]    ${group}
    Require Values    ${FILTER_GROUP_TOGGLE}[${group}]    ${FILTER_GROUP_LIST}[${group}]
    Element Should Be Visible    ${FILTER_GROUP_LIST}[${group}]
    Click Element Safe    ${FILTER_GROUP_TOGGLE}[${group}]
    Element Should Not Be Visible    ${FILTER_GROUP_LIST}[${group}]
    Click Element Safe    ${FILTER_GROUP_TOGGLE}[${group}]
    Element Should Be Visible    ${FILTER_GROUP_LIST}[${group}]

# ---------- select / unselect ----------
Select Filter Option
    [Documentation]    Click the checkbox. Clicking a selected option unselects it.
    [Arguments]    ${group}    ${label}
    Require Values    ${FILTER_OPTION}
    ${checkbox}=    Format Locator    ${FILTER_OPTION}    group=${group}    label=${label}
    # the <input> is hidden by the page and covered by its label, so click the label (the parent of the input)
    Click Element Safe    ${checkbox}/..
    Wait For Results

Selected Filter Tag Should Be Shown
    [Arguments]    ${label}
    ${tag}=    Format Locator    ${SELECTED_FILTER_TAG}    label=${label}
    ${remove}=    Format Locator    ${SELECTED_FILTER_TAG_REMOVE}    label=${label}
    Element Should Be Shown    ${tag}
    Element Should Be Shown    ${remove}

Selected Filter Tag Should Not Be Shown
    [Arguments]    ${label}
    ${tag}=    Format Locator    ${SELECTED_FILTER_TAG}    label=${label}
    Require Values    ${tag}
    Element Should Not Be Visible    ${tag}

Select Filters
    [Arguments]    ${filters}
    FOR    ${group}    ${values}    IN    &{filters}
        FOR    ${value}    IN    @{values}
            Select Filter Option    ${group}    ${value}
        END
    END

# ---------- compare with data ----------
Displayed Jobs Should Match Filters
    [Arguments]    ${filters}
    Require Real Job Data
    ${expected}=    Expected Titles    filters=${filters}
    ${actual}=    Get Displayed Titles
    Titles Should Match    ${actual}    ${expected}

Filters From Data Should Match
    [Documentation]    Pick the first N values of a group from the data, select them, compare.
    [Arguments]    ${group}    ${n}
    Require Real Job Data
    ${values}=    Distinct Values For Group    ${group}
    ${size}=    Get Length    ${values}
    Skip If    ${size} < ${n}    Data has fewer than ${n} distinct values for ${group}
    ${picked}=    Evaluate    $values[:int($n)]
    ${filters}=    Create Dictionary    ${group}=${picked}
    Select Filters    ${filters}
    Displayed Jobs Should Match Filters    ${filters}

Filter By Label Should Match Data
    [Arguments]    ${group}    ${label}
    Require Values    ${FILTER_OPTION}
    ${option}=    Format Locator    ${FILTER_OPTION}    group=${group}    label=${label}
    ${count}=    Get Element Count    ${option}
    Skip If    ${count} == 0    Filter option "${label}" is not on the page (options come from the database).
    ${picked}=    Create List    ${label}
    ${filters}=    Create Dictionary    ${group}=${picked}
    Select Filters    ${filters}
    Selected Filter Tag Should Be Shown    ${label}
    Displayed Jobs Should Match Filters    ${filters}

Filters Across Groups Should Match Data
    Require Real Job Data
    ${filters}=    Filters From First Job
    Select Filters    ${filters}
    Displayed Jobs Should Match Filters    ${filters}

Removing Filter Should Restore Results
    [Arguments]    ${group}
    ${label}=    Set Variable    ${FILTER_OPTIONS}[${group}][0]
    Select Filter Option    ${group}    ${label}
    Selected Filter Tag Should Be Shown    ${label}
    Select Filter Option    ${group}    ${label}
    Selected Filter Tag Should Not Be Shown    ${label}
    Job Count Should Be    ${INITIAL_CARD_COUNT}

Clear Filters Should Reset Everything
    Require Values    ${BTN_CLEAR_FILTERS}    ${SELECTED_FILTER_TAG_ANY}
    ${dept}=    Set Variable    ${FILTER_OPTIONS}[departments][0]
    ${type}=    Set Variable    ${FILTER_OPTIONS}[job_types][0]
    Select Filter Option    departments    ${dept}
    Select Filter Option    job_types    ${type}
    Click Element Safe    ${BTN_CLEAR_FILTERS}
    Wait For Results
    Page Should Not Contain Element    ${SELECTED_FILTER_TAG_ANY}
    Job Count Should Be    ${INITIAL_CARD_COUNT}

# ---------- selected-filter tags ----------
Selected Filters Should Be Shown As Tags
    ${dept}=    Set Variable    ${FILTER_OPTIONS}[departments][0]
    ${type}=    Set Variable    ${FILTER_OPTIONS}[job_types][0]
    Select Filter Option    departments    ${dept}
    Select Filter Option    job_types    ${type}
    Selected Filter Tag Should Be Shown    ${dept}
    Selected Filter Tag Should Be Shown    ${type}

Removing Tag Should Update Results
    ${dept}=    Set Variable    ${FILTER_OPTIONS}[departments][0]
    ${type}=    Set Variable    ${FILTER_OPTIONS}[job_types][0]
    Select Filter Option    departments    ${dept}
    Select Filter Option    job_types    ${type}
    ${remove}=    Format Locator    ${SELECTED_FILTER_TAG_REMOVE}    label=${dept}
    Click Element Safe    ${remove}
    Wait For Results
    Selected Filter Tag Should Not Be Shown    ${dept}
    Selected Filter Tag Should Be Shown    ${type}
    ${placeholder}=    Job Data Is Placeholder
    IF    not $placeholder
        ${types}=    Create List    ${type}
        ${filters}=    Create Dictionary    job_types=${types}
        Displayed Jobs Should Match Filters    ${filters}
    END

# ---------- result count / empty ----------
Result Count Should Match Filtered Data
    Require Real Job Data
    Require Values    ${RESULT_COUNT}
    ${filters}=    Filters From First Job
    Select Filters    ${filters}
    ${expected}=    Expected Titles    filters=${filters}
    ${expected_count}=    Get Length    ${expected}
    ${text}=    Get Text    ${RESULT_COUNT}
    ${shown}=    Number From Text    ${text}
    Should Be Equal As Integers    ${shown}    ${expected_count}
    Job Count Should Be    ${expected_count}

Empty State Should Be Shown
    Element Should Be Shown    ${EMPTY_STATE}
    Element Text Should Include    ${EMPTY_STATE}    ${EMPTY_STATE_TEXT}
    Job Count Should Be    0

Impossible Filter Combination Should Show Empty State
    Require Real Job Data
    ${filters}=    Find Empty Filter Combo    ${FILTER_OPTIONS}
    Skip If    $filters is None    Every filter combination has at least one job in the data
    Select Filters    ${filters}
    Empty State Should Be Shown
