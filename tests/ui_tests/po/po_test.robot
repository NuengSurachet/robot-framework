*** Settings ***
Documentation    Test suite for PR functionality
Resource    ../../../resources/keywords/common_keywords.robot
Resource    ../../../resources/keywords/pr/pr_keywords.robot
Test Setup    Login To Application
#Test Teardown    Logout From Application

*** Test Cases ***
Create PO
    Disable Automatic Screenshots
    Select Company    ICON - ICON Framework Co.,Ltd.
    Select Menu    ${PR_MENU}

    Click Element    ${PR_LIST_MENU}

    # Check if PR type dropdown is visible and select value
    Wait Until Element Is Visible    ${PR_TYPE_DOCUMENT}
    Select From List By Value    ${PR_TYPE_DOCUMENT}    2
    Input Text    xpath=//input[@id='c']    text Po Remark
    Input Text    xpath=//input[@id='place']    ทดสอบที่อยู่
    Click Element    xpath=//div[@class='col-md-6']//div[@class='col-md-6']//i[@class='icon-user']
    Click Element    xpath=//div[@class='col-md-6']//div[@class='col-md-6']//i[@class='icon-user']
    Select From List By Index    xpath=//select[@id='dimension']    12
    Select From List By Index    xpath=//select[@id='sendapprove']    5
    #Click Element    xpath=//select[@id='dimension']
    Scroll Element Into View    locator=xpath=//a[@id='sss']
    Execute JavaScript    window.scrollBy(0, 3000)
    Click Element    locator=xpath=//a[@id='sss']
    Sleep    5
    Click Element    xpath=//button[@class='openproj10 btn btn-xs btn-block btn-primary']
    Click Element    xpath=//button[@data-target="#opnewmat"]
    # Select by index (first option = 0, second = 1, etc)
    Sleep    50000