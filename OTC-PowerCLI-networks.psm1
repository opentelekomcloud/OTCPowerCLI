
function Get-OTCnetworks {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$false)][string]$name,
            [Parameter(Mandatory=$false)][string]$id
            )    
    Write-Verbose ('$Name: ' + $name)
    Write-Verbose ('$ID: ' + $id)

    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # GET /v2.0/networks 
    Set-Variable -Name URL -Value "$NETWORK_URL/v2.0/networks"

    ## Making the call to the API
    $VPCList = (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary)

    ## Handling response bodies 
    if ($VPCList) {
        $Networks = $VPCList.networks
        if ($Name -and $ID) {
            $Networks = ($VPCList.networks|?{($_.name -match $Name) -and $($_.ID -match $ID) })
        }else {
            if ($Name ) {
                $Networks = ($VPCList.networks|?{$_.name -match $Name})
            }else {
                if ($ID ) {
                    $Networks = ($VPCList.networks|?{$_.id -match $ID})
                }# end else ($ID)
            }# end else ($Name)
        }# end else ($Name -and $ID)
        
    ## return results
    $Networks | Sort-Object Name 
    } else {
        Write-Error "no Networks found."
    }
}
export-modulemember -function Get-OTCnetworks


function Get-OTCnetwork {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$false)][string]$id
            ) 
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # GET /v2.0/networks/{network_id}  
    Set-Variable -Name URL -Value "$NETWORK_URL/v2.0/networks/$id"

    ## Making the call to the API
    try {
        $VPCList = (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary)
        $VPCList.network | Sort-Object Name
        }
    catch { Catch-Error $_ }
}
export-modulemember -function Get-OTCnetwork



function Get-OTCsubnets {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$false)][string]$name,
            [Parameter(Mandatory=$false)][string]$id
            )    
    Write-Verbose ('$Name: ' + $name)
    Write-Verbose ('$ID: ' + $id)
    
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # GET /v2.0/subnets   
    Set-Variable -Name URL -Value "$NETWORK_URL/v2.0/subnets"

    ## Making the call to the API
    try {
        $ResponceBody = (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary)
        if ($ResponceBody) {
            $subnets = $ResponceBody.subnets
            if ($Name -and $ID) {
                $subnets = ($ResponceBody.subnets|?{($_.name -match $Name) -and $($_.ID -match $ID) })
            }else {
                if ($Name ) {
                    $subnets = ($ResponceBody.subnets|?{$_.name -match $Name})
                }else {
                    if ($ID ) {
                        $subnets = ($ResponceBody.subnets|?{$_.id -match $ID})
                    }# end else ($ID)
                }# end else ($Name)
            }# end else ($Name -and $ID)
        
        ## return results
        $subnets | Sort-Object Name 
        } else {
            Write-Error "no Subnets found."
        }
    }
    catch {Catch-Error $_ }
}
export-modulemember -function Get-OTCsubnets



#Update-OTCsubnet -id '1d594ea8-ad5d-4fd8-8180-5fa882948c99' -gateway_ip '192.168.1.2' 
#Update-OTCsubnet -id '1d594ea8-ad5d-4fd8-8180-5fa882948c99' -allocation_pools '[{
#                                                    "start":"192.168.1.1", 
#                                                    "end":"192.168.1.250"
#                                                    }]'
function Update-OTCsubnet {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$id,
            [Parameter(Mandatory=$false)][string]$gateway_ip
#            [Parameter(Mandatory=$false)][string]$allocation_pools
            )    
    Write-Verbose ('$ID: ' + $id)
    Write-Verbose ('$gateway_ip: ' + $gateway_ip)
#    Write-Verbose ('$allocation_pools: ' + $allocation_pools)
    
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # PUT /v2.0/subnets/{subnet-id}    
    Set-Variable -Name URL -Value "$NETWORK_URL/v2.0/subnets/$id"

    Set-Variable -Name body -Value ('{
                                    "subnet":
                                        {
                                        "gateway_ip": "' + $gateway_ip + '"
                                        }
                                    }')

# not working somehow
#    Set-Variable -Name body -Value ('{
#                                    "subnet":
#                                        {
#                                        "allocation_pools" :"' + $allocation_pools + '" 
#                                        }
#                                    }')

    Write-Verbose ($body)


    ## Making the call to the API
    try {
        $ResponceBody = (Invoke-RestMethod -Uri $URL -Body $body -Headers $HeaderDictionary -Method Put)
        if ($ResponceBody) {
            $ResponceBody

        } else {
            Write-Error "no result."
        }
    }
    catch {Catch-Error $_ }
}
export-modulemember -function Update-OTCsubnet



function Get-OTCports {

    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # GET /v2.0/ports 
    Set-Variable -Name URL -Value "$NETWORK_URL/v2.0/ports"
 
    ## Making the call to the API
    $VPCList = (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary)

    ## Handling empty response bodies 
    if ($VPCList -eq $null) {
        write-error "no ports found."
    }
    else {
        
        ## return results
        $VPCList.ports | Sort-Object Name

    }
<#
 .SYNOPSIS
 The Get-OTCports cmdlet will pull down a list of all ports on your account.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
 none

 .EXAMPLE
 PS C:\Users\Administrator> Get-OTCports
 
#>
}
export-modulemember -function Get-OTCports


function New-OTCport {

    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # POST /v2.0/ports 
    Set-Variable -Name URL -Value "$NETWORK_URL/v2.0/ports"
    Set-Variable -Name Port -Value (' 
        {"port":{
            "availability_zone":"eu-de-01",
            "name":"aei-test-01",
            "imageRef":"3d582cf9-8738-4471-b21a-b86a7cfb930e",
            "flavorRef":"computev1-1",
            "root_volume":{
                "volumetype":"SATA",
                "size":80,
                "extendparam":{
                    "resourceSpecCode":"",
                    "resourceType":""
                    }
                },
            "data_volumes":[],
            "vpcid":"9dc73bec-70bf-4adb-8a09-bd5ba2aa551c",
            "nics":[{
                "subnet_id":"88c43184-5db2-442f-83bd-1dcbe4f6580f"
                  }],
            "networks":[{
                "uuid":"88c43184-5db2-442f-83bd-1dcbe4f6580f"
                  }],
             "security_groups":[{
                "id":"1e58dcb6-ed86-4a05-a7a4-d12132a491cb"
                }],
            "personality":[],
            "count":1,
            "extendparam":{
                "chargingMode":0,
                "regionID":"eu-de"
                },

            "key_name":"otc-prod-aeichhor"
            }
        }
    ')


    ## Making the call to the API
    Set-Variable -Name newPort -Value (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary -Body $Port -ContentType application/json -Method Post) 

    ## Handling empty response bodies 
    if ($newPort -eq $null) {
        write-error "port creation failed."
    }
    else {
        
        ## return results
        $newPort.ports | Sort-Object Name

    }
<#
 .SYNOPSIS
 The New-OTCport cmdlet will create a new port

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
 none

 .EXAMPLE
 PS C:\Users\Administrator> New-OTCport
 
#>
}
export-modulemember -function New-OTCport
