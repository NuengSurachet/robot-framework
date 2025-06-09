*** Settings ***
Resource    resource.robot

*** Test Cases ***
ทดสอบ CM
    loginCM    kidsana  @password 
      Sleep    100m