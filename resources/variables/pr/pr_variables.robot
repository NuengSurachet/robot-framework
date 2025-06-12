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
${today}    Get Current Date    result_format=%Y-%m-%d
${INPUT_REMARK}    //input[@id='c']
${INPUT_INVOICE_NUMBER}    //input[@id='invoice_no']
${INPUT_DUEDATE}    //input[@id='apduedate'] 
${INPUT_SEND_APPROVAL}    //select[@id='sendapprove']
