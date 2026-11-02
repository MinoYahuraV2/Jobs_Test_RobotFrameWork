*** Settings ***
Documentation     CMS (admin) login page keywords: /admin/login.
...               The account comes from config/secrets.local.env (never from the repo).
...               Keywords that need it SKIP when the account is not set.
Resource          ../common.resource
Variables         ../../locators/login_page.py
Variables         ../../testdata/login_expected.py


*** Keywords ***
# ================= open / reset =================
Open Admin Browser
    ${options}=    Build Browser Options    ${HEADLESS}
    Open Browser    ${BASE_URL}${ADMIN_LOGIN_PATH}    ${BROWSER}    options=${options}
    Set Selenium Timeout    ${TIMEOUT}

Open Login Page
    [Documentation]    Start every test logged out, on a desktop window, on the login page.
    Delete All Cookies
    Set Window Size    1440    900
    Go To    ${BASE_URL}${ADMIN_LOGIN_PATH}
    Wait Until Element Is Visible    ${LOGIN_HEADING}

Login Page Should Be Open
    Wait Until Location Contains    ${ADMIN_LOGIN_PATH}
    Element Should Be Visible    ${LOGIN_FORM}

Require Admin Account
    Skip If    $ADMIN_EMAIL == '' or $ADMIN_PASSWORD == ''    Admin account is not set. Fill config/secrets.local.env (see secrets.local.env.example).

# ================= fill / submit =================
Fill Login Form
    [Arguments]    ${email}=${EMPTY}    ${password}=${EMPTY}
    IF    $email != ''
        Input Text    ${LOGIN_EMAIL}    ${email}
    END
    IF    $password != ''
        Input Password    ${LOGIN_PASSWORD}    ${password}
    END

Submit Login
    Click Button    ${LOGIN_SUBMIT}

Tick Remember Me
    Click Element    ${LOGIN_REMEMBER_LABEL}

Login Wrong Attempt
    [Documentation]    Fill the form with these values, press the button and wait for the red box.
    [Arguments]    ${email}    ${password}
    Fill Login Form    ${email}    ${password}
    Submit Login
    Wait Until Element Is Visible    ${LOGIN_ERROR}
    Login Page Should Be Open

Login As Admin
    [Documentation]    Fill the real account and press the button. Does not wait for any page.
    [Arguments]    ${remember}=${False}
    Require Admin Account
    Fill Login Form    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    IF    ${remember}
        Tick Remember Me
    END
    Submit Login

Login As Admin And Reach Dashboard
    [Arguments]    ${remember}=${False}
    Login As Admin    ${remember}
    Dashboard Should Be Open

Dashboard Should Be Open
    Wait Until Location Contains    ${LOGIN_DASHBOARD_PATH}    timeout=20s
    Title Should Be    ${LOGIN_DASHBOARD_TITLE}
    Wait Until Element Is Visible    ${LOGIN_LOGOUT_BUTTON}

Logout From Cms
    Click Button    ${LOGIN_LOGOUT_BUTTON}
    Wait Until Location Contains    ${ADMIN_LOGIN_PATH}    timeout=20s

# ================= checks =================
Login Error Should Be
    [Arguments]    ${text}
    Wait Until Element Is Visible    ${LOGIN_ERROR}
    Element Should Contain    ${LOGIN_ERROR}    ${text}

Login Field Validity Should Be
    [Documentation]    Browser form check. prop is a ValidityState flag, e.g. valueMissing or typeMismatch.
    [Arguments]    ${locator}    ${prop}
    ${element}=    Get WebElement    ${locator}
    ${flag}=    Execute Javascript    return arguments[0].validity.${prop};    ARGUMENTS    ${element}
    Should Be True    ${flag}    The field should have validity.${prop} but it does not

Form Should Not Have Been Sent
    [Documentation]    After a blocked submit the page stays on login and shows no server error.
    Sleep    ${RESULT_SETTLE}
    Login Page Should Be Open
    Element Should Not Be Visible    ${LOGIN_ERROR}

Login Labels Should Match
    Element Should Contain    ${LOGIN_EMAIL_LABEL}    ${LOGIN_EMAIL_LABEL_TEXT}
    Element Should Contain    ${LOGIN_PASSWORD_LABEL}    ${LOGIN_PASSWORD_LABEL_TEXT}
    Element Should Contain    ${LOGIN_EMAIL_LABEL}    *
    Element Should Contain    ${LOGIN_PASSWORD_LABEL}    *

Login Placeholders Should Match
    ${email}=    Get Element Attribute    ${LOGIN_EMAIL}    placeholder
    ${password}=    Get Element Attribute    ${LOGIN_PASSWORD}    placeholder
    Should Be Equal    ${email}    ${LOGIN_EMAIL_PLACEHOLDER}
    Should Be Equal    ${password}    ${LOGIN_PASSWORD_PLACEHOLDER}

Login Logo Should Be Loaded
    Element Should Be Visible    ${LOGIN_LOGO}
    ${element}=    Get WebElement    ${LOGIN_LOGO}
    ${width}=    Execute Javascript    return arguments[0].naturalWidth;    ARGUMENTS    ${element}
    Should Be True    ${width} > 0    The logo image did not load

Login Form Should Be Empty By Default
    ${email}=    Get Value    ${LOGIN_EMAIL}
    ${password}=    Get Value    ${LOGIN_PASSWORD}
    Should Be Empty    ${email}
    Should Be Empty    ${password}
    Checkbox Should Not Be Selected    ${LOGIN_REMEMBER}

Login Autocomplete Should Be Set
    ${email}=    Get Element Attribute    ${LOGIN_EMAIL}    autocomplete
    ${password}=    Get Element Attribute    ${LOGIN_PASSWORD}    autocomplete
    Should Be Equal    ${email}    email
    Should Be Equal    ${password}    current-password

Label Click Should Focus Field
    [Arguments]    ${label}    ${field_id}
    Click Element    ${label}
    ${active}=    Execute Javascript    return document.activeElement.id;
    Should Be Equal    ${active}    ${field_id}

Home Page Should Be Open
    Wait Until Location Contains    ${LOGIN_HOME_PATH}    timeout=15s

Logout Button Should Not Be Shown
    Page Should Not Contain Element    ${LOGIN_LOGOUT_BUTTON}

Cms Menu Should Be Shown
    Element Should Be Visible    ${LOGIN_MENU_DASHBOARD}
    Element Should Be Visible    ${LOGIN_MENU_JOBS}

# ================= wrong-attempt helpers =================
Failed Login With Changed Admin Password
    [Documentation]    how = append (real password + "x") or swapcase (same letters, other case).
    ...                The changed password is built with logging off, so it never lands in the result files.
    [Arguments]    ${how}
    Require Admin Account
    ${old}=    Set Log Level    NONE
    ${password}=    Evaluate    $ADMIN_PASSWORD + 'x' if $how == 'append' else $ADMIN_PASSWORD.swapcase()
    Set Log Level    ${old}
    Skip If    $password == $ADMIN_PASSWORD    The password has no letters, so its case cannot be changed.
    Failed Login With Password    ${password}

Login Should Not Have Entered The Cms
    Location Should Contain    ${ADMIN_LOGIN_PATH}
    Page Should Not Contain Element    ${LOGIN_LOGOUT_BUTTON}

Failed Login With Password
    [Arguments]    ${password}
    Require Admin Account
    Login Wrong Attempt    ${ADMIN_EMAIL}    ${password}
    Login Should Not Have Entered The Cms

Email Should Be Kept After Error
    Require Admin Account
    Login Wrong Attempt    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}x
    ${email}=    Get Value    ${LOGIN_EMAIL}
    Should Be Equal    ${email}    ${ADMIN_EMAIL}

Submit Button Should Show Loading While Sending
    [Documentation]    Watch the button with a page-side observer, because the loading state lasts well under a second.
    Require Admin Account
    Execute Javascript
    ...    window.__sawLoading = false; window.__loadingText = '';
    ...    var watch = function () {
    ...        var b = document.querySelector("form button[type='submit']");
    ...        if (b && b.disabled) { window.__sawLoading = true; window.__loadingText = b.innerText; }
    ...    };
    ...    new MutationObserver(watch).observe(document.body, {subtree: true, childList: true, attributes: true, characterData: true});
    Fill Login Form    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}x
    Submit Login
    Wait Until Element Is Visible    ${LOGIN_ERROR}
    ${saw}=    Execute Javascript    return window.__sawLoading;
    ${text}=    Execute Javascript    return window.__loadingText;
    Should Be True    ${saw}    The button was never disabled while the form was being sent
    Should Contain    ${text}    ${LOGIN_SUBMIT_LOADING_TEXT}
    Wait Until Element Is Enabled    ${LOGIN_SUBMIT}

# ================= session / cookies =================
Session Cookies Should Be HttpOnly
    FOR    ${name}    IN    @{LOGIN_SESSION_COOKIES}
        ${cookie}=    Get Cookie    ${name}
        Should Be True    ${cookie.httpOnly}    Cookie ${name} is readable by scripts (not HttpOnly)
    END

Cookie Days Left
    [Arguments]    ${name}
    ${cookie}=    Get Cookie    ${name}
    ${days}=    Evaluate    ($cookie.expiry - datetime.datetime.now()).total_seconds() / 86400    modules=datetime
    RETURN    ${days}

Session Should Last About
    [Arguments]    ${expected_days}
    ${days}=    Cookie Days Left    evp_access_token
    ${low}=    Evaluate    $expected_days - 1.0 if $expected_days > 1 else 0.5
    ${high}=    Evaluate    $expected_days + 1.0
    Should Be True    ${low} <= ${days} <= ${high}    The session lasts ${days} days, expected about ${expected_days}

Session Cookies Should Be Gone
    FOR    ${name}    IN    @{LOGIN_SESSION_COOKIES}
        ${cookies}=    Get Cookies
        Should Not Contain    ${cookies}    ${name}=
    END

Logged Out Page Should Ask For Login
    [Arguments]    ${path}
    Go To    ${BASE_URL}${path}
    Wait Until Location Contains    ${ADMIN_LOGIN_PATH}    timeout=15s
    Login Page Should Be Open

Login Should Remember Where You Wanted To Go
    [Arguments]    ${path}
    ${encoded}=    Evaluate    __import__('urllib.parse').parse.quote($path, safe='')
    Logged Out Page Should Ask For Login    ${path}
    Location Should Contain    next=${encoded}

Login After Redirect Should Open Dashboard
    [Documentation]    Even when the login URL carries ?next=<page>, the team wants the Dashboard after login.
    [Arguments]    ${path}
    Logged Out Page Should Ask For Login    ${path}
    Login As Admin
    Dashboard Should Be Open

Browser Back After Logout Should Not Show The Cms
    Logout From Cms
    Go Back
    Sleep    ${RESULT_SETTLE}
    Wait Until Keyword Succeeds    10s    1s    Logout Button Should Not Be Shown

# ================= keyboard / layout =================
Tab Order Should Follow The Form
    Click Element    ${LOGIN_EMAIL}
    @{ids}=    Create List
    FOR    ${i}    IN RANGE    5
        Press Keys    NONE    TAB
        ${id}=    Execute Javascript    var e = document.activeElement; return e.id || e.tagName;
        Append To List    ${ids}    ${id}
    END
    Should Be Equal    ${ids}[0]    login-password
    Should Be Equal    ${ids}[1]    login-remember
    Should Contain    ${ids}[2:]    BUTTON

Remember Me Should Toggle With Space
    Click Element    ${LOGIN_EMAIL}
    Press Keys    NONE    TAB    TAB
    ${active}=    Execute Javascript    return document.activeElement.id;
    Should Be Equal    ${active}    login-remember
    Press Keys    NONE    SPACE
    Checkbox Should Be Selected    ${LOGIN_REMEMBER}
    Press Keys    NONE    SPACE
    Checkbox Should Not Be Selected    ${LOGIN_REMEMBER}

Remember Me Should Toggle With Click
    Tick Remember Me
    Checkbox Should Be Selected    ${LOGIN_REMEMBER}
    Tick Remember Me
    Checkbox Should Not Be Selected    ${LOGIN_REMEMBER}

Login Card Should Be Centered
    [Documentation]    The form sits in the middle of the window (within 20 px).
    ${offset}=    Execute Javascript
    ...    var r = document.getElementById('login-email').form.getBoundingClientRect();
    ...    return Math.abs((r.left + r.right) / 2 - document.documentElement.clientWidth / 2);
    Should Be True    ${offset} <= 20    The login form is ${offset}px away from the window center

Login Page Should Fit A Phone Screen
    Set Window Size    375    812
    Sleep    ${RESULT_SETTLE}
    ${overflow}=    Execute Javascript    return document.documentElement.scrollWidth - document.documentElement.clientWidth;
    Should Be True    ${overflow} <= 1    The page scrolls sideways by ${overflow}px on a phone
    Element Should Be Visible    ${LOGIN_EMAIL}
    Element Should Be Visible    ${LOGIN_PASSWORD}
    Scroll Element Into View    ${LOGIN_SUBMIT}
    Element Should Be Visible    ${LOGIN_SUBMIT}
