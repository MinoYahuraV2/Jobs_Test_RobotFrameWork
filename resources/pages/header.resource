*** Settings ***
Documentation     Header keywords (logo, menu, Eventthai.com button, language).
Resource          ../common.resource


*** Keywords ***
Header Menu Should Be Complete
    FOR    ${key}    ${label}    IN    &{NAV_LABELS}
        Element Text Should Match    ${NAV}[${key}]    ${label}
    END

Click Header Menu And Verify Destination
    [Arguments]    ${key}
    Click And Verify Destination    ${NAV}[${key}]    ${LINKS}[${key}]

Eventthai Button Should Link To Website
    Element Text Should Match    ${BTN_EVENTTHAI}    ${BTN_EVENTTHAI_TEXT}
    Click And Verify Destination    ${BTN_EVENTTHAI}    ${LINKS}[eventthai]

Switch Language And Verify
    [Arguments]    ${lang}
    Click Element Safe    ${LANG_SWITCH}[${lang}]
    Element Text Should Match    ${HERO_TITLE}    ${HERO_TITLE_BY_LANG}[${lang}]
