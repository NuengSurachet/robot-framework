*** Settings ***
Documentation    Test suite for login functionality
Resource    ../../../resources/keywords/auth/login_keywords.robot
Resource    ../../../resources/keywords/common_keywords.robot
Test Setup    Open Browser To Login Page
Test Teardown    Close All Browsers

*** Test Cases ***
Valid Login
    Input Login Credentials
    Click Login Button
    Logout From Application

Invalid Login
    Input Login Credentials    invalid_user    invalid_password
    Click Login Button
    Sleep    5s
    Wait Until Page Contains    Login Error.
    Page Should Contain    Login Error.
