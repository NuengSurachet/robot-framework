*** Settings ***
Library    SeleniumLibrary
Resource    ./auth/login_keywords.robot
Resource    ../page_objects/auth/logout_page.robot

*** Keywords ***
Login To Application
    [Arguments]    ${username}=${USERNAME}    ${password}=${PASSWORD}
    login_keywords.Open Browser To Login Page
    login_keywords.Input Login Credentials    ${username}    ${password}
    login_keywords.Click Login Button

Logout From Application
    Sleep    5s
    Click Element    ${AVATAR_PROFILE}
    Click Element    ${LOGOUT_BUTTON}
    Wait Until Page Contains    Login
    Page Should Contain    Login
    Close All Browsers
