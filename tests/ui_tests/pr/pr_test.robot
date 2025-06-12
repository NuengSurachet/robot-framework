*** Settings ***
Documentation    Test suite for PR functionality
Resource    ../../../resources/keywords/common_keywords.robot
Resource    ../../../resources/keywords/pr/pr_keywords.robot
Test Setup    Login To Application
Test Teardown    Logout From Application

*** Test Cases ***
Create PR
    Select Company    ICON - ICON Framework Co.,Ltd.
    Select Menu    ${PR_MENU}

    Click Element    ${PR_LIST_MENU}

    # Check if PR type dropdown is visible and select value
    Wait Until Element Is Visible    ${PR_TYPE_DOCUMENT}
    Select From List By Value    ${PR_TYPE_DOCUMENT}    7
    
    # Check if vendor selection modal is displayed
    Check Vendor Selection Modal Is Displayed
    
    # Select the first vendor from the list
    Select Vendor    BP Code    M-V1
    Select First Address