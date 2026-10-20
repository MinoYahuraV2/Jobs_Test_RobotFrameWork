*** Settings ***
Documentation     Shared setup, "skip when TODO" guards and generic keywords.
Library           SeleniumLibrary
Library           Collections
Library           String
Library           ../libraries/Helpers.py
Library           ../libraries/JobData.py
Variables         ../config/env.py
Variables         ../locators/jobs_page.py
Variables         ../testdata/expected.py


*** Keywords ***
# ---------- open / reset ----------
Open Jobs Page
    ${todo}=    Is Todo    ${BASE_URL}
    Skip If    ${todo}    BASE_URL is not set yet (waiting for dev). Run with: --variable BASE_URL:https://host
    ${options}=    Build Browser Options    ${HEADLESS}
    Open Browser    ${BASE_URL}${JOBS_PATH}    ${BROWSER}    options=${options}
    Set Selenium Timeout    ${TIMEOUT}

Go To Jobs Page
    Go To    ${BASE_URL}${JOBS_PATH}
    ${todo}=    Is Todo    ${HERO_TITLE}
    IF    not $todo
        Wait Until Element Is Visible    ${HERO_TITLE}
    END
    ${todo}=    Is Todo    ${JOB_CARD}
    ${count}=    Set Variable    ${-1}
    IF    not $todo
        ${count}=    Get Element Count    ${JOB_CARD}
    END
    Set Test Variable    ${INITIAL_CARD_COUNT}    ${count}

Wait For Results
    ${todo}=    Is Todo    ${LOADING_INDICATOR}
    IF    not $todo
        Wait Until Element Is Not Visible    ${LOADING_INDICATOR}
    END
    Sleep    ${RESULT_SETTLE}

# ---------- guards: SKIP (not fail) while a value is still TODO ----------
Require Values
    [Arguments]    @{values}
    FOR    ${value}    IN    @{values}
        ${todo}=    Is Todo    ${value}
        Skip If    ${todo}    A locator or expected value is still TODO (see locators/jobs_page.py, testdata/expected.py)
    END

Require Real Job Data
    ${placeholder}=    Job Data Is Placeholder
    Skip If    ${placeholder}    testdata/jobs.json is still PLACEHOLDER. Fill it from the real database.

# ---------- generic element keywords ----------
Click Element Safe
    [Arguments]    ${locator}
    Require Values    ${locator}
    Wait Until Element Is Visible    ${locator}
    Scroll Element Into View    ${locator}
    Click Element    ${locator}

Element Should Be Shown
    [Arguments]    ${locator}
    Require Values    ${locator}
    Wait Until Element Is Visible    ${locator}
    Scroll Element Into View    ${locator}

Element Text Should Match
    [Arguments]    ${locator}    ${expected}    ${ignore_case}=${True}
    Require Values    ${locator}    ${expected}
    Wait Until Element Is Visible    ${locator}
    ${text}=    Get Text    ${locator}
    ${text}=    Evaluate    ' '.join($text.split())
    Should Be Equal As Strings    ${text}    ${expected}    ignore_case=${ignore_case}    strip_spaces=True

Element Text Should Include
    [Arguments]    ${locator}    ${expected}
    Require Values    ${locator}    ${expected}
    Wait Until Element Is Visible    ${locator}
    Element Should Contain    ${locator}    ${expected}

Link Href Should Start With
    [Arguments]    ${locator}    ${prefix}
    Require Values    ${locator}    ${prefix}
    ${href}=    Get Element Attribute    ${locator}    href
    Should Start With    ${href}    ${prefix}

Click And Verify Destination
    [Documentation]    Click a link. Works if it opens in the same tab or a new tab.
    [Arguments]    ${locator}    ${expected_url_part}
    Require Values    ${locator}    ${expected_url_part}
    ${before}=    Get Window Handles
    Click Element Safe    ${locator}
    ${after}=    Get Window Handles
    ${opened_new}=    Evaluate    len($after) > len($before)
    IF    ${opened_new}
        Switch Window    NEW
        Wait Until Location Contains    ${expected_url_part}
        Close Window
        Switch Window    MAIN
    ELSE
        Wait Until Location Contains    ${expected_url_part}
    END
