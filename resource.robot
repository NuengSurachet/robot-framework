*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}    https://std-cm-test.iconrem.com/
${USER}    xpath=//input[@id='inputEmail']
${PASS}    xpath=//input[@id='inputPassword']

*** Keywords ***
loginCM
    [Arguments]  ${kw1}   ${kw2}
    log  ${kw1}  
    log  ${kw2}   
    Open Browser  ${URL}    chrome
    Sleep    6
    Input Text    ${USER}    ${kw1}
    Input Text    ${PASS}    ${kw2}
    Click Element    xpath=//button[@id='login_id']
    