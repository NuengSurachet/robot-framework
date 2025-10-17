*** Settings ***
Documentation    Test suite for PR functionality
Resource    ../../../resources/keywords/common_keywords.robot
Resource    ../../../resources/keywords/pr/pr_keywords.robot
Test Setup    Login To Application
#Test Teardown    Logout From Application

*** Test Cases ***
Create Settings
    Disable Automatic Screenshots
     Sleep    1
    Select Company    ICON - ICON Framework Co.,Ltd.
    Select Menu    ระบบจัดการข้อมูลกลาง
    Click Element    xpath=//li[@id='sh_1']//a[@class='has-ul']
    Scroll Element Into View    locator=xpath=//span[normalize-space()='Setup Document Numbering']
    Click Element    xpath=//span[normalize-space()='Setup Document Numbering']
    Click Element    xpath=//a[normalize-space()='Transaction']
    Click Element    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/div[2]/div[1]/table[1]/tbody[1]/tr[2]/td[3]/a[1]
    Click Element    xpath=//tbody/tr[1]/td[9]/a[1]
    Execute JavaScript    window.scrollBy(0, 3000)
   #Click Element    xpath=//a[@class='new_serial btn bg-info']
    Input Text    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[3]/input[1]    PO2507
    Input Text    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[4]/input[1]    PO
    Click Element    locator=xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[5]/select[1]
    Press Keys    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[5]/select[1]    ARROW_DOWN
    Input Text    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[6]/input[1]    4
    Input Text    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[7]/input[1]    1
    Input Text    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[8]/input[1]    9999
    Select From List By Value    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[9]/select[1]    2025-07
    Scroll Element Into View    locator=xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/button[1]
    Execute JavaScript    window.scrollBy(8000, 0)
    Click Element    locator=xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[1]/div[1]/button[1]
    Sleep    1
    Click Element    locator=xpath=//button[@class='confirm']
    Sleep    3
    Click Element    xpath=//span[normalize-space()='Setup Document Numbering']
     Sleep    1
    Click Element    xpath=//a[normalize-space()='Transaction']
     Sleep    1
    Click Element    locator=xpath=//tbody/tr[6]/td[3]/a[1]
    Click Element    locator=xpath=//tbody/tr[2]/td[9]/a[1]
    Execute JavaScript    window.scrollBy(0, 3000)
    Click Element    xpath=//a[@class='new_serial btn bg-info']
    Input Text    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[3]/input[1]    GR2506
    Input Text    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[4]/input[1]    GR
    Click Element    locator=xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[5]/select[1]
    Press Keys    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[5]/select[1]    ARROW_DOWN
    Input Text    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[6]/input[1]    4
    Input Text    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[7]/input[1]    1
    Input Text    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[8]/input[1]    9999
    Select From List By Value    xpath=/html[1]/body[1]/div[4]/div[1]/div[3]/div[1]/div[1]/div[1]/div[1]/div[2]/div[1]/div[1]/div[1]/table[1]/tbody[1]/tr[40]/td[9]/select[1]    2025-07
    Execute JavaScript    window.scrollBy(4000, 0)
    Scroll Element Into View    locator=xpath=//button[@id='saver']
    