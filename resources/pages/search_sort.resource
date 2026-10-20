*** Settings ***
Documentation     Hero, result count, search and sort keywords.
Resource          ../common.resource
Resource          job_cards.resource


*** Keywords ***
Jobs Page Should Display All Main Sections
    Element Should Be Shown    ${LOGO}
    Element Should Be Shown    ${NAV}[jobs]
    Element Should Be Shown    ${HERO_TITLE}
    Element Should Be Shown    ${SEARCH_INPUT}
    Element Should Be Shown    ${SORT_DROPDOWN}
    Element Should Be Shown    ${FILTER_PANEL}
    Element Should Be Shown    ${RESULT_COUNT}
    Job Cards Should Be Displayed
    Element Should Be Shown    ${FOOTER}

Hero Title Should Be Correct
    Element Text Should Match    ${HERO_TITLE}    ${HERO_TITLE_TEXT}    ignore_case=${False}

Result Count Should Match Displayed Cards
    Require Values    ${RESULT_COUNT}    ${JOB_CARD}
    ${text}=    Get Text    ${RESULT_COUNT}
    ${shown}=    Number From Text    ${text}
    Job Count Should Be    ${shown}

# ---------- search ----------
Search Bar Should Be Displayed With Placeholder
    Element Should Be Shown    ${SEARCH_INPUT}
    Require Values    ${SEARCH_PLACEHOLDER}
    ${placeholder}=    Get Element Attribute    ${SEARCH_INPUT}    placeholder
    Should Be Equal    ${placeholder}    ${SEARCH_PLACEHOLDER}

Search Jobs
    [Arguments]    ${text}
    Require Values    ${SEARCH_INPUT}
    Wait Until Element Is Visible    ${SEARCH_INPUT}
    Clear Element Text    ${SEARCH_INPUT}
    IF    '${text}' != ''
        Input Text    ${SEARCH_INPUT}    ${text}
        Press Keys    ${SEARCH_INPUT}    ENTER
    END
    Wait For Results

Displayed Titles Should Include Expected
    [Documentation]    Search may be wider than title only, so we check "includes", not "equals".
    [Arguments]    ${text}
    ${expected}=    Expected Titles    text=${text}
    ${actual}=    Get Displayed Titles
    FOR    ${title}    IN    @{expected}
        List Should Contain Value    ${actual}    ${title}
    END

Search By Existing Title Should Show Match
    Require Real Job Data
    ${title}=    First Title
    Search Jobs    ${title}
    Displayed Titles Should Include Expected    ${title}

Search By Keyword Should Show Matches
    Require Real Job Data
    ${title}=    First Title
    ${word}=    Search Keyword From Title    ${title}
    Search Jobs    ${word}
    Displayed Titles Should Include Expected    ${word}

Search With No Match Should Show Empty State
    Search Jobs    ${SEARCH_NO_MATCH_TEXT}
    Job Count Should Be    0
    Element Should Be Shown    ${EMPTY_STATE}

Clearing Search Should Show All Jobs Again
    Require Values    ${JOB_CARD}
    Search Jobs    ${SEARCH_NO_MATCH_TEXT}
    Search Jobs    ${EMPTY}
    Job Count Should Be    ${INITIAL_CARD_COUNT}

Search Should Ignore Letter Case
    Require Real Job Data
    ${title}=    First Title
    Search Jobs    ${title.lower()}
    ${lower}=    Get Displayed Titles
    Search Jobs    ${title.upper()}
    ${upper}=    Get Displayed Titles
    Titles Should Match    ${upper}    ${lower}
    List Should Contain Value    ${upper}    ${title}

# ---------- sort ----------
Sort Options Should Be Displayed
    Require Values    ${SORT_DROPDOWN}    ${SORT_OPTION}    ${SORT_OPTION_LABELS}
    Element Should Be Shown    ${SORT_DROPDOWN}
    Click Element Safe    ${SORT_DROPDOWN}
    FOR    ${label}    IN    @{SORT_OPTION_LABELS}
        ${option}=    Format Locator    ${SORT_OPTION}    label=${label}
        Element Should Be Visible    ${option}
    END

Select Sort Option
    [Arguments]    ${label}
    Require Values    ${SORT_DROPDOWN}    ${SORT_OPTION}    ${label}
    Click Element Safe    ${SORT_DROPDOWN}
    ${option}=    Format Locator    ${SORT_OPTION}    label=${label}
    Click Element Safe    ${option}
    Wait For Results

Latest Sort Should Order By Newest Posted Date
    Require Values    ${SORT_LABEL_LATEST}
    Select Sort Option    ${SORT_LABEL_LATEST}
    ${texts}=    Get Card Texts    posted
    ${ok}=    Posted Dates Are Newest First    ${texts}
    Should Be True    ${ok}    Posted dates are not newest first: ${texts}

Changing Sort Option Should Update Selection
    Require Values    ${SORT_DROPDOWN}
    ${count}=    Get Length    ${SORT_OPTION_LABELS}
    Skip If    ${count} < 2    Need at least 2 sort options in testdata/expected.py (SORT_OPTION_LABELS)
    ${label}=    Set Variable    ${SORT_OPTION_LABELS}[1]
    Select Sort Option    ${label}
    Element Should Contain    ${SORT_DROPDOWN}    ${label}
    Job Cards Should Be Displayed
