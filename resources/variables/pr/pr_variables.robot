*** Variables ***
${PR_MENU}    ระบบจัดการในสำนักงาน
${PR_LIST_MENU}    id=d_1
${PR_TYPE_DOCUMENT}    //select[@id='pr_type']

# Vendor selection modal locators
${VENDOR_MODAL}    id=openvender
${VENDOR_MODAL_TITLE}    //div[@id='openvender']//h5[contains(@class,'modal-title') and text()='Select Vender']
${VENDOR_MODAL_CLOSE_BUTTON}    //div[@id='openvender']//button[@id='close']
${VENDOR_SELECT_BUTTON}    //button[contains(@class,'select_bp_detail') and text()='SELECT']

# Address selection modal locators
${ADDRESS_MODAL}    id=bp_add3
${ADDRESS_MODAL_TITLE}    //div[@id='bp_add3']//h5[contains(@class,'modal-title')]
${ADDRESS_SELECT_BUTTON}    id=select_add1
${ADDRESS_MODAL_CLOSE_BUTTON}    id=ok_bp_add
${ADDRESS_INPUT}    //input[@id='addrvender']

#requement input
${INPUT_REMARK}    //input[@id='c']
${INPUT_INVOICE_NUMBER}    //input[@id='invoice_no']
${INPUT_DUEDATE}    //input[@id='apduedate'] 
${INPUT_SEND_APPROVAL}    //select[@id='sendapprove']

# create cost price
${ADD_ROW_BUTTON}    //a[@id='sss']

# project selection modal
${PROJECT_MODAL}    id=openproj
${PROJECT_MODAL_CONTENT}    //div[@id='openproj']//div[@class='modal-content']
${PROJECT_MODAL_TITLE}    //div[@id='openproj']//h4[@class='modal-title' and text()='Select Project']
${PROJECT_TABLE}    //table[@id='DataTables_Table_2']
${PROJECT_NEXT_PAGE}    //a[@id='DataTables_Table_2_next' and not(contains(@class,'disabled'))]
${PROJECT_MODAL_CLOSE_BUTTON}    //div[@id='openproj']//button[@id='close']

# material selection modal
${MATERIAL_MODAL}    id=opnewmat
${MATERIAL_MODAL_CONTENT}    //div[@id='opnewmat']//div[@class='modal-content']
${MATERIAL_MODAL_TITLE}    //div[@id='opnewmat']//h4[@class='modal-title']
${MATERIAL_TABLE}    //table[@id='DataTables_Table_4']
${MATERIAL_NEXT_PAGE}    //a[@id='DataTables_Table_4_next' and not(contains(@class,'disabled'))]
${MATERIAL_MODAL_CLOSE_BUTTON}    //div[@id='opnewmat']//button[@class='close' and @data-dismiss='modal']

# budget selection table
${BUDGET_TABLE}    //div[@class='col-xs-4']//table[@id='myTable']
${BUDGET_TABLE_ROWS}    //div[@class='col-xs-4']//table[@id='myTable']/tbody/tr
${BUDGET_NEXT_PAGE}    //div[@class='col-xs-4']//a[@id='myTable_next' and not(contains(@class,'disabled'))]

# budget group table
${BUDGET_GROUP_TABLE}    //div[@id='myTable_wrapper']//table[@id='myTable']
${BUDGET_GROUP_TABLE_ROWS}    //div[@id='myTable_wrapper']//table[@id='myTable']/tbody/tr
${BUDGET_GROUP_NEXT_PAGE}    //div[@id='myTable_wrapper']//a[@id='myTable_next' and not(contains(@class,'disabled'))]

# add item form
${PRICE_UNIT_INPUT}    //input[@id='pprice_unit']
${VAT_PERCENT_SELECT}    //select[@id='vatper__']
${VAT_OPTION_7}    //select[@id='vatper__']/option[@value='7']
${NET_AMOUNT_INPUT}    //input[@id='pnetamt']
${AMOUNT_INPUT}    //input[@id='pamount']
${DISCOUNT_AMOUNT_INPUT}    //input[@id='pri_disce']
${VAT_AMOUNT_INPUT}    //input[@id='to_vat']
${REMARK_ITEM_INPUT}    //input[@id='remarkitem']
${ADD_TO_ROW_BUTTON}    //button[@id='addtorow']

# success dialog and modal
${SUCCESS_DIALOG_OK_BUTTON}    //div[contains(@class, 'sweet-alert') and contains(@class, 'visible')]//button[contains(@class, 'confirm')]
${INSERT_ROW_MODAL}    //div[@id='insertroww']
${INSERT_ROW_CLOSE_BUTTON}    //div[@id='insertroww']//button[@type='button'][normalize-space()='X']
