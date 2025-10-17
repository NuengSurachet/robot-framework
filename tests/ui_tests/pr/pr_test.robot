*** Settings ***
Documentation    Test suite for PR functionality
Resource    ../../../resources/keywords/common_keywords.robot
Resource    ../../../resources/keywords/pr/pr_keywords.robot
Test Setup    Login To Application
#Test Teardown    Logout From Application

*** Test Cases ***
Create PR
    Disable Automatic Screenshots
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

    ${today}=    Get Today Date
    Fill In Requirement Input    Test remark for PR    1235    ${today}    test test
    
    # Use data-driven approach with test case data
    # Create Cost Price
    # Select Material Name    Item Code    A0010004
    # Select Budget    Budget Code    G202405290    2
    # Select Budget Group    A0201 - A0201001
    # Fill In Add Item
    # Use JSON data-driven approach
    Process PR Items From Json Case    ${EXECDIR}/data/test_data/pr_data/pr_data.json    case_1
    Validate Total Amount    ${EXECDIR}/data/test_data/pr_data/pr_data.json    case_1