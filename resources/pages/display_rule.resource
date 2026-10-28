*** Settings ***
Documentation     Search/Filter visibility depends on the number of jobs:
...               1-5 jobs = hidden (cards only), 6+ jobs = shown. Threshold: MIN_JOBS_FOR_SEARCH_FILTER.
Resource          ../common.resource
Resource          job_cards.resource
Resource          search_sort.resource
Resource          filters.resource


*** Keywords ***
# ---------- hidden (1-5 jobs) ----------
Search Bar Should Be Hidden
    Require Values    ${SEARCH_INPUT}
    Wait Until Element Is Not Visible    ${SEARCH_INPUT}

Filter Should Be Hidden
    Require Values    ${FILTER_PANEL}    ${BTN_CLEAR_FILTERS}
    Wait Until Element Is Not Visible    ${FILTER_PANEL}
    Wait Until Element Is Not Visible    ${BTN_CLEAR_FILTERS}

Filter Tags Bar Should Be Hidden
    Require Values    ${SELECTED_FILTER_TAG_ANY}
    Wait Until Element Is Not Visible    ${SELECTED_FILTER_TAG_ANY}

Sort Should Be Hidden
    Require Values    ${SORT_DROPDOWN}
    Wait Until Element Is Not Visible    ${SORT_DROPDOWN}

Search And Filter Should Be Hidden
    Search Bar Should Be Hidden
    Filter Should Be Hidden
    Filter Tags Bar Should Be Hidden

# ---------- shown (6+ jobs) ----------
Search And Filter Should Be Shown
    Element Should Be Shown    ${SEARCH_INPUT}
    Element Should Be Shown    ${FILTER_PANEL}

# ---------- TC cases ----------
Few Jobs Should Hide Search Bar
    Require Few Jobs
    Search Bar Should Be Hidden

Few Jobs Should Hide Filter
    Require Few Jobs
    Filter Should Be Hidden

Few Jobs Should Hide Filter Tags Bar
    Require Few Jobs
    Filter Tags Bar Should Be Hidden

Few Jobs Should Hide Sort
    Require Few Jobs
    Skip If    not ${SORT_HIDDEN_WHEN_FEW}    Sort is expected to stay visible with few jobs (SORT_HIDDEN_WHEN_FEW is False).
    Sort Should Be Hidden

Few Jobs Should Show Only Job Cards In One Column
    [Documentation]    Cards appear one under another, same left edge, none beside another.
    Require Few Jobs
    Require Values    ${CARD}[title]    ${CARD}[view_apply]
    Job Cards Should Be Displayed
    ${cards}=    Get WebElements    ${JOB_CARD}
    ${prev_y}=    Set Variable    ${-1}
    ${first_x}=    Set Variable    ${None}
    FOR    ${card}    IN    @{cards}
        ${x}=    Get Horizontal Position    ${card}
        ${y}=    Get Vertical Position    ${card}
        Should Be True    ${y} > ${prev_y}    A card is not below the previous card (y=${y}, previous y=${prev_y})
        IF    $first_x is None
            ${first_x}=    Set Variable    ${x}
        END
        ${gap}=    Evaluate    abs(${x} - ${first_x})
        Should Be True    ${gap} <= 2    Cards are not in one column (x=${x}, first x=${first_x})
        ${prev_y}=    Set Variable    ${y}
    END

Hero Subtitle Count Should Match Displayed Cards
    Require Values    ${HERO_SUBTITLE}    ${JOB_CARD}
    Wait Until Element Is Visible    ${HERO_SUBTITLE}
    ${text}=    Get Text    ${HERO_SUBTITLE}
    ${shown}=    Number From Text    ${text}
    Job Count Should Be    ${shown}

Exactly Five Jobs Should Hide Search And Filter
    Require Exactly Jobs    5
    Search And Filter Should Be Hidden

Exactly Six Jobs Should Show Search And Filter
    Require Exactly Jobs    6
    Search And Filter Should Be Shown

Many Jobs Should Show Search Bar
    Require Many Jobs
    Search Bar Should Be Displayed With Placeholder

Many Jobs Should Show Filter
    Require Many Jobs
    Filter Panel Should Be Displayed On The Left
    Clear Filters Button Should Be Displayed

Search And Filter Should Stay When Results Drop Below Threshold
    [Documentation]    The rule counts ALL jobs, not the filtered result.
    Require Many Jobs
    Require Values    ${FILTER_OPTIONS}[departments]
    Search Jobs    ${SEARCH_NO_MATCH_TEXT}
    Search And Filter Should Be Shown
    Search Jobs    ${EMPTY}
    Select Filter Option    departments    ${FILTER_OPTIONS}[departments][0]
    Search And Filter Should Be Shown

No Jobs Should Hide Search And Filter And Show Empty State
    Require Exactly Jobs    0
    Search And Filter Should Be Hidden
    Element Should Be Shown    ${EMPTY_STATE}
