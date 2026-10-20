*** Settings ***
Documentation     Footer keywords.
Resource          ../common.resource


*** Keywords ***
Footer Should Show All Sections
    Element Should Be Shown    ${FOOTER}
    FOR    ${key}    ${title}    IN    &{FOOTER_HEADINGS}
        Element Text Should Match    ${FOOTER_SECTION}[${key}]    ${title}
    END
    Element Text Should Include    ${FOOTER_COMPANY_INFO}    ${FOOTER_COMPANY_NAME}

Footer Link Should Navigate
    [Arguments]    ${key}
    Element Text Should Match    ${FOOTER_LINK}[${key}]    ${FOOTER_LINK_TEXT}[${key}]
    Click And Verify Destination    ${FOOTER_LINK}[${key}]    ${LINKS}[${key}]

Footer Email Should Be Correct And Clickable
    Element Text Should Match    ${FOOTER_EMAIL_LINK}    ${FOOTER_EMAIL}
    Link Href Should Start With    ${FOOTER_EMAIL_LINK}    mailto:

Footer Phone Should Be Correct And Clickable
    Element Text Should Match    ${FOOTER_PHONE_LINK}    ${FOOTER_PHONE}
    Link Href Should Start With    ${FOOTER_PHONE_LINK}    tel:

Footer Copyright Should Be Correct
    Element Text Should Include    ${FOOTER_COPYRIGHT_TEXT}    ${FOOTER_COPYRIGHT}
