# OTCPowerCLI

use Open Telekom Cloud API with MS Windows Powershell

copy all files to a folder on your server
run  Import-OTCPowerCLI.ps1

enter credentials and configuration which is stored in %userprofile%\config.json and %userprofile%\credentials.json

"OTC_USERNAME":		

your Username found on my Credential tab on OTC web portal
e.g. 12345678 OTC00000000001234567890


"OTC_API_KEY": e.g ddf0115d1118c7a0051b00f9b2e1db24685b34d22769d1a06ee5b6c24f06857ea4aac2500000002d0d8bc

your password entered on my Credential tab on OTC web portal - formally known as api key - 
password is stored encrypted



"OTC_USER_DOMAIN_NAME":	e.g. OTC00000000001234567890

your Domain Name found on my Credential tab on OTC web portal


"OTC_PROJECT_NAME":	e.g. eu-de

your Project found on my Credential tab on OTC web portal
e.g. eu-de


"OTC_API_URL": 	e.g. eu-de.otc.t-systems.com

OTC API Url - see https://docs.otc.t-systems.com/en-us/endpoint/index.html



run get-help otc and see available commands
