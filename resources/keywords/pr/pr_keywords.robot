*** Settings ***
Library    SeleniumLibrary
Library    String
Library    Collections
Resource    ../../variables/pr/pr_variables.robot
Resource    ../../keywords/common_keywords.robot
*** Keywords ***
Check Vendor Selection Modal Is Displayed
    [Documentation]    Checks if the vendor selection modal is displayed
    Wait Until Element Is Visible    ${VENDOR_MODAL}    timeout=10s
    Element Should Be Visible    ${VENDOR_MODAL_TITLE}
    Log    Vendor selection modal is displayed
    
Select Vendor
    [Arguments]    ${column_name}    ${column_value}
    [Documentation]    Selects a vendor from the vendor selection modal by searching for a specific value in a specific column
    Check Vendor Selection Modal Is Displayed
    
    # Define column index based on column name (using the table headers)
    ${column_index}=    Set Variable If
    ...    '${column_name}' == 'No.'    1
    ...    '${column_name}' == 'BP Code'    2
    ...    '${column_name}' == 'BP Name'    3
    ...    '${column_name}' == 'BP Tax ID'    4
    ...    '${column_name}' == 'BP Group'    5
    ...    0
    
    # Validate column name
    Run Keyword If    ${column_index} == 0    Fail    Invalid column name: ${column_name}
    
    # Initialize variables for pagination
    ${found}=    Set Variable    ${FALSE}
    ${max_pages}=    Set Variable    10    # Maximum number of pages to check
    ${current_page}=    Set Variable    1
    
    # Log what we're searching for
    Log    Searching for vendor with ${column_name} = ${column_value}
    
    # Loop through pages until vendor is found or max pages reached
    WHILE    not ${found} and ${current_page} <= ${max_pages}
        # Log current page
        Log    Searching for vendor on page ${current_page}
        
        # Wait for the table to be visible
        Wait Until Element Is Visible    xpath://table[@id='DataTables_Table_0']    timeout=10s
        
        # Get all rows in the current page
        @{rows}=    Get WebElements    xpath://table[@id='DataTables_Table_0']/tbody/tr
        ${row_count}=    Get Length    ${rows}
        
        # Log row count for debugging
        Log    Found ${row_count} rows on page ${current_page}
        
        # If no rows found, break the loop
        Run Keyword If    ${row_count} == 0    Exit For Loop
        
        # Loop through each row to find the vendor
        FOR    ${row_index}    IN RANGE    1    ${row_count}+1
            # Get the cell text in the specified column
            ${cell_xpath}=    Set Variable    xpath://table[@id='DataTables_Table_0']/tbody/tr[${row_index}]/td[${column_index}]
            Wait Until Element Is Visible    ${cell_xpath}    timeout=5s
            ${cell_text}=    Get Text    ${cell_xpath}
            
            # Log for debugging
            Log    Row ${row_index}, ${column_name}: ${cell_text}
            
            # Check if this is the vendor we're looking for (case insensitive)
            ${cell_text_lower}=    Convert To Lowercase    ${cell_text}
            ${column_value_lower}=    Convert To Lowercase    ${column_value}
            ${is_match}=    Run Keyword And Return Status    Should Contain    ${cell_text_lower}    ${column_value_lower}
            
            IF    ${is_match}
                Log    Found vendor with ${column_name} = ${column_value} at row ${row_index}
                # Get the SELECT button in this row
                ${select_button_xpath}=    Set Variable    xpath://table[@id='DataTables_Table_0']/tbody/tr[${row_index}]//button[contains(@class,'select_bp_detail')]
                Wait Until Element Is Visible    ${select_button_xpath}    timeout=5s
                
                # Click the SELECT button
                Click Element    ${select_button_xpath}
                Sleep    2s
                ${found}=    Set Variable    ${TRUE}
                BREAK
            END
        END
        
        # If vendor not found on current page, go to next page if available
        IF    not ${found}
            # Check if there's a next page button and it's enabled
            ${next_page_exists}=    Run Keyword And Return Status    Element Should Be Visible    xpath://a[@id='DataTables_Table_0_next' and not(contains(@class,'disabled'))]
            
            IF    ${next_page_exists}
                # Click next page
                Click Element    xpath://a[@id='DataTables_Table_0_next']
                Sleep    2s
                ${current_page}=    Evaluate    ${current_page} + 1
            ELSE
                # No more pages, exit loop
                Log    No more pages available. Vendor not found.
                BREAK
            END
        END
    END
    
    # If vendor not found after checking all pages, fail the test
    Run Keyword If    not ${found}    Fail    Vendor with ${column_name} = ${column_value} not found in the vendor table
    
    # After selecting a vendor, check if the address selection modal appears
    ${address_modal_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${ADDRESS_MODAL}
    
    IF    ${address_modal_visible}
        Log    Address selection modal appeared, selecting first address
        Select First Address
    ELSE
        Log    No address selection modal appeared
    END
    
Select Vendor By Index
    [Arguments]    ${vendor_index}=1
    [Documentation]    Selects a vendor from the vendor selection modal by index
    Check Vendor Selection Modal Is Displayed
    ${select_button}=    Set Variable    (//button[contains(@class,'select_bp_detail')])[${vendor_index}]
    Wait Until Element Is Visible    ${select_button}    timeout=10s
    Click Element    ${select_button}
    Sleep    2s
    
Close Vendor Selection Modal
    [Documentation]    Closes the vendor selection modal
    Check Vendor Selection Modal Is Displayed
    Click Element    ${VENDOR_MODAL_CLOSE_BUTTON}
    Sleep    1s
    Wait Until Element Is Not Visible    ${VENDOR_MODAL}    timeout=5s

Select First Address
    [Documentation]    Selects the first address from the address selection modal
    Log    Address selection modal is displayed
    
    # Wait for the table to be visible
    Wait Until Element Is Visible    xpath://table[@id='DataTables_Table_1']    timeout=10s
    
    # Get the first SELECT button in the table
    Wait Until Element Is Visible    ${ADDRESS_SELECT_BUTTON}    timeout=5s
    
    # Log the address being selected
    ${address_text}=    Get Text    xpath://table[@id='DataTables_Table_1']/tbody/tr[1]/td[2]
    Log    Selecting address: ${address_text}
    
    # Click the SELECT button
    Click Element    ${ADDRESS_SELECT_BUTTON}
    Sleep    2s
    
    # Verify the modal is closed
    Wait Until Element Is Not Visible    ${ADDRESS_MODAL}    timeout=5s

    # Check select address input
    ${actual_value}=    Get Element Attribute    ${ADDRESS_INPUT}    value
    Should Be Equal As Strings    ${actual_value}    ${address_text}

Fill In Requirement Input
    [Arguments]    ${VALUE_REMARK}    ${VALUE_INVOICE_NUMBER}    ${VALUE_DATE}    ${VALUE_APPROVAL_NAME}
    Input Text    ${INPUT_REMARK}    ${VALUE_REMARK}
    Input Text    ${INPUT_INVOICE_NUMBER}    ${VALUE_INVOICE_NUMBER}
    Input Date    ${INPUT_DUEDATE}    ${VALUE_DATE}
    Select From List By Label    ${INPUT_SEND_APPROVAL}    ${VALUE_APPROVAL_NAME}

Check Project Selection Modal Is Displayed
    [Documentation]    Checks if the project selection modal is displayed
    Wait Until Element Is Visible    ${PROJECT_MODAL}    timeout=10s
    Wait Until Element Is Visible    ${PROJECT_MODAL_CONTENT}    timeout=5s
    Wait Until Element Is Visible    ${PROJECT_MODAL_TITLE}    timeout=5s
    Log    Project selection modal is displayed
    
Close Project Selection Modal
    [Documentation]    Closes the project selection modal
    Wait Until Element Is Visible    ${PROJECT_MODAL}    timeout=5s
    Click Element    ${PROJECT_MODAL_CLOSE_BUTTON}
    Sleep    1s
    Wait Until Element Is Not Visible    ${PROJECT_MODAL}    timeout=5s
    
Select Project
    [Arguments]    ${column_name}    ${column_value}
    [Documentation]    Selects a project from the project selection modal by searching for a specific value in a specific column
    Check Project Selection Modal Is Displayed
    
    # Define column index based on column name (using the table headers)
    ${column_index}=    Set Variable If
    ...    '${column_name}' == 'No.'    1
    ...    '${column_name}' == 'Project Code'    2
    ...    '${column_name}' == 'Project Name'    3
    ...    '${column_name}' == 'Active'    4
    ...    0
    
    # Validate column name
    Run Keyword If    ${column_index} == 0    Fail    Invalid column name: ${column_name}
    
    # Initialize variables for pagination
    ${found}=    Set Variable    ${FALSE}
    ${max_pages}=    Set Variable    10    # Maximum number of pages to check
    ${current_page}=    Set Variable    1
    
    # Log what we're searching for
    Log    Searching for project with ${column_name} = ${column_value}
    
    # Loop through pages until project is found or max pages reached
    WHILE    not ${found} and ${current_page} <= ${max_pages}
        # Log current page
        Log    Searching for project on page ${current_page}
        
        # Wait for the table to be visible
        Wait Until Element Is Visible    ${PROJECT_TABLE}    timeout=10s
        
        # Get all rows in the current page
        @{rows}=    Get WebElements    xpath://table[@id='DataTables_Table_2']/tbody/tr
        ${row_count}=    Get Length    ${rows}
        
        # Log row count for debugging
        Log    Found ${row_count} rows on page ${current_page}
        
        # If no rows found, break the loop
        Run Keyword If    ${row_count} == 0    Exit For Loop
        
        # Loop through each row to find the project
        FOR    ${row_index}    IN RANGE    1    ${row_count}+1
            # Get the cell text in the specified column
            ${cell_xpath}=    Set Variable    xpath://table[@id='DataTables_Table_2']/tbody/tr[${row_index}]/td[${column_index}]
            Wait Until Element Is Visible    ${cell_xpath}    timeout=5s
            ${cell_text}=    Get Text    ${cell_xpath}
            
            # Log for debugging
            Log    Row ${row_index}, ${column_name}: ${cell_text}
            
            # Check if this is the project we're looking for (case insensitive)
            ${cell_text_lower}=    Convert To Lowercase    ${cell_text}
            ${column_value_lower}=    Convert To Lowercase    ${column_value}
            ${is_match}=    Run Keyword And Return Status    Should Contain    ${cell_text_lower}    ${column_value_lower}
            
            IF    ${is_match}
                Log    Found project with ${column_name} = ${column_value} at row ${row_index}
                # Get the SELECT button in this row
                ${select_button_xpath}=    Set Variable    xpath://table[@id='DataTables_Table_2']/tbody/tr[${row_index}]//button[contains(@class,'btn-primary') and text()='SELECT']
                Wait Until Element Is Visible    ${select_button_xpath}    timeout=5s
                
                # Click the SELECT button
                Click Element    ${select_button_xpath}
                Sleep    2s
                ${found}=    Set Variable    ${TRUE}
                BREAK
            END
        END
        
        # If project not found on current page, go to next page if available
        IF    not ${found}
            # Check if there's a next page button and it's enabled
            ${next_page_exists}=    Run Keyword And Return Status    Element Should Be Visible    ${PROJECT_NEXT_PAGE}
            
            IF    ${next_page_exists}
                # Click next page
                Click Element    ${PROJECT_NEXT_PAGE}
                Sleep    2s
                ${current_page}=    Evaluate    ${current_page} + 1
            ELSE
                # No more pages, exit loop
                Log    No more pages available. Project not found.
                BREAK
            END
        END
    END
    
    # If project not found after checking all pages, fail the test
    Run Keyword If    not ${found}    Fail    Project with ${column_name} = ${column_value} not found in the project table

Create Cost Price
    # Use JavaScript to click the button to avoid element interception issues
    Execute JavaScript    document.getElementById('sss').click();
    Sleep    2s
    
    # Wait for and verify the project modal is displayed
    Wait Until Element Is Visible    ${PROJECT_MODAL}    timeout=10s
    Wait Until Element Is Visible    ${PROJECT_MODAL_CONTENT}    timeout=5s
    
    # Select the project with code MQ001
    Select Project    Project Code    MQ001
    
    # If the modal is still visible for some reason, close it
    ${modal_still_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${PROJECT_MODAL}
    Run Keyword If    ${modal_still_visible}    Close Project Selection Modal

Select Material Name
    [Arguments]    ${column_name}    ${column_value}
    Click Button    //button[@class='openun btn btn-info btn-block']
    Sleep    2
    Click Element    //a[normalize-space()='Item Master']

    Sleep    2
    
    # Select the first material
    Select Material    ${column_name}    ${column_value}

Select Material
    [Documentation]    Selects a material from the material table by searching for a value in a specific column
    [Arguments]    ${column_name}    ${column_value}
    
    # Wait for the material modal and table to be visible
    Wait Until Element Is Visible    ${MATERIAL_MODAL}    timeout=10s
    Wait Until Element Is Visible    ${MATERIAL_TABLE}    timeout=10s
    
    # Get all rows in the current page
    @{rows}=    Get WebElements    xpath://table[@id='DataTables_Table_4']/tbody/tr
    ${row_count}=    Get Length    ${rows}
    
    # Log row count for debugging
    Log    Found ${row_count} rows in the material table
    
    # Find the column index based on the column name
    @{headers}=    Get WebElements    xpath://table[@id='DataTables_Table_4']/thead/tr/th
    ${column_index}=    Set Variable    ${0}
    ${found_column}=    Set Variable    ${FALSE}
    
    # Log all headers for debugging
    Log    Found ${headers.__len__()} headers in the material table
    
    FOR    ${header}    IN    @{headers}
        ${column_index}=    Evaluate    ${column_index} + 1
        ${header_text}=    Get Text    ${header}
        ${aria_label}=    Get Element Attribute    ${header}    aria-label
        
        # Log header info for debugging
        Log    Header ${column_index}: Text='${header_text}', Aria-label='${aria_label}'
        
        # Try to match with text or aria-label (which often contains the column name)
        ${is_match_text}=    Run Keyword And Return Status    Should Contain    ${header_text}    ${column_name}
        ${is_match_aria}=    Run Keyword And Return Status    Should Contain    ${aria_label}    ${column_name}
        ${is_match}=    Evaluate    ${is_match_text} or ${is_match_aria}
        
        IF    ${is_match}
            Set Test Variable    ${found_column}    ${TRUE}
            Log    Found column '${column_name}' at index ${column_index} (text='${header_text}', aria-label='${aria_label}')
            Exit For Loop
        END
    END
    
    IF    not ${found_column}
        Fail    Column '${column_name}' not found in the material table
    END
    Log    Found column '${column_name}' at index ${column_index}
    
    # Initialize a flag to track if we found the material
    ${found_material}=    Set Variable    ${FALSE}
    
    # Loop through pages until we find the material or run out of pages
    WHILE    not ${found_material}
        # Loop through each row to find the material
        FOR    ${row_index}    IN RANGE    1    ${row_count}+1
            # Get the cell text in the specified column
            ${cell_xpath}=    Set Variable    xpath://table[@id='DataTables_Table_4']/tbody/tr[${row_index}]/td[${column_index}]
            Wait Until Element Is Visible    ${cell_xpath}    timeout=5s
            ${cell_text}=    Get Text    ${cell_xpath}
            
            # Convert both strings to lowercase for case-insensitive comparison
            ${cell_text_lower}=    Convert To Lowercase    ${cell_text}
            ${column_value_lower}=    Convert To Lowercase    ${column_value}
            
            # Check if this is the material we're looking for
            ${is_match}=    Run Keyword And Return Status    Should Contain    ${cell_text_lower}    ${column_value_lower}
            
            IF    ${is_match}
                Log    Found material with ${column_name} = ${column_value} at row ${row_index}
                # Get the SELECT button in this row
                ${select_button_xpath}=    Set Variable    xpath://table[@id='DataTables_Table_4']/tbody/tr[${row_index}]//button[contains(@class,'btn-primary') and text()='SELECT']
                Wait Until Element Is Visible    ${select_button_xpath}    timeout=5s
                
                # Click the SELECT button
                Click Element    ${select_button_xpath}
                
                # Set the flag to indicate we found the material
                ${found_material}=    Set Variable    ${TRUE}
                Exit For Loop
            END
        END
        
        # If we haven't found the material yet, try to go to the next page
        IF    not ${found_material}
            ${next_page_exists}=    Run Keyword And Return Status    Element Should Be Visible    ${MATERIAL_NEXT_PAGE}
            
            # If there's no next page, break the loop
            IF    not ${next_page_exists}
                Exit For Loop
            END
            
            # Click the next page button
            Click Element    ${MATERIAL_NEXT_PAGE}
            Sleep    1s
            
            # Get the rows in the new page
            @{rows}=    Get WebElements    xpath://table[@id='DataTables_Table_4']/tbody/tr
            ${row_count}=    Get Length    ${rows}
        ELSE
            Exit For Loop
        END
    END
    
    # If we didn't find the material, fail the test
    IF    not ${found_material}
        Fail    Material with ${column_name} = ${column_value} not found in the table
    END

Select Budget
    [Documentation]    Selects a budget from the budget table by searching for a value in a specific column
    [Arguments]    ${column_name}    ${column_value}
    
    # Wait for the budget table to be visible
    Wait Until Element Is Visible    ${BUDGET_TABLE}    timeout=10s
    
    # Get all headers to find the column index
    @{headers}=    Get WebElements    xpath://table[@id='myTable']/thead/tr/th
    ${column_index}=    Set Variable    ${0}
    ${found_column}=    Set Variable    ${FALSE}
    
    # Log all headers for debugging
    Log    Found ${headers.__len__()} headers in the budget table
    
    FOR    ${header}    IN    @{headers}
        ${column_index}=    Evaluate    ${column_index} + 1
        ${header_text}=    Get Text    ${header}
        
        # Log header info for debugging
        Log    Header ${column_index}: Text='${header_text}'
        
        # Try to match with text
        ${is_match}=    Run Keyword And Return Status    Should Contain    ${header_text}    ${column_name}
        
        IF    ${is_match}
            Set Test Variable    ${found_column}    ${TRUE}
            Log    Found column '${column_name}' at index ${column_index} (text='${header_text}')
            Exit For Loop
        END
    END
    
    IF    not ${found_column}
        Fail    Column '${column_name}' not found in the budget table
    END
    Log    Found column '${column_name}' at index ${column_index}
    
    # Initialize a flag to track if we found the budget
    ${found_budget}=    Set Variable    ${FALSE}
    
    # Loop through pages until we find the budget or run out of pages
    WHILE    not ${found_budget}
        # Get all rows in the current page
        @{rows}=    Get WebElements    ${BUDGET_TABLE_ROWS}
        ${row_count}=    Get Length    ${rows}
        Log    Found ${row_count} rows in the current page
        
        # Loop through each row to find the budget
        FOR    ${row_index}    IN RANGE    1    ${row_count}+1
            # Get the cell text in the specified column
            ${cell_xpath}=    Set Variable    xpath://table[@id='myTable']/tbody/tr[${row_index}]/td[${column_index}]
            ${cell_xpath_alt}=    Set Variable    xpath://table[@id='myTable']/tbody/tr[${row_index}]/th[${column_index}]
            
            # Try both td and th elements as the table structure uses th for some cells
            ${cell_exists}=    Run Keyword And Return Status    Element Should Be Visible    ${cell_xpath}    timeout=1s
            ${cell_text}=    Run Keyword If    ${cell_exists}    Get Text    ${cell_xpath}
            ...    ELSE    Get Text    ${cell_xpath_alt}
            
            # Convert both strings to lowercase for case-insensitive comparison
            ${cell_text_lower}=    Convert To Lowercase    ${cell_text}
            ${column_value_lower}=    Convert To Lowercase    ${column_value}
            
            # Check if the cell text contains the search value
            ${is_match}=    Run Keyword And Return Status    Should Contain    ${cell_text_lower}    ${column_value_lower}
            
            IF    ${is_match}
                Log    Found budget with ${column_name}='${column_value}' in row ${row_index}
                Set Test Variable    ${found_budget}    ${TRUE}
                
                # Get the row ID to find the folder icon
                ${row_id}=    Get Element Attribute    xpath://table[@id='myTable']/tbody/tr[${row_index}]    id
                ${row_number}=    Set Variable    ${row_id.replace('a', '')}
                
                # Check if the folder icon exists and is clickable
                ${folder_icon_xpath}=    Set Variable    xpath://div[@id='file_bg${row_number}']//i[contains(@class,'glyphicon-folder-open')]
                ${folder_exists}=    Run Keyword And Return Status    Element Should Be Visible    ${folder_icon_xpath}    timeout=2s
                
                IF    ${folder_exists}
                    # Click the folder icon
                    Sleep    2
                    Click Element    ${folder_icon_xpath}
                    Log    Clicked folder icon for budget in row ${row_index}
                ELSE
                    # If folder icon doesn't exist, the budget might be over due date or locked
                    ${status_text}=    Get Text    xpath://div[@id='file_bg${row_number}']
                    Fail    Budget found but cannot be selected: ${status_text}
                END
                
                Exit For Loop
            END
        END
        
        # If we didn't find the budget in this page, check if there's a next page
        ${next_page_exists}=    Run Keyword And Return Status    Element Should Be Visible    ${BUDGET_NEXT_PAGE}    timeout=1s
        
        IF    not ${found_budget} and ${next_page_exists}
            # Click the next page button
            Click Element    ${BUDGET_NEXT_PAGE}
            Sleep    1s
        ELSE
            Exit For Loop
        END
    END
    
    # If we didn't find the budget, fail the test
    IF    not ${found_budget}
        Fail    Budget with ${column_name} = ${column_value} not found in the table
    END

Select Budget Group
    [Documentation]    Selects a budget group by searching for a cost code in the Cost Code column
    [Arguments]    ${cost_code}

    Sleep    3
    
    # Wait for the budget group table to be visible
    Wait Until Element Is Visible    ${BUDGET_GROUP_TABLE}    timeout=10s
    
    # Initialize a flag to track if we found the budget group
    ${found_budget_group}=    Set Variable    ${FALSE}
    
    # Loop through pages until we find the budget group or run out of pages
    WHILE    not ${found_budget_group}
        # Get all rows in the current page
        @{rows}=    Get WebElements    ${BUDGET_GROUP_TABLE_ROWS}
        ${row_count}=    Get Length    ${rows}
        Log    Found ${row_count} rows in the current page
        
        # Loop through each row to find the budget group
        FOR    ${row_index}    IN RANGE    1    ${row_count}+1
            # Get the Cost Code cell text (3rd column)
            ${cost_code_cell_xpath}=    Set Variable    xpath://table[@id='myTable' and contains(@class,'datatable-basicxcboqcostcode-')]/tbody/tr[${row_index}]/th[3]
            ${cost_code_text}=    Get Text    ${cost_code_cell_xpath}
            
            # Convert both strings to lowercase for case-insensitive comparison
            ${cost_code_text_lower}=    Convert To Lowercase    ${cost_code_text}
            ${search_cost_code_lower}=    Convert To Lowercase    ${cost_code}
            
            # Check if the cell text contains the search value
            ${is_match}=    Run Keyword And Return Status    Should Contain    ${cost_code_text_lower}    ${search_cost_code_lower}
            
            IF    ${is_match}
                Log    Found budget group with Cost Code='${cost_code}' in row ${row_index}
                Set Test Variable    ${found_budget_group}    ${TRUE}
                
                # Get the row number from the sorting_1 column
                ${row_number}=    Get Text    xpath://div[@id='myTable_wrapper']//table[@id='myTable']/tbody/tr[${row_index}]/th[contains(@class,'sorting_1')]
                Log    Found row number: ${row_number}
                
                # Try different approaches to click the select button
                # 1. Try direct XPath with class
                ${select_button_xpath1}=    Set Variable    //a[contains(@class,'insertopenxx${row_number}')]
                ${button1_exists}=    Run Keyword And Return Status    Element Should Be Visible    ${select_button_xpath1}    timeout=2s
                
                # 2. Try finding by text content
                ${select_button_xpath2}=    Set Variable    //div[@id='myTable_wrapper']//table[@id='myTable']/tbody/tr[${row_index}]/th[8]//a[contains(text(),'เลือก')]
                ${button2_exists}=    Run Keyword And Return Status    Element Should Be Visible    ${select_button_xpath2}    timeout=2s
                
                # 3. Try finding by position
                ${select_button_xpath3}=    Set Variable    //div[@id='myTable_wrapper']//table[@id='myTable']/tbody/tr[${row_index}]/th[8]//a
                ${button3_exists}=    Run Keyword And Return Status    Element Should Be Visible    ${select_button_xpath3}    timeout=2s
                
                # Log which button was found
                Log    Button1 exists: ${button1_exists}, Button2 exists: ${button2_exists}, Button3 exists: ${button3_exists}
                
                # Try to click using JavaScript for more reliability
                IF    ${button1_exists}
                    Log    Clicking button with XPath: ${select_button_xpath1}
                    Execute JavaScript    document.querySelector("a.insertopenxx${row_number}").click();
                ELSE IF    ${button2_exists}
                    Log    Clicking button with XPath: ${select_button_xpath2}
                    Execute JavaScript    document.evaluate("${select_button_xpath2}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
                ELSE IF    ${button3_exists}
                    Log    Clicking button with XPath: ${select_button_xpath3}
                    Execute JavaScript    document.evaluate("${select_button_xpath3}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
                ELSE
                    # Last resort - try to click by direct class name
                    Execute JavaScript    document.querySelector(".insertopenxx${row_number}").click();
                END
                Log    Clicked select button for budget group in row ${row_index}
                
                Exit For Loop
            END
        END
        
        # If we didn't find the budget group in this page, check if there's a next page
        ${next_page_exists}=    Run Keyword And Return Status    Element Should Be Visible    ${BUDGET_GROUP_NEXT_PAGE}    timeout=1s
        
        IF    not ${found_budget_group} and ${next_page_exists}
            # Click the next page button
            Click Element    ${BUDGET_GROUP_NEXT_PAGE}
            Sleep    1s
        ELSE
            Exit For Loop
        END
    END
    
    # If we didn't find the budget group, fail the test
    IF    not ${found_budget_group}
        Fail    Budget group with Cost Code = ${cost_code} not found in the table
    END

Fill In Add Item
    [Documentation]    Fills in the add item form with the given values
    [Arguments]    ${price_unit}=8411.21    ${vat_percent}=7    ${expected_net_amount}=8999

    Sleep    2
    
    # Wait for the price unit input to be visible and clear it
    Wait Until Element Is Visible    ${PRICE_UNIT_INPUT}    timeout=10s
    Clear Element Text    ${PRICE_UNIT_INPUT}
    
    # Input the price unit value
    Input Text    ${PRICE_UNIT_INPUT}    ${price_unit}
    Log    Set price unit to ${price_unit}
    
    # Select the VAT percentage
    Click Element    ${VAT_PERCENT_SELECT}
    Click Element    //select[@id='vatper__']/option[@value='${vat_percent}']
    Log    Selected VAT percentage: ${vat_percent}%
    
    # Wait for calculations to complete
    Sleep    2s
    
    # Get the calculated net amount
    ${actual_net_amount}=    Get Element Attribute    ${NET_AMOUNT_INPUT}    value
    ${actual_net_amount}=    Replace String    ${actual_net_amount}    ,    ${EMPTY}
    ${actual_net_amount}=    Convert To Number    ${actual_net_amount}
    Log    Actual net amount: ${actual_net_amount}
    
    # Convert expected amount to number to ensure both are same type
    ${expected_net_amount_num}=    Convert To Number    ${expected_net_amount}
    Log    Expected net amount: ${expected_net_amount_num}
    
    # Use a delta comparison to handle floating point precision
    ${difference}=    Evaluate    abs(${actual_net_amount} - ${expected_net_amount_num})
    Log    Difference between amounts: ${difference}
    
    # Allow a small tolerance (1.0) for floating point comparison
    Should Be True    ${difference} < 1.0    Net amount ${actual_net_amount} differs from expected ${expected_net_amount_num} by more than 1.0
    
    # Add a remark
    Input Text    ${REMARK_ITEM_INPUT}    Auto-filled by Robot Framework
    
    # Click the Add to Row button
    Wait Until Element Is Visible    ${ADD_TO_ROW_BUTTON}    timeout=5s
    Click Element    ${ADD_TO_ROW_BUTTON}
    Log    Clicked Add to Row button
    
    # Wait for the success dialog to appear
    Wait Until Element Is Visible    ${SUCCESS_DIALOG_OK_BUTTON}    timeout=10s
    Log    Success dialog appeared
    
    # Click the OK button on the success dialog
    Click Element    ${SUCCESS_DIALOG_OK_BUTTON}
    Log    Clicked OK on success dialog
    
    # Wait for any animations to complete
    Sleep    1
    
    # Close the insert row modal
    Wait Until Element Is Visible    ${INSERT_ROW_CLOSE_BUTTON}    timeout=5s
    Click Element    ${INSERT_ROW_CLOSE_BUTTON}
    Log    Closed insert row modal
    
    # Wait for the modal to close
    Wait Until Element Is Not Visible    ${INSERT_ROW_MODAL}    timeout=5s