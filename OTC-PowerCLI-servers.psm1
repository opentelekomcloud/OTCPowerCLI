function Get-OTCServers {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$false)][string]$name,
            [Parameter(Mandatory=$false)][string]$id
            )    

    ## Authentication token check/retrieval
    Get-AuthToken

    Write-Verbose ('$Name: ' + $Name)
    Write-Verbose ('$ID: ' + $ID)

    ## Setting variables needed to execute this function
    # GET /v2/{tenant_id}/servers
    # ecs.eu-de.otc.t-systems.com:443/v2/.../servers
    $URL = "$COMPUTE_URL/servers"
    $retrycount = 5
    Do {
        ## Making the call to the API
        Try {
            $ServerList = Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary 

            ## Handling response bodies 
            if ($ServerList) {
                $Servers = $ServerList.Servers
                if ($Name -and $ID) {
                    $Servers = ($ServerList.Servers|?{($_.name -match $Name) -and $($_.ID -match $ID) })
                }else {
                    if ($Name ) {
                        $Servers = ($ServerList.Servers|?{$_.name -match $Name})
                    }else {
                        if ($ID ) {
                            $Servers = ($ServerList.Servers|?{$_.id -match $ID})
                        }# end else ($ID)
                    }# end else ($Name)
                }# end else ($Name -and $ID)
        
            ## return results
            $Servers |select -property name,id| Sort-Object Name 
            } else {
                Write-Error "no servers found."
            }
            $retrycount = 0
        }
        catch {
            if ($_.Exception -match 'The operation has timed out') {$retrycount--} else {$retrycount = 0}
            Catch-Error $_
        }
        if ($retrycount -gt 0) {Write-Verbose "retry api call - retries left $retrycount"}
    }until ($retrycount -le 0)
}
<#
 .SYNOPSIS
 The Get-OTCServers cmdlet will pull down a list of all Cloud Servers on your account.Can be filtered by name and id

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
 none, id, name

 .EXAMPLE
 PS C:\Users\Administrator> Get-OTCServers
 This example shows how to get a list of all servers currently deployed in your account
 PS C:\Users\Administrator> Get-OTCServers "hugo"
 This example shows how to get a list of all servers which contains hugo in name
#>
export-modulemember -function Get-OTCServers


function Get-OTCServer {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$false)]$OTCserver,
            [Parameter(Mandatory=$false)]$id
            )   

    if (($OTCserver) -or ($id)) {
   
        ## Authentication token check/retrieval
        Get-AuthToken
        if ($OTCserver) {$id = $OTCserver.id}
        Write-Verbose ('$ID: ' + $ID)
        #testparameter:
        #$ID = 'c8df117c-fc74-412d-96f2-9fcb620b7f2a'

        ## Setting variables needed to execute this function
        # GET /v2/{tenant_id}/servers/{server_id} 
        Set-Variable -Name URL -Value "$COMPUTE_URL/servers/$ID"

        ## Making the call to the API
        $retrycount = 5
        Do {
            try {
                $retrycount --
                $Server = (Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -timeout 30 )
                ## Handling empty response bodies 
                if ($Server -eq $null) {
                    Write-Error "ERROR: Server not found."
                }
            if ($Server) {return $Server.server} else {$server.server.status = 'unknown'}
            }
            catch {
                if ($_.Exception -match 'The operation has timed out') {$retrycount--} else {$retrycount = 0}
                Catch-Error $_
            }
            if ($retrycount -gt 0) {Write-Verbose "retry api call - retries left $retrycount"}
        }until ($retrycount -le 0)
    }
    else {
        Write-Error "ERROR: parameter missing."
    }
}
export-modulemember -function Get-OTCServer


function Get-OTCServerStatus {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$false)]$OTCserver,
            [Parameter(Mandatory=$false)]$id
            )   
    Write-Verbose "Get-OTCServerStatus: start"
    #testparameter:
    #$ID = 'd319ad7e-ebd2-41c1-b948-663286423a43'
        
    if (($OTCserver) -or ($id)) {
        if ($OTCserver) {$id = $OTCserver.id}
        Write-Verbose "Get-OTCServerStatus: ID: $ID"

        ## Making the call to the API
        $Server = Get-OTCServer -id $id -ErrorAction SilentlyContinue
        if ($server.status) {return $server.status} else {return 'UNKNOWN'}
    }
    else {
        Write-Error "ERROR: parameter missing."
    }
}
export-modulemember -function Get-OTCServerStatus
# Get-OTCServerStatus -id 'd319ad7e-ebd2-41c1-b948-663286423a43'


function New-OTCServer {

    Param(  [Parameter(Position=0,Mandatory=$true)][string]$imageRef,
            [Parameter(Position=1,Mandatory=$true)][string]$name,
            [Parameter(Position=2,Mandatory=$true)][string]$availability_zone,
            [Parameter(Position=3,Mandatory=$true)][string]$key_name,
            [Parameter(Position=4,Mandatory=$false)][string]$flavorRef,
            [Parameter(Position=5,Mandatory=$false)][string]$vpcid,
            [Parameter(Position=6,Mandatory=$false)][string]$subnet_id,
            [Parameter(Position=7,Mandatory=$false)][string]$security_group,
            [Parameter(Position=8,Mandatory=$false)][string]$network_uuid,
            [Parameter(Position=9,Mandatory=$false)][string]$regionID,
            [Parameter(Position=10,Mandatory=$false)][string]$size = '30',
            [Parameter(Position=11,Mandatory=$false)][string][ValidateNotNullOrEmpty()][ValidateSet("SSD", "SATA", "SAS")]$volumetype = 'SATA',
            [Parameter(Position=12,Mandatory=$false)][switch]$async 
            )

    if (!$vpcid ) {$vpcid = $OTC_DEFAULT_vpcid }
    if (!$subnet_id ) {$subnet_id = $OTC_DEFAULT_subnet_id }
    if (!$security_group ) {$security_group = $OTC_DEFAULT_security_group }
    if (!$network_uuid ) {$network_uuid = $OTC_DEFAULT_network_uuid }
    if (!$regionID ) {$regionID = $OTC_DEFAULT_regionID }

    Write-Verbose ('New-OTCServer: start')
    Write-Verbose ('New-OTCServer: $imageRef :' + $imageRef)
    Write-Verbose ('New-OTCServer: $name ' + $name)
    Write-Verbose ('New-OTCServer: $availability_zone ' + $availability_zone)
    Write-Verbose ('New-OTCServer: $key_name ' + $key_name)
    Write-Verbose ('New-OTCServer: $flavorRef ' + $flavorRef)
    Write-Verbose ('New-OTCServer: $vpcid ' + $vpcid)
    Write-Verbose ('New-OTCServer: $subnet_id ' + $subnet_id)
    Write-Verbose ('New-OTCServer: $security_group ' + $security_group)
    Write-Verbose ('New-OTCServer: $network_uuid ' + $network_uuid)
    Write-Verbose ('New-OTCServer: $regionID ' + $regionID)
    Write-Verbose ('New-OTCServer: $size ' + $size)
    Write-Verbose ('New-OTCServer: $volumetype ' + $volumetype)
    Write-Verbose ('New-OTCServer: $async ' + $async)

    ## Authentication token check/retrieval
    Get-AuthToken

    #testparameter
    #$imageRef = (Get-OTCImages $imagename).id
    #$name = $imagename
    #$availability_zone = 'eu-de-01' 
    #$key_name = 'otc-prod-aeichhor' 
    #$flavorRef = 'computev1-2'

    ## Setting variables needed to execute this function
    # nativ api
    # POST /v2/{tenant_id}/servers 
    $URL = "$Compute_URL/servers" # nativ api
    $body = '{"server":{
                "availability_zone":"' + $availability_zone + '",
                "name":"' + $name + '",
                "imageRef":"' + $imageRef + '",
                "flavorRef":"' + $flavorRef + '",
                "vpcid":"' + $vpcid + '",
                "nics":[{
	                "subnet_id":"' + $subnet_id + '",
	                "ip_address":""}],
	            "security_groups":[{
		            "name":"' + $security_group + '"}],            
                "networks":[{
                    "uuid":"' + $network_uuid + '"
                      }],
                "personality":[],
                "count":1,
                "extendparam":{
                    "chargingMode":0,
                    "regionID":"' + $regionID + '"
                    },
                "tags":[],
                "key_name":"' + $key_name + '"
                }
            }'

    ## Making the call to the API
    Write-Verbose ('New-OTCServer: Making the call to the API ') 
    Write-Verbose ('New-OTCServer: $URL ' + $URL)
    Write-Verbose ('New-OTCServer: $body ' + $body)
    try {
        $resultbody = Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -Body $body -ContentType application/json -Method Post
        # Write-Verbose ('New-OTCServer: ResultBody:' + $resultbody)
        if ($resultbody.server) {Write-Verbose ('New-OTCServer: ResultBody:' + $resultbody.server)}
       
        if (!$async  ) {
            $i = 0
            $SavedTime = ([System.DateTime]::Now)
            $status = Get-OTCServerStatus -id $resultbody.server.id -ErrorAction Continue 
            while (($status -ne "ACTIVE") -and ($status -ne "ERROR")) {
                Write-Progress -Activity "Server in status $status" -Status ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)) -PercentComplete ($i)
                if ($i -lt 100) {$i++} # if $i > 100 then the script (Write-Progress) will fail
                sleep 10
                $status = Get-OTCServerStatus -id $resultbody.server.id -ErrorAction Continue 
                Write-Verbose "New-OTCServer: status: $status"
#                $progress = Get-OTCServer -id $resultbody.server.id -ErrorAction Continue 
#                Write-Verbose "New-OTCServer: progress: " $progress.progress
                }
            if ($status -ne "ERROR") {
                write-verbose ("New-OTCServer: server was successfully created, Job takes " + ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)))
            } else {
                if ($resultbody.server.id ) {$server = Get-OTCServer -id $resultbody.server.id}
                if ($server.fault) {Write-Verbose ("New-OTCServer: fault: " + $server.fault)}
                write-error 'Server creation failed'
            }
        } 
        # return server data anyway
        if ($resultbody.server) {
            return $resultbody.server
        } 
    } 
    catch {
        # return server data anyway
        if ($resultbody.server) {
            return $resultbody.server
        } 
        Catch-Error $_ 
    }
}
export-modulemember -function New-OTCServer



function New-OTCServerV1 {

    Param(  [Parameter(Position=0,Mandatory=$true)][string]$imageRef,
            [Parameter(Position=1,Mandatory=$true)][string]$name,
            [Parameter(Position=2,Mandatory=$true)][string]$availability_zone,
            [Parameter(Position=3,Mandatory=$true)][string]$key_name,
            [Parameter(Position=4,Mandatory=$false)][string]$flavorRef,
            [Parameter(Position=5,Mandatory=$false)][string]$vpcid,
            [Parameter(Position=6,Mandatory=$false)][string]$subnet_id,
            [Parameter(Position=7,Mandatory=$false)][string]$security_group,
            [Parameter(Position=8,Mandatory=$false)][string]$network_uuid,
            [Parameter(Position=9,Mandatory=$false)][string]$regionID,
            [Parameter(Position=10,Mandatory=$false)][string]$size = '30',
            [Parameter(Position=11,Mandatory=$false)][string][ValidateNotNullOrEmpty()][ValidateSet("SSD", "SATA", "SAS")]$volumetype = 'SATA',
            [Parameter(Position=12,Mandatory=$false)][switch]$async 
            )

    
    if (!$vpcid ) {$vpcid = $OTC_DEFAULT_vpcid }
    if (!$subnet_id ) {$subnet_id = $OTC_DEFAULT_subnet_id }
    if (!$security_group ) {$security_group = $OTC_DEFAULT_security_group }
    if (!$network_uuid ) {$network_uuid = $OTC_DEFAULT_network_uuid }
    if (!$regionID ) {$regionID = $OTC_DEFAULT_regionID }

    try {
        $security_group_id = (Get-OTCSecurityGroups -name $security_group)[-1].id
        } 
    catch {
        write-error "New-OTCServerV1: Error: security_group_id of security group $security_group not found" 
        break
        }

    Write-Verbose ('New-OTCServer: start')
    Write-Verbose ('New-OTCServer: $imageRef :' + $imageRef)
    Write-Verbose ('New-OTCServer: $name ' + $name)
    Write-Verbose ('New-OTCServer: $availability_zone ' + $availability_zone)
    Write-Verbose ('New-OTCServer: $key_name ' + $key_name)
    Write-Verbose ('New-OTCServer: $flavorRef ' + $flavorRef)
    Write-Verbose ('New-OTCServer: $vpcid ' + $vpcid)
    Write-Verbose ('New-OTCServer: $subnet_id ' + $subnet_id)
    Write-Verbose ('New-OTCServer: $security_group ' + $security_group)
    Write-Verbose ('New-OTCServer: $security_group_id ' + $security_group_id)
    Write-Verbose ('New-OTCServer: $network_uuid ' + $network_uuid)
    Write-Verbose ('New-OTCServer: $regionID ' + $regionID)
    Write-Verbose ('New-OTCServer: $size ' + $size)
    Write-Verbose ('New-OTCServer: $volumetype ' + $volumetype)
    Write-Verbose ('New-OTCServer: $async ' + $async)

    ## Authentication token check/retrieval
    Get-AuthToken

    #testparameter
    #$imageRef = (Get-OTCImages $imagename).id
    #$name = $imagename
    #$availability_zone = 'eu-de-01' 
    #$key_name = 'otc-prod-aeichhor' 
    #$flavorRef = 'computev1-2'

    ## Setting variables needed to execute this function
    # nativ api
    # POST /v2/{tenant_id}/servers 
    $URL = "$Compute_URL/servers" # nativ api
    # huawei api
    # POST /v1/{project_id}/cloudservers
    $v1URL = "$Compute_URL/cloudservers" -replace '/v2/', '/v1/'
    $body = '{"server":{
                "availability_zone":"' + $availability_zone + '",
                "name":"' + $name + '",
                "imageRef":"' + $imageRef + '",
                "flavorRef":"' + $flavorRef + '",
                "root_volume":{
                    "volumetype":"' + $volumetype + '", 
                    "multiattach":"true", 
                    "size":' + $size + ',
                    "extendparam":{
                        "resourceSpecCode":"",
                        "resourceType":""
                        }
                    },
                "data_volumes":[],
                "vpcid":"' + $vpcid + '",
                "nics":[{
	                "subnet_id":"' + $subnet_id + '",
	                "ip_address":""}],
	            "security_groups":[{
		            "id":"' + $security_group_id + '"}],            
                "networks":[{
                    "uuid":"' + $network_uuid + '"
                      }],
                "personality":[],
                "count":1,
                "extendparam":{
                    "chargingMode":0,
                    "regionID":"' + $regionID + '"
                    },
                "tags":[],
                "key_name":"' + $key_name + '"
                }
            }'

    ## Making the call to the API
    Write-Verbose ('New-OTCServer: Making the call to the API ') 
    Write-Verbose ('New-OTCServer: $URL ' + $v1URL)
    Write-Verbose ('New-OTCServer: $body ' + $body)

    try {

        $resultbody = Invoke-RestMethod -Uri $v1URL -Headers $HeaderDictionary -Body $body -ContentType application/json -Method Post
        #Write-Verbose ('New-OTCServer: ResultBody:' + $resultbody)
        if ($resultbody.job_id) {Write-Verbose ('New-OTCServer: ResultBody:' + $resultbody.job_id)}
       
        if (!$async ) {
            $i = 0
            $SavedTime = ([System.DateTime]::Now)
            $jobstatus = (Get-OTCJobStatus $resultbody.job_id -ErrorAction Continue).status
            write-verbose "New-OTCServerV1: job status: $jobstatus"
            while (($jobstatus -ne "SUCCESS") -and ($jobstatus -ne "FAIL")) {
                Write-Progress -Activity "Job in Status $jobstatus" -Status ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)) -PercentComplete $i
                if ($i -lt 100) {$i++} # if $i > 100 then the script (Write-Progress) will fail
                sleep 10
                $jobstatus = (Get-OTCJobStatus $resultbody.job_id -ErrorAction Continue).status
                write-verbose "New-OTCServerV1: job status: $jobstatus"
                }
            if ($jobstatus -eq "SUCCESS") {
                write-verbose ("New-OTCServerV1: server creation time: " + ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)) )
                $result = Get-OTCJobStatus $resultbody.job_id -ErrorAction SilentlyContinue
                write-verbose $result
                write-verbose $result.entities.sub_jobs.entities.server_id
                if ($result.entities.sub_jobs.entities.server_id) {
                    return $result.entities.sub_jobs.entities.server_id
                } 
            } 
            else {
                write-error "New-OTCServerV1: server creation faild" 
                if ($jobstatus.fail_reason) {write-error ("New-OTCServerV1: job status fail_reason: " + $jobstatus.fail_reason)}
                if ($jobstatus.entities) {write-error $jobstatus.entities}
                if ($jobstatus.entities.sub_jobs) {write-error $jobstatus.entities.sub_jobs}

            }
        } 
        # return server data anyway

    } 
    catch {
        # return server data anyway
        if ($result.entities.sub_jobs.entities.server_id) {
            return $result.entities.sub_jobs.entities.server_id
        } 
        Catch-Error $_ 
    }
}
export-modulemember -function New-OTCServerV1



function Remove-OTCServer {

    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$serverid,
            [Parameter(Position=1,Mandatory=$false)][string]$delete_publicip = 'false',
            [Parameter(Position=2,Mandatory=$false)][string]$delete_volume = 'false',
            [Parameter(Position=3,Mandatory=$false)][switch]$async 
            )

    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # POST /v1/{project_id}/cloudservers/delete
    Set-Variable -Name URL -Value "$Compute_URL/cloudservers/delete"
    $URL = $URL -replace '/v2/', '/v1/'
    Set-Variable -Name body -Value (' 
                                    {
                                    "servers": [
                                        {
                                            "id": "' + $serverid + '"
                                        }
                                    ], 
                                    "delete_publicip": ' + $delete_publicip + ', 
                                    "delete_volume": ' + $delete_volume + '
                                    }
                                ')

    ## Making the call to the API
    try {
        Set-Variable -Name resultBody -Value (Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -Body $body -ContentType application/json -Method Post) 
        
        if (!$async  ) {
            $i = 0
            $SavedTime = ([System.DateTime]::Now)
            $status = (Get-OTCJobStatus $resultBody.job_id -ErrorAction Continue ).status 
            if (-not $status )  {$status = 'UNKNOWN'}
            while (($status -ne "SUCCESS")-and ($i -le (99))) {
                Write-Progress -Activity ('Job in Status ' + (Get-OTCJobStatus $resultBody.job_id).status) -Status ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)) -PercentComplete ($i)
                sleep 10
                if ($i -lt 100) {$i++} # if $i > 100 then the script (Write-Progress) will fail
                $status = (Get-OTCJobStatus $resultBody.job_id -ErrorAction Continue ).status 
                if (-not $status )  {$status = 'UNKNOWN'}
                }
            write-verbose ("server $serverid was successfully deleted, Job takes " + ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)))
        } 
        if ($resultbody.job_id) {
            return $resultbody.job_id
        } 
    } 
    catch {
        # return server data anyway
        if ($resultbody.job_id) {
            return $resultbody.job_id
        } 
        Catch-Error $_ 
    }
}
export-modulemember -function Remove-OTCServer


function Stop-OTCServer {

    Param(  [Parameter(Position=0,Mandatory=$true)][string]$serverid,
            [Parameter(Position=1,Mandatory=$false)][string]$type = 'SOFT',
            [Parameter(Position=2,Mandatory=$false)][switch]$async 
           )

    ## Authentication token check/retrieval
    Get-AuthToken

    #testparameter
    #$serverid = 'b46b5259-5611-43bf-b6c7-fcc6c31efaf6'
    #$type = 'HARD'
    ## Setting variables needed to execute this function
    # POST /v2/{tenant_id}/servers/{server_id}/action
    Set-Variable -Name URL -Value "$Compute_URL/servers/$serverid/action"
    Set-Variable -Name body -Value (' 
                                    {
                                    "os-stop": {
                                        "type":"' + $type + '"
                                        }
                                    }
    ')

    ## Making the call to the API
    try {
        Set-Variable -Name result -Value (Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -Body $body -ContentType application/json -Method Post) 
        
        if (!$async ) {
            $i = 0
            $serverstatus = Get-OTCServerStatus -id $serverid
            while ($serverstatus -ne "SHUTOFF")  {
                Write-Progress -Activity ('Server in Status ' + $serverstatus) -Status "$i" -PercentComplete ($i)
                $i++
                sleep 10
                $serverstatus = Get-OTCServerStatus -id $serverid
            }
            write-verbose "server $serverid was successfully powered off, Job takes $i x10 seconds"
        } 
        $result
        } 
    catch {Catch-Error $_ }
}
export-modulemember -function Stop-OTCServer



function Restart-OTCServer {

    Param(  [Parameter(Position=0,Mandatory=$true)][string]$serverid,
            [Parameter(Position=1,Mandatory=$false)][string]$type = 'SOFT',
            [Parameter(Position=2,Mandatory=$false)][switch]$async 
           )

    ## Authentication token check/retrieval
    Get-AuthToken

    #testparameter
    #$serverid = 'b46b5259-5611-43bf-b6c7-fcc6c31efaf6'
    #$type = 'HARD'

    ## Setting variables needed to execute this function
    # POST /v2/{tenant_id}/servers/{server_id}/action
    Set-Variable -Name URL -Value "$Compute_URL/servers/$serverid/action"
    Set-Variable -Name body -Value ('{
                                    "reboot": {
                                        "type":"' + $type + '"
                                        }
                                    }')

    ## Making the call to the API
    try {
        Set-Variable -Name resultbody -Value (Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -Body $body -ContentType application/json -Method Post) 
        } 
    catch {Catch-Error $_ }

    ## Handling empty response bodies 
    if ($resultbody -eq $null) {
        write-error 'no output, probably OK'
    }
    else {
        ## return results
        $resultbody
    }
}
export-modulemember -function Restart-OTCServer



function Start-OTCServer {

    Param(  [Parameter(Position=0,Mandatory=$true)][string]$serverid,
            [Parameter(Position=1,Mandatory=$false)][switch]$async 
           )

    ## Authentication token check/retrieval
    Get-AuthToken

    #testparameter
    #$serverid = 'b46b5259-5611-43bf-b6c7-fcc6c31efaf6'

    ## Setting variables needed to execute this function
    # POST /v2/{tenant_id}/servers/{server_id}/action
    Set-Variable -Name URL -Value "$Compute_URL/servers/$serverid/action"
    Set-Variable -Name body -Value (' 
                                    {
                                     "os-start": {}
                                    }
                                    ')


    ## Making the call to the API
    try {
        Set-Variable -Name resultbody -Value (Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -Body $body -ContentType application/json -Method Post) 
       if (!$async ) {
            $i = 0
            $serverstatus = Get-OTCServerStatus -id $serverid
            while ($serverstatus -ne "ACTIVE")  {
                Write-Progress -Activity ('Server in Status ' + $serverstatus) -Status "$i" -PercentComplete ($i)
                $i++
                sleep 10
                $serverstatus = Get-OTCServerStatus -id $serverid
            }
            write-verbose "server $serverid was successfully powered on, Job takes $i x10 seconds"
        } 
    } 
    catch {Catch-Error $_  }

    ## Handling empty response bodies 
    if ($resultbody -eq $null) {
        write-error 'no output, probably OK'
    }
    else {
        ## return results
        $resultbody.server 

    }
}
export-modulemember -function Start-OTCServer



function Get-OTCflavors {

    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # GET /v2/{tenant_id}/flavors  
    Set-Variable -Name URL -Value "$COMPUTE_URL/flavors"
 
    ## Making the call to the API
    $flavors = (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary)

    ## Handling empty response bodies 
    if ($flavors -eq $null) {
        write-error "no flavors found."
    }
    else {
        
        ## return results
        $flavors.flavors | select -Property id, name |Sort-Object Name

    }
}
export-modulemember -function Get-OTCflavors


function Get-OTCflavor {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$id
            )

    ## Authentication token check/retrieval
    Get-AuthToken

    #testparameter
    #$id = 'g1.xlarge'

    ## Setting variables needed to execute this function
    # GET /v2/{tenant_id}/flavors/{flavors_id}  
    Set-Variable -Name URL -Value "$COMPUTE_URL/flavors/$id"
 
    ## Making the call to the API
    $flavor = (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary)

    ## Handling empty response bodies 
    if ($flavor -eq $null) {
        write-error "flavor not found."
    }
    else {
        ## return results
        $flavor.flavor
    }
<#
 .SYNOPSIS
 The Get-OTCflavor cmdlet will show all flavor properties.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
 id e.g 'g1.xlarge'

 .EXAMPLE
 PS C:\Users\Administrator> Get-OTCflavor 'g1.xlarge'
 
#>
}
export-modulemember -function Get-OTCflavor


function Get-OTCJobStatus {
    
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$jobID
            )
    write-verbose "Get-OTCJobStatus: start"
    write-verbose "Get-OTCJobStatus: jobID: $jobID"
    #testparameter:
    #$jobID = "2c9eb2c1599edc2e0159ac51dd57458c"

    ## Authentication token check/retrieval
    Get-AuthToken

    # GET /v1/{tenant_id}/jobs/{job_id} 
    Set-Variable -Name URL -Value "https://ecs.$OTC_API_URL/v1/$OTC_PROJECT_ID/jobs/$jobID"
    write-verbose "Get-OTCJobStatus: URL: $URL"

    ## Making the call to the API
    try {
        Set-Variable -Name job -Value (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary -timeout 30) 
        if ($job) {
            write-verbose "Get-OTCJobStatus: job: $job"
            return $job
        } else {write-error "Get-OTCJobStatus: Job not found"}
    } 
    catch {
        write-error "Get-OTCJobStatus: $_"
        # return unknown status in case of any error
         $returnerrorbody = Convertto-Json @{status="UNKNOWN"
                                            entities="UNKNOWN"
                                            job_id="$jobID"
                                            job_type="UNKNOWN"
                                            begin_time="UNKNOWN"
                                            end_time=""
                                            error_code=""
                                            fail_reason=""
                                            }
        write-verbose ("Get-OTCJobStatus: job: $returnerrorbody")
        return ConvertFrom-Json $returnerrorbody
    } 
    write-verbose "Get-OTCJobStatus: end"
<#
 .SYNOPSIS
 The Get-OTCJobStatus cmdlet will return job status.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
 jobID
 
 .EXAMPLE
 PS C:\Users\Administrator> Get-OTCJobStatus <jobID>
 
#>
}
# 
export-modulemember -function Get-OTCJobStatus



function Get-OTCServerPassword {
    
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$id
            )
    #testparameter:
    #$id = $testServer.id

    ## Authentication token check/retrieval
    Get-AuthToken

    # GET /v2/{tenant_id}/servers/{server_id}/os-server-password
    Set-Variable -Name URL -Value "$COMPUTE_URL/servers/$id/os-server-password"

    ## Making the call to the API
    try {
        Set-Variable -Name result -Value (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary ) 
        } 
    catch {Catch-Error $_  }
      
    if ($result -eq $null) {
        write-error "no password set"
    }
    else {
        ## return result
        $result.password 
    }
}
<#
 .SYNOPSIS
 The Get-OTCServerPassword cmdlet will return password of an ecs server.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
 serverID
 
 .EXAMPLE
 PS C:\Users\Administrator> Get-OTCServerPassword <serverID >
 
#>
export-modulemember -function Get-OTCServerPassword



function Get-OTCServerTags {
    
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$id
            )
    #testparameter:
    #$id = $testServer.id

    ## Authentication token check/retrieval
    Get-AuthToken

    # GET /v2/{tenant_id}/servers/{server_id}/tags
    Set-Variable -Name URL -Value "$COMPUTE_URL/servers/$id/tags"

    ## Making the call to the API
    try {
        Set-Variable -Name result -Value (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary ) 
        } 
    catch {Catch-Error $_  }
      
    if ($result -eq $null) {
        write-error "Error: get tags"
    }
    else {
        ## return result
        $result.tags
        # ConvertTo-Json $result
    }
}
<#
 .SYNOPSIS
 The Get-OTCServerTag cmdlet will return tags of an ecs server.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
 serverID
 
 .EXAMPLE
 PS C:\Users\Administrator> Get-OTCServerTag <serverID >
 
#>
export-modulemember -function Get-OTCServerTags



function Add-OTCServerTag {
    
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$id,
            [Parameter(ValueFromPipeline,Position=1,Mandatory=$true)][string]$tag
            )
    #testparameter:
    # $id = '97606a8c-f039-4338-b9d4-56a59d9b9b14'
    # $tag = 'test'

    ## Authentication token check/retrieval
    Get-AuthToken

    # POST /v2/{project_id}/servers/{server_id}/tags
    Set-Variable -Name URL -Value "$COMPUTE_URL/servers/$id/tags/$tag"
   
    Write-Verbose "Add-OTCServerTag: id: $id"
    Write-Verbose "Add-OTCServerTag: tag: $tag"
    Write-Verbose "Add-OTCServerTag: URL: $URL"

    
    ## Making the call to the API
    try {
        $result = Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -ContentType application/json -Method Put
        } 
    catch {Catch-Error $_  }
      
    if ($result -eq $null) {
        write-error "Job not found"
    }
    else {
        ## return result
        $result 
    }
}
<#
 .SYNOPSIS
 The Add-OTCServerTag cmdlet will add a tag of an ecs server.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
 serverID,tag
 
 .EXAMPLE
 PS C:\Users\Administrator> Add-OTCServerTag <serverID > <tag>
 
#>
export-modulemember -function Add-OTCServerTag


function Remove-OTCServerTag {
    
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$id,
            [Parameter(ValueFromPipeline,Position=1,Mandatory=$true)][string]$tag
            )
    #testparameter:
    # $id = '97606a8c-f039-4338-b9d4-56a59d9b9b14'
    # $tag = 'test'

    ## Authentication token check/retrieval
    Get-AuthToken

    # POST /v2/{project_id}/servers/{server_id}/tags
    Set-Variable -Name URL -Value "$COMPUTE_URL/servers/$id/tags/$tag"
   
    Write-Verbose "Remove-OTCServerTag: id: $id"
    Write-Verbose "Remove-OTCServerTag: tag: $tag"
    Write-Verbose "Remove-OTCServerTag: URL: $URL"

    
    ## Making the call to the API
    try {
        $result = Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -ContentType application/json -Method Delete
        } 
    catch {Catch-Error $_  }
      
    if ($result -eq $null) {
        write-error "Job not found"
    }
    else {
        ## return result
        $result 
    }
}
<#
 .SYNOPSIS
 The Remove-OTCServerTag cmdlet will remove a tag of an ecs server.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
 serverID,tag
 
 .EXAMPLE
 PS C:\Users\Administrator> Remove-OTCServerTag <serverID > <tag>
 
#>
export-modulemember -function Remove-OTCServerTag


function Get-OTCSecurityGroups {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$false)][string]$name,
            [Parameter(Mandatory=$false)][string]$id
            )    
    Write-Verbose ('$Name: ' + $name)
    Write-Verbose ('$ID: ' + $id)

    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # GET /v2/{tenant_id}/os-security-groups
    Set-Variable -Name URL -Value "$Compute_URL/os-security-groups"


    ## Making the call to the API
    $SGList = (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary)

    ## Handling response bodies 
    if ($SGList) {
        $security_groups = $SGList.security_groups
        if ($Name -and $ID) {
            $security_groups = ($SGList.security_groups|?{($_.name -match $Name) -and $($_.ID -match $ID) })
        }else {
            if ($Name ) {
                $security_groups = ($SGList.security_groups|?{$_.name -match $Name})
            }else {
                if ($ID ) {
                    $security_groups = ($SGList.security_groups|?{$_.id -match $ID})
                }# end else ($ID)
            }# end else ($Name)
        }# end else ($Name -and $ID)
        
    ## return results
    $security_groups | Sort-Object Name 
    } else {
        Write-Error "no Networks found."
    }
}
export-modulemember -function Get-OTCSecurityGroups
