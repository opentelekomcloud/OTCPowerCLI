$verbosepreference = "Continue" # write verbose messages
# $verbosepreference = "SilentlyContinue" # do not write verbose messages

# rd "C:\Users\Administrator\.otc" -Force -Confirm:$false -Recurse

# get current script name and path
Set-Variable -Name "LastInvocation" -Value $MyInvocation -Scope Script
Set-Variable -Name "ScriptFileName" -Value $LastInvocation.MyCommand.Name -Scope Script
Set-Variable -Name "ScriptFilePath" -Value (Split-Path -Parent $LastInvocation.MyCommand.Path) -Scope Script

'##########################################'| Write-Verbose 
'INFO - $ScriptFileName: ' + $ScriptFileName |Write-Verbose
'INFO - $ScriptFilePath: ' + $ScriptFilePath |Write-Verbose


# store config and credential data in folder %userprofile%\.otc
Set-Variable -Name OTCconfigPath -Value "$($env:USERPROFILE)\.otc" -Scope Global


Import-Module –Name $ScriptFilePath\OTC-PowerCLI-authentication.psm1 -force -Verbose 
Import-Module –Name $ScriptFilePath\OTC-PowerCLI-volumes.psm1 -force -Verbose
Import-Module –Name $ScriptFilePath\OTC-PowerCLI-images.psm1 -force -Verbose
Import-Module –Name $ScriptFilePath\OTC-PowerCLI-servers.psm1 -force -Verbose
Import-Module –Name $ScriptFilePath\OTC-PowerCLI-networks.psm1 -force -Verbose
#Import-Module –Name $ScriptFilePath\OTC-PowerCLI-obs.psm1 -force -Verbose

clear-OTCauthToken
get-OTCauthToken

return 'SUCCESS'

# get-OTCcredentials
# set-OTCcredentials