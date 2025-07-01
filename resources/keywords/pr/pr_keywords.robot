*** Settings ***
Library    SeleniumLibrary
Library    String
Library    Collections
Library    OperatingSystem
Resource    ../../variables/pr/pr_variables.robot
Resource    ../../keywords/common_keywords.robot

*** Keywords ***

Load Json Data
    [Documentation]    Loads JSON data from a file
    [Arguments]    ${json_file_path}
    
    ${json_content}=    Get File    ${json_file_path}
    ${json_data}=    Evaluate    json.loads('''${json_content}''')    json
    
    RETURN    ${json_data}

Process PR Items From Json Case
    [Documentation]    Processes PR items from a JSON test case
    [Arguments]    ${json_file_path}    ${case_name}
    
    # Load JSON data
    ${json_data}=    Load Json Data    ${json_file_path}
    
    # Check if the case exists in the JSON data
    ${case_exists}=    Run Keyword And Return Status    Should Contain    ${json_data}[test_cases]    ${case_name}
    
    IF    ${case_exists}
        ${case_data}=    Set Variable    ${json_data}[test_cases][${case_name}]
        ${items}=    Set Variable    ${case_data}[items]
        
        Log    Processing items from JSON case: ${case_name}
        Log    Description: ${case_data}[description]
        
        # Loop through each item
        FOR    ${item}    IN    @{items}
            Sleep    2
            Log    Processing item: ${item}
            Process Single PR Item From Json    ${item}
        END
    ELSE
        Fail    Test case '${case_name}' not found in JSON data.
    END

Process Single PR Item From Json
    [Documentation]    Processes a single PR item from JSON data
    [Arguments]    ${item}
    
    # Extract item details
    ${no}=    Set Variable    ${item}[no]
    ${qty}=    Set Variable    ${item}[qty]
    ${unit_price}=    Set Variable    ${item}[unit_price]
    ${net_amount}=    Set Variable    ${item}[net_amount]
    
    Log    Processing item #${no}: Qty=${qty}, Unit Price=${unit_price}, Net Amount=${net_amount}
    
    # Process the item - with enhanced error handling
    Wait Until Page Contains Element    id=sss    timeout=10s
    
    # Use JavaScript to click the button to avoid element interception issues
    Execute JavaScript    document.getElementById('sss').click();
    Sleep    2s
    
    # Wait for and verify the project modal is displayed with longer timeout
    Wait Until Element Is Visible    ${PROJECT_MODAL}    timeout=15s
    Wait Until Element Is Visible    ${PROJECT_MODAL_CONTENT}    timeout=10s
    
    # Make sure the project table is visible with longer timeout
    Wait Until Element Is Visible    ${PROJECT_TABLE}    timeout=15s
    
    # Select the project with code MQ001
    Select Project    Project Code    MQ001
    
    # If the modal is still visible for some reason, close it
    ${modal_still_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${PROJECT_MODAL}
    Run Keyword If    ${modal_still_visible}    Close Project Selection Modal
    
    # Continue with the rest of the process
    Select Material Name    Item Code    A0010004
    Select Budget    Budget Code    G202405290    2
    Select Budget Group    A0201 - A0201001
    Fill In Add Item    ${unit_price}    7    ${net_amount}
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
    
    # Select the 3rd option from the dimension dropdown
    Wait Until Element Is Visible    ${INPUT_DIMENSION}    timeout=5s
    ${options}=    Get WebElements    ${INPUT_DIMENSION}/option
    
    # Log the number of options found for debugging
    ${option_count}=    Get Length    ${options}
    Log    Found ${option_count} options in the dimension dropdown
    
    # Get the 3rd option (index 2 since we're 0-indexed)
    ${target_index}=    Set Variable    2
    
    # Make sure we have enough options
    IF    ${option_count} > ${target_index}
        # Get the value and text of the 3rd option
        ${option_value}=    Get Element Attribute    ${options}[${target_index}]    value
        ${option_text}=    Get Text    ${options}[${target_index}]
        
        # Select the option
        Select From List By Value    ${INPUT_DIMENSION}    ${option_value}
        Log    Selected dimension option: ${option_text} (${option_value})
    END
    
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
        
        # Get all rows in the current page - using the dynamic PROJECT_TABLE variable
        @{rows}=    Get WebElements    ${PROJECT_TABLE}/tbody/tr
        ${row_count}=    Get Length    ${rows}
        
        # Log row count for debugging
        Log    Found ${row_count} rows on page ${current_page}
        
        # If no rows found, break the loop
        Run Keyword If    ${row_count} == 0    Exit For Loop
        
        # Loop through each row to find the project
        FOR    ${row_index}    IN RANGE    1    ${row_count}+1
            # Get the cell text in the specified column - using the dynamic PROJECT_TABLE variable
            ${cell_xpath}=    Set Variable    ${PROJECT_TABLE}/tbody/tr[${row_index}]/td[${column_index}]
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
                # Get the SELECT button in this row - using the dynamic PROJECT_TABLE variable
                ${select_button_xpath}=    Set Variable    ${PROJECT_TABLE}/tbody/tr[${row_index}]//button[contains(@class,'btn-primary') and text()='SELECT']
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
    Wait Until Page Contains Element    id=sss    timeout=10s
    Execute JavaScript    document.getElementById('sss').click();
    Sleep    2s
    
    # Wait for and verify the project modal is displayed with longer timeout
    Wait Until Element Is Visible    ${PROJECT_MODAL}    timeout=15s
    Wait Until Element Is Visible    ${PROJECT_MODAL_CONTENT}    timeout=10s
    Wait Until Element Is Visible    ${PROJECT_TABLE}    timeout=15s
    
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
    Wait Until Element Is Visible    ${MATERIAL_TABLE}    timeout=15s
    
    # Get all rows in the current page
    @{rows}=    Get WebElements    ${MATERIAL_TABLE}/tbody/tr
    ${row_count}=    Get Length    ${rows}
    
    # Log row count for debugging
    Log    Found ${row_count} rows in the material table
    
    # Find the column index based on the column name
    @{headers}=    Get WebElements    ${MATERIAL_TABLE}/thead/tr/th
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
            ${cell_xpath}=    Set Variable    ${MATERIAL_TABLE}/tbody/tr[${row_index}]/td[${column_index}]
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
                ${select_button_xpath}=    Set Variable    ${MATERIAL_TABLE}/tbody/tr[${row_index}]//button[contains(@id,'select_item') and contains(@class,'btn-primary')]
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
            @{rows}=    Get WebElements    ${MATERIAL_TABLE}/tbody/tr
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
    [Arguments]    ${column_name}    ${column_value}    ${row_number}
    
    # Wait for the budget table to be visible
    Wait Until Element Is Visible    ${BUDGET_TABLE}    timeout=10s
    
    # Get all headers to find the column index
    @{headers}=    Get WebElements    xpath://table[@id='myTable']/thead/tr/th
    ${column_index}=    Set Variable    ${0}
    ${found_column}=    Set Variable    ${FALSE}
    
    # Log all headers for debugging
    Log    Found ${headers.__len__()} headers in the budget table
    
    # Check if we already have a cached column index for this column name
    ${cached_index}=    Get Variable Value    ${BUDGET_COLUMN_${column_name}}    ${None}
    
    # If we have a cached index, use it directly
    IF    $cached_index is not None
        ${column_index}=    Set Variable    ${cached_index}
        ${found_column}=    Set Variable    ${TRUE}
        Log    Using cached column index ${column_index} for column '${column_name}'
    ELSE
        # Otherwise, search for the column
        FOR    ${header}    IN    @{headers}
            ${column_index}=    Evaluate    ${column_index} + 1
            ${header_text}=    Get Text    ${header}
            
            # Log header info for debugging
            Log    Header ${column_index}: Text='${header_text}'
            
            # Try to match with text
            ${is_match}=    Run Keyword And Return Status    Should Contain    ${header_text}    ${column_name}
            
            # If found, cache the index and set found flag
            IF    ${is_match}
                Set Test Variable    ${BUDGET_COLUMN_${column_name}}    ${column_index}
                Set Test Variable    ${found_column}    ${TRUE}
                Log    Found column '${column_name}' at index ${column_index} (text='${header_text}')
                Exit For Loop
            END
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
            Sleep    3s
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
                # ${row_id}=    Get Element Attribute    xpath://table[@id='myTable']/tbody/tr[${row_index}]    id
                # ${row_number}=    Set Variable    ${row_id.replace('a', '')}
                
                # Check if the folder icon exists and is clickable using multiple locator strategies based on exact HTML structure
                # <div id="file_bg2"><a class="insertopen2"><i class="glyphicon glyphicon-folder-open"></i></a></div>
                ${folder_icon_xpath1}=    Set Variable    xpath://div[@id='file_bg${row_number}']/a[contains(@class,'insertopen2')]/i[contains(@class,'glyphicon-folder-open')]
                ${folder_icon_xpath2}=    Set Variable    xpath://div[@id='file_bg${row_number}']/a[contains(@class,'insertopen2')]
                ${folder_icon_xpath3}=    Set Variable    xpath://div[@id='file_bg${row_number}']
                ${folder_icon_xpath4}=    Set Variable    xpath://div[contains(@id,'file_bg${row_number}')]//i[contains(@class,'glyphicon-folder-open')]
                
                # Try multiple locator strategies
                ${folder_exists1}=    Run Keyword And Return Status    Element Should Be Visible    ${folder_icon_xpath1}    timeout=1s
                ${folder_exists2}=    Run Keyword And Return Status    Element Should Be Visible    ${folder_icon_xpath2}    timeout=1s
                ${folder_exists3}=    Run Keyword And Return Status    Element Should Be Visible    ${folder_icon_xpath3}    timeout=1s
                ${folder_exists4}=    Run Keyword And Return Status    Element Should Be Visible    ${folder_icon_xpath4}    timeout=1s
                
                # Log which locators are found for debugging
                Log    Folder icon locator 1 (exact match): ${folder_exists1}
                Log    Folder icon locator 2 (a tag): ${folder_exists2}
                Log    Folder icon locator 3 (div only): ${folder_exists3}
                Log    Folder icon locator 4 (generic): ${folder_exists4}
                
                # Determine which locator to use
                ${folder_xpath}=    Set Variable If
                ...    ${folder_exists1}    ${folder_icon_xpath1}
                ...    ${folder_exists2}    ${folder_icon_xpath2}
                ...    ${folder_exists4}    ${folder_icon_xpath4}
                ...    ${folder_exists3}    ${folder_icon_xpath3}
                ...    ${EMPTY}
                
                ${folder_exists}=    Evaluate    ${folder_exists1} or ${folder_exists2} or ${folder_exists3} or ${folder_exists4}
                
                IF    ${folder_exists}
                    # Click the folder icon with robust retry mechanism
                    Sleep    5s
                    
                    # Try multiple click strategies with retry
                    FOR    ${attempt}    IN RANGE    1    4
                        # Re-check visibility to avoid stale element
                        ${still_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${folder_xpath}    timeout=5s
                        
                        IF    ${still_visible}
                            # Try regular click first
                            ${click_success}=    Run Keyword And Return Status    Click Element    ${folder_xpath}
                            
                            # If regular click fails, try JavaScript click
                            IF    not ${click_success}
                                TRY
                                    ${element}=    Get WebElement    ${folder_xpath}
                                    Execute JavaScript    arguments[0].click();    ARGUMENTS    ${element}
                                    ${click_success}=    Set Variable    ${TRUE}
                                EXCEPT
                                    Log    JavaScript click failed on attempt ${attempt}
                                END
                            END
                            
                            # If any click succeeded, exit the loop
                            IF    ${click_success}
                                Log    Successfully clicked folder icon for budget in row ${row_index} on attempt ${attempt}
                                Exit For Loop
                            END
                        END
                        
                        # If we're still in the loop, wait and try again
                        Sleep    2s
                    END
                    
                    # Verify click was successful by checking if budget group modal appears
                    Wait Until Element Is Visible    xpath://div[@id='costcode']    timeout=10s
                    Log    Budget group modal appeared after clicking folder icon
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

Validate Total Amount
    [Documentation]    Validates the total amount values displayed in the HTML table against the values in the JSON data
    [Arguments]    ${json_file_path}    ${case_name}
    
    # Load JSON data and get the expected values
    ${json_data}=    Load Json Data    ${json_file_path}
    ${case_exists}=    Run Keyword And Return Status    Should Contain    ${json_data}[test_cases]    ${case_name}
    
    IF    ${case_exists}
        ${case_data}=    Set Variable    ${json_data}[test_cases][${case_name}]
        ${expected_amount}=    Set Variable    ${case_data}[total][amount]
        ${expected_vat}=    Set Variable    ${case_data}[total][vat]
        
        # Check if the JSON uses 'net_amount' or 'cm_net_amount'
        ${has_net_amount}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${case_data}[total]    net_amount
        ${expected_net_amount}=    Set Variable If    
        ...    ${has_net_amount}    ${case_data}[total][net_amount]    
        ...    ${case_data}[total][cm_net_amount]
        
        # Get the actual values from the web page
        ${actual_amount}=    Get Value    id=summarydi
        ${actual_vat}=    Get Value    id=summaryvat
        ${actual_net_amount}=    Get Value    id=summarytot
        
        # Remove commas from the values before converting to numbers
        ${actual_amount_clean}=    Replace String    ${actual_amount}    ,    ${EMPTY}
        ${actual_vat_clean}=    Replace String    ${actual_vat}    ,    ${EMPTY}
        ${actual_net_amount_clean}=    Replace String    ${actual_net_amount}    ,    ${EMPTY}
        
        # Convert to numbers for comparison
        ${expected_amount_num}=    Convert To Number    ${expected_amount}
        ${expected_vat_num}=    Convert To Number    ${expected_vat}
        ${expected_net_amount_num}=    Convert To Number    ${expected_net_amount}
        
        ${actual_amount_num}=    Convert To Number    ${actual_amount_clean}
        ${actual_vat_num}=    Convert To Number    ${actual_vat_clean}
        ${actual_net_amount_num}=    Convert To Number    ${actual_net_amount_clean}
        
        # Log the values for debugging
        Log    Expected Amount: ${expected_amount_num}, Actual Amount: ${actual_amount_num}
        Log    Expected VAT: ${expected_vat_num}, Actual VAT: ${actual_vat_num}
        Log    Expected Net Amount: ${expected_net_amount_num}, Actual Net Amount: ${actual_net_amount_num}
        
        # Validate the values with a small tolerance for floating point differences
        ${amount_diff}=    Evaluate    abs(${expected_amount_num} - ${actual_amount_num})
        ${vat_diff}=    Evaluate    abs(${expected_vat_num} - ${actual_vat_num})
        ${net_amount_diff}=    Evaluate    abs(${expected_net_amount_num} - ${actual_net_amount_num})
        
        ${tolerance}=    Set Variable    0.01
        
        # Perform the validations
        Run Keyword If    ${amount_diff} > ${tolerance}    Fail    Amount validation failed. Expected: ${expected_amount_num}, Actual: ${actual_amount_num}, Difference: ${amount_diff}
        Run Keyword If    ${vat_diff} > ${tolerance}    Fail    VAT validation failed. Expected: ${expected_vat_num}, Actual: ${actual_vat_num}, Difference: ${vat_diff}
        Run Keyword If    ${net_amount_diff} > ${tolerance}    Fail    Net Amount validation failed. Expected: ${expected_net_amount_num}, Actual: ${actual_net_amount_num}, Difference: ${net_amount_diff}
        
        Log    All total amount validations passed successfully!
    ELSE
        Fail    Test case '${case_name}' not found in JSON data.
    END