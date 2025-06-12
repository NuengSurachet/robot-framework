*** Settings ***
Library    SeleniumLibrary
Library    String
Resource    ../../variables/pr/pr_variables.robot
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
    Input Text    ${INPUT_DUEDATE}    ${VALUE_DATE}
    Select From List By Label    ${INPUT_SEND_APPROVAL}    ${VALUE_APPROVAL_NAME}
   