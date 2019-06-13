function Catch-Error {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)]$CatchedError
        )     
    # Dig into the exception to get the Response details.
    write-host $CatchedError -ForegroundColor DarkYellow
#    return $CatchedError
    write-host $CatchedError.InvocationInfo.PositionMessage -ForegroundColor Cyan
    if ($CatchedError.Exception ) {
        write-host $CatchedError.Exception  -ForegroundColor Magenta
        if ($CatchedError.Exception.Response ) {
            $ResponseStream = $catchedError.Exception.Response.GetResponseStream()
            $StreamReader = New-Object System.IO.StreamReader($ResponseStream)
            $StreamReader.BaseStream.Position = 0
            $StreamReader.DiscardBufferedData()
            $ResponseBody = $StreamReader.ReadToEnd();
            write-host $responseBody  -ForegroundColor DarkYellow
        }
    }
}
export-modulemember -function Catch-Error

## Global Authentication Cmdlets
function Clear-OTCauthToken {
    Write-Host 'INFO: clearing access token...'
    Set-Variable -Name token -Value $null -Scope Global
    Set-Variable -Name TOKEN_EXPIRES_AT -Value (Get-Date) -Scope Global
}
export-modulemember -function Clear-OTCauthToken

function Get-AuthToken {
                get-OTCauthToken
}
export-modulemember -function Get-AuthToken


function get-OTCauthToken () {

    # Check for current authentication token and retrieves a new one if needed
    if ((Get-Date) -ge $TOKEN_EXPIRES_AT) {
        Write-verbose 'access token expired...'
        Write-verbose 'getting new access token...'
    
        $cred = get-OTCcredentials
        $OTC_USERNAME = $cred.UserName
        try {$OTC_API_KEY = $cred.GetNetworkCredential().Password } catch {}

        # do twice - somethimes first get fails
        $cred = get-OTCcredentials
        $OTC_USERNAME = $cred.UserName
        $OTC_API_KEY = $cred.GetNetworkCredential().Password

        $OTCconfig = get-OTCconfig
        $OTC_USER_DOMAIN_NAME = $OTCconfig.OTC_USER_DOMAIN_NAME
        $OTC_PROJECT_NAME = $OTCconfig.OTC_PROJECT_NAME

    
        # Setting variables needed for function execution
        if ($OTC_API_URL) {   Set-Variable -Name AuthURL -Value "https://iam.$OTC_API_URL/v3/auth/tokens";Write-verbose ('$AuthURL = ' + $AuthURL)
        }    else {    Write-Error '$OTC_API_URL is empty or missing';    }

        if (!$OTC_USERNAME) {    Write-Error '$OTC_USERNAME is empty or missing';  break } else {Write-verbose ('$OTC_USERNAME = ' + $OTC_USERNAME)}
        if (!$OTC_API_KEY)  {    Write-Error '$OTC_API_KEY is empty or missing';  break }else {Write-verbose ('$OTC_API_KEY = ******') }
        if (!$OTC_USER_DOMAIN_NAME) {    Write-Error '$OTC_USER_DOMAIN_NAME is empty or missing';  break  }else {Write-verbose ('$OTC_USER_DOMAIN_NAME = ' + $OTC_USER_DOMAIN_NAME) }
        if (!$OTC_PROJECT_NAME)  {    Write-Error '$OTC_PROJECT_NAME is empty or missing';  break  }else {Write-verbose ('$OTC_PROJECT_NAME = ' + $OTC_PROJECT_NAME) }

        Set-Variable -Name AuthBody -Value (' 
 	    { 	"auth": { 
 			    "identity": { 
 			    "methods": [ "password" ], 
 				    "password": { 
 				    "user": { 
 					    "name": "' + $OTC_USERNAME + '", 
 					    "password": "' + $OTC_API_KEY + '", 
 					    "domain": { "name": "' + $OTC_USER_DOMAIN_NAME + '" } 
 				    } 
 			    } 
 		    }, 
 			    "scope": { 
 				    "project": { "name": "' + $OTC_PROJECT_NAME + '" } 
 			    } 
 		    } 
 	    }' )

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        ## Making the call to the token authentication API and saving it's output as a global variable for reference in every other function.
    #    Set-Variable -Name token2 -Value (Invoke-RestMethod -Uri $AuthURI -Body $AuthBody -ContentType application/json -Method Post) -Scope Global
    #    Set-Variable -Name OTC_PROJECT_ID -Value $token2.token.project.id -Scope Global

        try {
            Set-Variable -Name token -Value (Invoke-WebRequest -Uri $AuthURL -Body $AuthBody -ContentType application/json -Method Post) -Scope Global
            Write-verbose ('recieved new properties:' ) 
        #    Set-Variable -Name token -Value (curl "$AuthURI" -ContentType application/json -body $AuthBody -Method Post) -Scope Global
            Set-Variable -Name X_Subject_Token -Value $token.Headers.'X-Subject-Token' -Scope Global
            Write-verbose ('$X_Subject_Token = ******' ) 
            Set-Variable -Name OTC_PROJECT_ID -Value (ConvertFrom-Json $token.Content).token.project.id -Scope Global
            Write-verbose ('$OTC_PROJECT_ID = ' + $OTC_PROJECT_ID)
            Set-Variable -Name TOKEN_EXPIRES_AT -Value (ConvertFrom-Json $token.Content).token.expires_at -Scope Global
            Write-verbose ('$TOKEN_EXPIRES_AT = ' + $TOKEN_EXPIRES_AT)
            Set-Variable -Name COMPUTE_URL -Value  ((ConvertFrom-Json $token.Content).token.catalog|?{$_.type -match 'compute'}).endpoints.url -Scope Global
            Write-verbose ('$COMPUTE_URL = ' + $COMPUTE_URL)
            Set-Variable -Name IMAGE_URL -Value  ((ConvertFrom-Json $token.Content).token.catalog|?{$_.type -match 'image'}).endpoints.url -Scope Global
            Write-verbose ('$IMAGE_URL = ' + $IMAGE_URL)
            Set-Variable -Name NETWORK_URL -Value  ((ConvertFrom-Json $token.Content).token.catalog|?{$_.type -match 'network'}).endpoints.url -Scope Global
            Write-verbose ('$NETWORK_URL = ' + $NETWORK_URL)
            Set-Variable -Name VOLUMEV2_URL -Value  ((ConvertFrom-Json $token.Content).token.catalog|?{$_.type -match 'volumev2'}).endpoints.url -Scope Global
            Write-verbose ('$VOLUMEV2_URL = ' + $VOLUMEV2_URL)
            Set-Variable -Name DNS_URL -Value  ((ConvertFrom-Json $token.Content).token.catalog|?{$_.type -match 'dns'}).endpoints.url -Scope Global
            Write-verbose ('$DNS_URL = ' + $DNS_URL)
            Set-Variable -Name OBS_URL -Value  ((ConvertFrom-Json $token.Content).token.catalog|?{$_.name -match 'objectstorage'}).endpoints.url -Scope Global
            Write-verbose ('$OBS_URL = ' + $OBS_URL)
            Set-Variable -Name SWIFT_URL -Value  ((ConvertFrom-Json $token.Content).token.catalog|?{$_.name -match 'swift'}).endpoints.url -Scope Global
            Write-verbose ('$SWIFT_URL = ' + $SWIFT_URL)
        #    (ConvertFrom-Json $token.Content).token
        #    (ConvertFrom-Json $token.Content).token.catalog | select name, endpoints | sort name
        #    (ConvertFrom-Json $token.Content).token.catalog.endpoints
        #    (ConvertFrom-Json $token.Content).token.catalog|?{$_.type -match 'image'}.endpoints
        #    ((ConvertFrom-Json $token.Content).token.catalog|?{$_.type -match 'ob'})
        #    (ConvertFrom-Json $token.Content).token.roles
        #    (ConvertFrom-Json $token.Content).token.user
        #    (ConvertFrom-Json $token.Content).token.project
        #    $token.Headers

            ## Headers in powershell need to be defined as a dictionary object, so here I'm creating a dictionary object with the newly granted token. It's global, as it's needed in every future request.
            Set-Variable -Name HeaderDictionary -Value (new-object "System.Collections.Generic.Dictionary``2[[System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089],[System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]") -Scope Global
            $HeaderDictionary.Add("X-Auth-Token", $X_Subject_Token)
        }
        catch { Catch-Error $_ }

    } # end if Check for current authentication token
}
export-modulemember -function get-OTCauthToken



function set-OTCcredentials {

    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

    add-type @"
    public struct OTCcredentials {
        public string OTC_USERNAME;
        public string OTC_API_KEY;
    }
"@
    
    $OTCcredentials = New-Object -TypeName OTCcredentials
       
    # create path
    if (!(Test-Path $OTCconfigPath)) {md $OTCconfigPath}

    #read credentials
    if (Test-Path "$OTCconfigPath\credentials.json") {

        [OTCcredentials]$OTCcredentials = (Get-Content "$OTCconfigPath\credentials.json" | ConvertFrom-Json)
        } 

    $OTCcredentials.OTC_USERNAME = [Microsoft.VisualBasic.Interaction]::InputBox("Enter OTC_USERNAME", "OTC_USERNAME", $OTCcredentials.OTC_USERNAME) 

    $OTCcredentials.OTC_API_KEY = read-host -assecurestring "Enter OTC API Key"| convertfrom-securestring 
    $OTCcredentials|ConvertTo-Json|Set-Content "$OTCconfigPath\credentials.json"

}
export-modulemember -function set-OTCcredentials



function get-OTCcredentials {

    if (!(Test-Path $OTCconfigPath)) {set-OTCcredentials}

    if (!(Test-Path "$OTCconfigPath\credentials.json")) {set-OTCcredentials}

    $OTCcredentials = Get-Content "$OTCconfigPath\credentials.json" | ConvertFrom-Json

    $password = $OTCcredentials.OTC_API_KEY |ConvertTo-SecureString
    $credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $OTCcredentials.OTC_USERNAME,$password

    return $credentials

}
export-modulemember -function get-OTCcredentials



function set-OTCconfig {

    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null


    add-type @"
    public struct OTCconfig {
        public string OTC_USER_DOMAIN_NAME;
        public string OTC_PROJECT_NAME;
        public string OTC_API_URL;
    }
"@
    $OTCconfig = New-Object -TypeName OTCconfig
       
    if (!(Test-Path $OTCconfigPath)) {md $OTCconfigPath}

    if (Test-Path "$OTCconfigPath\config.json") {

        #read credentials
        [OTCconfig]$OTCconfig = Get-Content "$OTCconfigPath\config.json" -ErrorAction SilentlyContinue| ConvertFrom-Json
        
        
        } 


    $OTCconfig.OTC_USER_DOMAIN_NAME = [Microsoft.VisualBasic.Interaction]::InputBox("Enter OTC_USER_DOMAIN_NAME", "OTC_USER_DOMAIN_NAME", $OTCconfig.OTC_USER_DOMAIN_NAME) 
    $OTCconfig.OTC_PROJECT_NAME = [Microsoft.VisualBasic.Interaction]::InputBox("Enter OTC_PROJECT_NAME", "OTC_PROJECT_NAME", $OTCconfig.OTC_PROJECT_NAME) 
    $OTCconfig.OTC_API_URL = [Microsoft.VisualBasic.Interaction]::InputBox("Enter OTC_API_URL", "OTC_API_URL", $OTCconfig.OTC_API_URL) 

    $OTCconfig|ConvertTo-Json|Set-Content "$OTCconfigPath\config.json"
  
}
export-modulemember -function set-OTCconfig

function get-OTCconfig {

    if (!(Test-Path $OTCconfigPath)) {set-OTCconfig}

    if (!(Test-Path "$OTCconfigPath\config.json")) {set-OTCconfig}

    $OTCconfig = Get-Content "$OTCconfigPath\config.json" | ConvertFrom-Json


    $OTCconfig | Get-Member -MemberType NoteProperty | ForEach-Object {
            Set-Variable -Name $_.Name -Value $OTCconfig."$($_.Name)" -Scope Global
            write-verbose "set variable $($_.Name) :     $($OTCconfig."$($_.Name)")"
    }
    # Get-Variable OTC_D*

    return $OTCconfig

}
export-modulemember -function get-OTCconfig