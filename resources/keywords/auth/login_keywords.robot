*** Settings ***
Library    SeleniumLibrary
Resource    ../../variables/common_variables.robot
Resource    ../../variables/auth/credentials.robot
Resource    ../../page_objects/auth/login_page.robot

*** Keywords ***
Open Browser To Login Page
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Page Should Contain    ${URL}

Input Login Credentials
    [Arguments]    ${username}=${USERNAME}    ${password}=${PASSWORD}
    Input Text    ${EMAIL_FIELD}    ${username}
    Input Password    ${PASSWORD_FIELD}    ${password}

Click Login Button
    Click Element    ${LOGIN_BUTTON}
