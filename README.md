# OTCPowerCLI

use Open Telekom Cloud API with MS Windows Powershell

copy all files to a folder on your server
run  Import-OTCPowerCLI.ps1

enter credentials and configuration which is stored in %userprofile%\config.json and %userprofile%\credentials.json

"OTC_USERNAME":		
your Username found on my Credential tab on OTC web portal
e.g. 12345678 OTC00000000001234567890

"OTC_API_KEY":
your password entered on my Credential tab on OTC web portal - formally known as api key - 
password is stored encrypted
e.g ddf0115d1118c7a0051b00f9b2e1db24685b34d22769d1a06ee5b6c24f06857ea4aac2500000002d0d8bc

"OTC_USER_DOMAIN_NAME":	
your Domain Name found on my Credential tab on OTC web portal
e.g. OTC00000000001234567890

"OTC_PROJECT_NAME":	
your Project found on my Credential tab on OTC web portal
e.g. eu-de

"OTC_API_URL": 		
OTC API Url - see https://docs.otc.t-systems.com/en-us/endpoint/index.html
e.g. eu-de.otc.t-systems.com

run get-help otc and see available commands
