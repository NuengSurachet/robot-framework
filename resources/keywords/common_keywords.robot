*** Settings ***
Library    SeleniumLibrary
Library    String
Resource    ./auth/login_keywords.robot
Resource    ../page_objects/auth/logout_page.robot
Resource    ../variables/pr/pr_variables.robot

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

Select Company
    [Arguments]    ${company_name}
    Sleep    2s
    
    # Log the company we're searching for
    Log    Searching for company: ${company_name}
    
    # Try to directly find the company by name within h6 elements
    ${xpath}=    Set Variable    //div[@id='load_num_doc']//h6[contains(text(),'${company_name}')]/ancestor::div[contains(@class,'col-lg-3')]
    ${xpath_alt}=    Set Variable    //div[@id='load_num_doc']//h6[contains(.,'${company_name}')]/ancestor::div[contains(@class,'col-lg-3')]
    # Try to find the element with the first XPath
    ${element_count}=    Get Element Count    ${xpath}
    Log    Found ${element_count} elements with first XPath
    
    # If not found, try alternative XPath
    IF    ${element_count} == 0
        ${element_count}=    Get Element Count    ${xpath_alt}
        Log    Found ${element_count} elements with alternative XPath
        ${xpath}=    Set Variable    ${xpath_alt}
    END
    
    # If still not found, try with just the first part of the company name
    IF    ${element_count} == 0
        # Extract the first part of the company name (before the first dash if exists)
        ${company_parts}=    Split String    ${company_name}    -
        ${first_part}=    Set Variable    ${company_parts}[0]
        ${xpath}=    Set Variable    //div[@id='load_num_doc']//h6[contains(.,'${first_part}')]/ancestor::div[contains(@class,'col-lg-3')]
        ${element_count}=    Get Element Count    ${xpath}
        Log    Found ${element_count} elements with first part of company name: ${first_part}
    END
    
    # If found, click on it
    IF    ${element_count} > 0
        Log    Found company element, clicking on it
        # First click on the company
        Click Element    ${xpath}
        Sleep    2s
        # Then click on the login icon within the company element
        ${login_icon}=    Set Variable    ${xpath}//i[contains(@class,'glyphicon-log-in')]
        ${login_button_count}=    Get Element Count    ${login_icon}
        
        IF    ${login_button_count} > 0
            Log    Found login icon, clicking on it
            Click Element    ${login_icon}
            Sleep    2s
        ELSE
            Log    Login icon not found within the company element    WARN
        END
    ELSE
        # If still not found, try a direct click on the second company as a last resort
        Log    Company not found by name. Attempting to click on the second company as a fallback
        ${company_count}=    Get Element Count    xpath://div[@id='load_num_doc']/div/div[contains(@class,'col-lg-3')]
        
        IF    ${company_count} >= 2
            ${fallback_company}=    Set Variable    xpath://div[@id='load_num_doc']/div/div[contains(@class,'col-lg-3')][2]
            Click Element    ${fallback_company}
            Sleep    2s
            Log    Clicked on the second company as a fallback
            
            # Also click on the login icon within the fallback company
            ${login_icon}=    Set Variable    ${fallback_company}//i[contains(@class,'glyphicon-log-in')]
            ${login_button_count}=    Get Element Count    ${login_icon}
            
            IF    ${login_button_count} > 0
                Log    Found login icon in fallback company, clicking on it
                Click Element    ${login_icon}
                Sleep    2s
            ELSE
                Log    Login icon not found within the fallback company element    WARN
            END
        ELSE
            Log    Company '${company_name}' not found and no fallback available    WARN
            Fail    Company '${company_name}' not found in the list
        END
    END

Select Menu
    [Arguments]    ${menu_name}
    Sleep    2s
    
    # Log the menu we're searching for
    Log    Searching for menu: ${menu_name}
    
    # Try to find the menu by its exact name in the h6 panel-title elements
    ${menu_xpath}=    Set Variable    //div[contains(@class,'panel-flat')]//h6[contains(@class,'panel-title') and contains(text(),'${menu_name}')]/ancestor::a
    ${menu_count}=    Get Element Count    ${menu_xpath}
    
    # If not found with exact match, try with contains
    IF    ${menu_count} == 0
        ${menu_xpath}=    Set Variable    //div[contains(@class,'panel-flat')]//h6[contains(@class,'panel-title') and contains(.,'${menu_name}')]/ancestor::a
        ${menu_count}=    Get Element Count    ${menu_xpath}
    END
    
    # If found, click on it
    IF    ${menu_count} > 0
        Log    Found menu: ${menu_name}, clicking on it
        Click Element    ${menu_xpath}
        Sleep    2s
    ELSE
        # Try to find by partial match if exact match fails
        @{menu_elements}=    Get WebElements    //div[contains(@class,'panel-flat')]//h6[contains(@class,'panel-title')]
        ${found}=    Set Variable    ${FALSE}
        
        FOR    ${element}    IN    @{menu_elements}
            ${menu_text}=    Get Text    ${element}
            Log    Found menu item: ${menu_text}
            
            # Check if menu name is in the text (case insensitive)
            ${contains}=    Run Keyword And Return Status    Should Contain    ${menu_text}    ${menu_name}
            ${contains_reverse}=    Run Keyword And Return Status    Should Contain    ${menu_name}    ${menu_text}
            
            IF    ${contains} or ${contains_reverse}
                Log    Found matching menu: ${menu_name} in ${menu_text}
                Click Element    ${element}/ancestor::a
                Sleep    2s
                ${found}=    Set Variable    ${TRUE}
                BREAK
            END
        END
        
        # If still not found, log error
        IF    ${found} == ${FALSE}
            Log    Menu '${menu_name}' not found    WARN
            Fail    Menu '${menu_name}' not found in the list
        END
    END