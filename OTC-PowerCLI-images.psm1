#Import-Module –Name .\OTC-PowerCLI-servers.psm1 -force -Verbose

function Get-OTCImages {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$false)][string]$name,
            [Parameter(Mandatory=$false)][string]$id
        )    
    #testparameter
    #$name = 'aei-msdos'
    #$id = '97c892d9-f71e-4dfa-a913-6361f8830147'
    Write-Verbose "name: $name"
    Write-Verbose "id: $id"
    
    ## Authentication token check/retrieval
    Get-AuthToken

    # GET /v2/{tenant_id}/images (ecs api)
    # GET /v2/images (image api

    Set-Variable -Name URL -Value "$COMPUTE_URL/images"
    # Set-Variable -Name URL -Value "$IMAGE_URL/v2/images"
   
    $retrycount = 5
    Do {
        try {
            ## Making the call to the API for a list of available server images and storing data into a variable
            $ImageList = Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -timeout 120
            #$ServerImageList.Images|fl
    
                ## Handling empty response bodies 
            if ($ImageList) {
                $Images = $ImageList.Images
                if ($Name -and $ID) {
                    $Images = ($ImageList.Images|?{($_.name -match $Name) -and $($_.ID -match $ID) })
                }else {
                    if ($Name ) {
                        $Images = ($ImageList.Images|?{$_.name -match $Name})
                }else {
                        if ($ID ) {
                            $Images = ($ImageList.Images|?{$_.id -match $ID})
                    }# end else ($ID)
                    }# end else ($Name)
                }# end else ($Name -and $ID)
        
                ## return results
                $Images |select -property name,id| Sort-Object Name 
            } else {Write-Error "no Images found."}
            $retrycount = 0
        }
        catch {
            if ($_.Exception -match 'The operation has timed out') {$retrycount--} else {$retrycount = 0}
            Catch-Error $_
        }
        if ($retrycount -gt 0) {Write-Verbose "retry api call - retries left $retrycount"}
    }until ($retrycount -le 0)
<#
 .SYNOPSIS
 The Get-OTCImages cmdlet will pull down a list of all Cloud Server images, including public images.

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
 none,id,name
 
 .EXAMPLE
    This example shows how to get a list of all available images in your account.
        PS C:\Users\Administrator> Get-OTCImages
    This example shows images which match specifc names
        PS C:\Users\Administrator> Get-OTCImages 'test'
    This example shows images which match specifc id
        PS C:\Users\Administrator> Get-OTCImages -id '34b565df-9963-4fba-8571-9264e50bdd14'

#>
}
export-modulemember -function Get-OTCImages


function Get-OTCprivateImages {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$false)][string]$name,
            [Parameter(Mandatory=$false)][string]$id
        )    
    #testparameter
    #$name = 'aei-msdos'
    #$id = '97c892d9-f71e-4dfa-a913-6361f8830147'
    Write-Verbose "name: $name"
    Write-Verbose "id: $id"
    
    ## Authentication token check/retrieval
    Get-AuthToken

    # GET /v2/{tenant_id}/images (ecs api)
    # GET /v2/images (image api

    # Set-Variable -Name URL -Value "$COMPUTE_URL/images"
    Set-Variable -Name URL -Value "$IMAGE_URL/v2/images"
   
    try {
        ## Making the call to the API for a list of available server images and storing data into a variable
        $ImageList = Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -timeout 30
        #$ServerImageList.Images|fl
    
            ## Handling empty response bodies 
        if ($ImageList) {
            $Images = $ImageList.Images
            if ($Name -and $ID) {
                $Images = ($ImageList.Images|?{($_.name -match $Name) -and $($_.ID -match $ID) })
            }else {
                if ($Name ) {
                    $Images = ($ImageList.Images|?{$_.name -match $Name})
            }else {
                    if ($ID ) {
                        $Images = ($ImageList.Images|?{$_.id -match $ID})
                }# end else ($ID)
                }# end else ($Name)
            }# end else ($Name -and $ID)
        
            ## return results
            $Images |select -property name,id| Sort-Object Name 
        } else {Write-Error "no Images found."}
    }
    catch { Catch-Error $_ }
}
<#
 .SYNOPSIS
 The Get-OTCprivateImages cmdlet will pull down a list of all private Cloud Server images

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
 none,id,name
 
 .EXAMPLE
    This example shows how to get a list of all available images in your account.
        PS C:\Users\Administrator> Get-OTCImages
    This example shows images which match specifc names
        PS C:\Users\Administrator> Get-OTCImages 'test'
    This example shows images which match specifc id
        PS C:\Users\Administrator> Get-OTCImages -id '34b565df-9963-4fba-8571-9264e50bdd14'

#>
export-modulemember -function Get-OTCprivateImages



function Get-OTCImage {

    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$false)]$OTCimage,
            [Parameter(Mandatory=$false)]$id
            )   

    if (($OTCimage) -or ($id)) {
   
        ## Authentication token check/retrieval
        Get-AuthToken

        if ($OTCimage) {$id = $OTCimage.id}
        Write-Verbose ('$ID: ' + $ID)
 
        ## Setting variables needed to execute this function
        # GET /v2/{tenant_id}/images/{image_id} (ecs api)
        # GET /v2/images/{image_id} (image api)
        # Set-Variable -Name URL -Value "$COMPUTE_URL/images/$ID"
        Set-Variable -Name URL -Value "$IMAGE_URL/v2/images/$ID"
   
        $retrycount = 5
        Do {
            try {
                ## Making the call to the API
                $Image = Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -timeout 30
 
                ## Handling empty response bodies 
#                if ($Image.image ) {
                if ($Image ) {
                    ## return results
#                    return $Image.image
                    return $Image
                }
                else {Write-Error "ERROR: Image not found."}
                $retrycount = 0
            }
            catch {
                return $null
                if ($_.Exception -match 'The operation has timed out') {$retrycount--} else {$retrycount = 0}
                Catch-Error $_
            }
            if ($retrycount -gt 0) {Write-Verbose "retry api call - retries left $retrycount"}
       }until ($retrycount -le 0)
   }
    else { Write-Error "ERROR: parameter missing."}
}
export-modulemember -function Get-OTCImage


function New-OTCImage {

    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$serverid,
            [Parameter(Position=1,Mandatory=$true)][string]$name,
            [Parameter(Position=2,Mandatory=$false)][string]$description,
            [Parameter(Position=3,Mandatory=$false)][switch]$async 
            )

    write-verbose "New-OTCImage: start"
    write-verbose "New-OTCImage: serverid: $serverid"
    write-verbose "New-OTCImage: name: $name"
    write-verbose "New-OTCImage: description: $description"

    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # POST /v2/cloudimages/action 
    Set-Variable -Name URL -Value "$IMAGE_URL/v2/cloudimages/action"
    write-verbose "New-OTCImage: URL: $URL"
    Set-Variable -Name body -Value (' 
       {"name":"' + $name + '",
       "description":"' + $description + '",
       "instance_id":"' + $serverid + '"}
    ')
    write-verbose "New-OTCImage: body: $body"

    ## Making the call to the API
    try {
        Set-Variable -Name resultbody -Value (Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -Body $body -ContentType application/json -Method Post) 
        if (!$async ) {
            $i = 0
            $SavedTime = ([System.DateTime]::Now)
            $jobstatus = (Get-OTCJobStatus $resultbody.job_id -ErrorAction Continue).status
            write-verbose "New-OTCImage: job status: $jobstatus"
            while (($jobstatus -ne "SUCCESS") -and ($jobstatus -ne "FAIL")) {
                Write-Progress -Activity "Job in Status $jobstatus" -Status ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)) -PercentComplete $i
                if ($i -lt 100) {$i++} # if $i > 100 then the script (Write-Progress) will fail
                sleep 10
                $jobstatus = (Get-OTCJobStatus $resultbody.job_id -ErrorAction Continue).status
                write-verbose "New-OTCImage: job status: $jobstatus"
                }
            if ($jobstatus -eq "SUCCESS") {
                write-verbose ('Export-OTCImage: image export time: ' + ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)))
            } 
            else {write-error "New-OTCImage: Image creation faild" }
        } 
        if ($resultbody.job_id) {
            return $resultbody.job_id
        }
    }
    catch {
        # return body anyway.
        if ($resultbody.job_id) {
            return $resultbody.job_id
        }
       Catch-Error $_ 
    }
    write-verbose "New-OTCImage: end"
}
<#
 .SYNOPSIS
 The New-OTCImage cmdlet will create a new image from a server

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
    ECS server id
    image name
    image description

 .EXAMPLE
 PS C:\Users\Administrator> New-OTCImage <server ID> <image name> <image description>
 
#>
export-modulemember -function New-OTCImage


function New-ImageMetadata {

    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$name,
            [Parameter(Position=1,Mandatory=$true)][string]$os_version,
            [Parameter(Position=2,Mandatory=$true)][string]$min_disk,
            [Parameter(Position=3,Mandatory=$true)][string]$min_ram,
            [Parameter(Position=4,Mandatory=$false)][string]$description
            )

    #testparameter:
    #$min_disk = '20'
    #$min_ram = '1024'
    #$name = 'aei-msdos'
    #$description = 'aei test'
    #$os_version = 'Windows Server 2012 R2 Standard 64bit'

    write-verbose "New-ImageMetadata: start"
    write-verbose "New-ImageMetadata: name: $name"
    write-verbose "New-ImageMetadata: os_version: $os_version"
    write-verbose "New-ImageMetadata: min_disk: $min_disk"
    write-verbose "New-ImageMetadata: min_ram: $min_ram"
    write-verbose "New-ImageMetadata: description: $description"
    
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # POST /v2/images
    Set-Variable -Name URL -Value "$IMAGE_URL/v2/images"
    # sample body 
 <#   {
    "__os_version": "Ubuntu 14.04 server 64bit",
    "container_format": "bare",
    "disk_format": "vhd",
    "id": "4ca46bf1-5c61-48ff-b4f3-0ad4e5e3ba86",
    "min_disk": 1,
    "min_ram": 1024,
    "name": "test",
    "tags": [
        "test",
        "image"
    ],
    "visibility": "private",
    "protected": false
}#>
    
    Set-Variable -Name body -Value ('{  "name":"' + $name + '",
                                        "description":"' + $description + '",
                                        "__os_version":"' + $os_version + '",
                                        "min_disk": ' + $min_disk + ',
                                        "min_ram": 1024,
                                        "visibility":"private",
                                        "protected":false
                                    }')

    write-verbose "New-ImageMetadata: url: $url"
    write-verbose "New-ImageMetadata: body: $body"

    ## Making the call to the API
    try {
        $resultbody =  Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary -Body $body -ContentType application/json -Method Post -timeout 30
        if ($resultbody) {
            return $resultbody
            }
    } 
    catch {
        # return body anyway.
        if ($resultbody) {
            return $resultbody
            }
         Catch-Error $_ 
    }
    write-verbose "New-ImageMetadata: end"
}
export-modulemember -function New-ImageMetadata



function Upload-OTCImageFile {

    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$id,
            [Parameter(Position=1,Mandatory=$true)][string]$image,
            [Parameter(Position=6,Mandatory=$false)][switch]$async 
            )

    #testparameter:
    #$image = 'aei-windows-images:MS-DOS 6.22 VHD.vhd'
    #$id = '25350d81-4a11-4420-8c2a-29be384c0649'


    write-verbose "Upload-OTCImageFile: start"
    write-verbose "Upload-OTCImageFile: id: $id"
    write-verbose "Upload-OTCImageFile: name: $image"
    write-verbose "Upload-OTCImageFile: async: $async"
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # PUT /v1/cloudimages/4ca46bf1-5c61-48ff-b4f3-0ad4e5e3ba86/upload
    Set-Variable -Name URL -Value "$IMAGE_URL/v1/cloudimages/$id/upload"
    <# sample body {
                    "image_url": "bucketname:Centos6.5-disk1.vmdk" 
                    } #>
    Set-Variable -Name body -Value ('{  "image_url":"' + $image + '"
                                        }')

    write-verbose "Upload-OTCImageFile: url: $url"
    write-verbose "Upload-OTCImageFile: body: $body"

    ## Making the call to the API
    try {
        $resultbody =  Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary -Body $body -ContentType application/json -Method PUT -timeout 30
        if (!$async ) {
            $i = 0
            $SavedTime = ([System.DateTime]::Now)
            $jobstatus = (Get-OTCJobStatus $resultbody.job_id -ErrorAction Continue).status
            write-verbose "Upload-OTCImageFile: job status: $jobstatus"
            while (($jobstatus -ne "SUCCESS") -and ($jobstatus -ne "FAIL")) {
                Write-Progress -Activity "Job in Status $jobstatus" -Status ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)) -PercentComplete $i
                if ($i -lt 100) {$i++} # if $i > 100 then the script (Write-Progress) will fail
                sleep 10
                $jobstatus = (Get-OTCJobStatus $resultbody.job_id -ErrorAction Continue).status
                write-verbose "Upload-OTCImageFile: job status: $jobstatus"
                }
            if ($jobstatus -eq "SUCCESS") {
                write-verbose ('Export-OTCImage: image export time: ' + ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)))
            } 
            else {write-error "Upload-OTCImageFile: Image creation faild" }
        } 
        if ($resultbody.job_id) {
            return $resultbody.job_id
            }
    } 
    catch {
        # return body anyway.
        if ($resultbody.job_id) {
            return $resultbody.job_id
            }
        Catch-Error $_ 
    }
    write-verbose "Upload-OTCImageFile: end"
}
export-modulemember -function Upload-OTCImageFile



function New-OTCImageFromFile {

    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$image,
            [Parameter(Position=1,Mandatory=$true)][string]$min_disk,
            [Parameter(Position=2,Mandatory=$true)][string]$name,
            [Parameter(Position=3,Mandatory=$false)][string]$description,
            [Parameter(Position=4,Mandatory=$false)][string]$os_version,
            [Parameter(Position=5,Mandatory=$false)][string]$is_config_init,
            [Parameter(Position=6,Mandatory=$false)][string]$type,
            [Parameter(Position=7,Mandatory=$false)][switch]$async 
            )

    #testparameter:
    #$image = 'aei-windows-images:MS-DOS 6.22 VHD.vhd'
    #$min_disk = '80'
    #$name = 'aei-msdostest'
    #$description = 'aei test'
    #$os_version = 'Windows Server 2012 R2 Standard 64bit'
    #$is_config_init = 'true'
    if (!$type) {$type = 'ECS'}

    write-verbose "New-OTCImageFromFile: start"
    write-verbose "New-OTCImageFromFile: image: $image"
    write-verbose "New-OTCImageFromFile: min_disk: $min_disk"
    write-verbose "New-OTCImageFromFile: name: $name"
    write-verbose "New-OTCImageFromFile: description: $description"
    write-verbose "New-OTCImageFromFile: os_version: $os_version"
    write-verbose "New-OTCImageFromFile: is_config_init: $is_config_init"
    write-verbose "New-OTCImageFromFile: type: $type"
    write-verbose "New-OTCImageFromFile: async: $async"
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # POST /v2/cloudimages/action 
    Set-Variable -Name URL -Value "$IMAGE_URL/v2/cloudimages/action"
    <# sample body {"name":"aei-msdos3",
                    "min_disk":30,
                    "image_url":"aei-windows-images:MS-DOS 6.22 VHD.vhd",
                    "description":"aei test",
                    "os_version":"Windows Server 2012 R2 Standard 64bit",
                    "is_config_init":true
                    } #>
    Set-Variable -Name body -Value ('{
                                        "name":"' + $name + '",
                                        "description":"' + $description + '",
                                        "type":"' + $type + '",
                                        "min_disk":' + $min_disk + ',
                                        "image_url":"' + $image + '",
                                        "os_version":"' + $os_version + '",
                                        "is_config_init":' + $is_config_init + '
                                    }')

    write-verbose "New-OTCImageFromFile: url: $url"
    write-verbose "New-OTCImageFromFile: body: $body"

    ## Making the call to the API
    try {
        $resultbody =  Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary -Body $body -ContentType application/json -Method Post #-timeout 30
        if (!$async ) {
            $i = 0
            $SavedTime = ([System.DateTime]::Now)
            $jobstatus = (Get-OTCJobStatus $resultbody.job_id -ErrorAction Continue).status
            write-verbose "New-OTCImageFromFile: job status: $jobstatus"
            while (($jobstatus -ne "SUCCESS") -and ($jobstatus -ne "FAIL")) {
                Write-Progress -Activity "Job in Status $jobstatus" -Status ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)) -PercentComplete $i
                if ($i -lt 100) {$i++} # if $i > 100 then the script (Write-Progress) will fail
                sleep 10
                $jobstatus = (Get-OTCJobStatus $resultbody.job_id -ErrorAction Continue).status
                write-verbose "New-OTCImageFromFile: job status: $jobstatus"
                }
            if ($jobstatus -eq "SUCCESS") {
                write-verbose ('New-OTCImageFromFile: image creation time: ' + ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)))
            } 
            else {write-error "New-OTCImageFromFile: Image creation faild" }
        } 
        if ($resultbody.job_id) {
            return $resultbody.job_id
            }
    } 
    catch {
        # return body anyway.
        if ($resultbody.job_id) {
            return $resultbody.job_id
            }
        Catch-Error $_ 
    }
    write-verbose "New-OTCImageFromFile: end"
}
<#
 .SYNOPSIS
 The New-OTCImageFromFile cmdlet will create a new image from object storage

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 


 .EXAMPLE
 PS C:\Users\Administrator> New-OTCImageFromFile 
 
#>
export-modulemember -function New-OTCImageFromFile


function Remove-OTCImage {

    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$id,
            [Parameter(Position=6,Mandatory=$false)][switch]$async 
             )
    # testparameter
    # $id = 'a278ccbf-b94a-4174-9fda-15b78cc6f900'
    
    
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # DELETE /v2/{tenant_id}/images/{image_id}  (ecs api)
    # DELETE /v2/images/{image_id} 
    Set-Variable -Name URL -Value "$IMAGE_URL/v2/images/$id "

    ## Making the call to the API
    try {
        $resultBody = Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary -Method Delete #-erroraction continue
        # api call does not return any body, just errors 
 #       if (!$async ) {
 #           $i = 0
 #          $SavedTime = ([System.DateTime]::Now)
 #           $status = (Get-OTCJobStatus $resultBody.job_id -ErrorAction Continue ).status 
 #           if (-not $status )  {$status = 'UNKNOWN'}
 #           while (($status -ne "SUCCESS")-and ($i -le (6*120))) {
 #               Write-Progress -Activity ('Job in Status ' + (Get-OTCJobStatus $resultBody.job_id).status) -Status ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)) -PercentComplete ($i)
 #               sleep 10
 #               if ($i -lt 100) {$i++} # if $i > 100 then the script (Write-Progress) will fail
 #               $status = (Get-OTCJobStatus $resultBody.job_id -ErrorAction Continue ).status 
 #               if (-not $status )  {$status = 'UNKNOWN'}
 #               }
 #           write-verbose ("image $id was successfully deleted, Job takes " + ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)))
 #       }
        if ($resultBody ) {
            return $resultBody
        }
    } 
    catch {Catch-Error $_  }
}
#there should be no result
#if ($result) {$result.job_id}

<#
 .SYNOPSIS
 The Remove-OTCImage cmdlet will delete an image

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
 image id

 .EXAMPLE
 PS C:\Users\Administrator> Remove-OTCImage '34b565df-9963-4fba-8571-9264e50bdd14'
 
#>
export-modulemember -function Remove-OTCImage



function Update-OTCImage {

    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$id,
            [Parameter(Position=1,Mandatory=$true)][string]$parameter,
            [Parameter(Position=2,Mandatory=$false)][string]$value,
            [Parameter(,Position=3)][string][ValidateNotNullOrEmpty()][ValidateSet("add", "replace", "remove")]$op = 'replace'
        )
            
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # POST /v2/cloudimages/action 
    Set-Variable -Name URL -Value "$IMAGE_URL/v2/cloudimages/$id"
    Set-Variable -Name body -Value (' 
       [{"op": "' + $op + '",
        "path": "' + $parameter + '",
        "value": "' + $value + '"
        }]
    ')

    ## Making the call to the API
    try {
        Set-Variable -Name job -Value (Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -Body $body -ContentType application/json -Method Patch) 
        } 
    catch {Catch-Error $_ }
    
    ## Handling empty response bodies 
    # api call does not return anything
}
<#
 .SYNOPSIS
 The Update-OTCImage cmdlet will update parameters of an image

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
    ID
    parameter
    value
    op (replace (default), add, remove

 .EXAMPLE
    add metadata description
        PS C:\Users\Administrator> Update-OTCImage '34b565df-9963-4fba-8571-9264e50bdd14' '/__description' 'test image' 'add'
    removes metadata description
        PS C:\Users\Administrator> Update-OTCImage '34b565df-9963-4fba-8571-9264e50bdd14' '/__description' -op 'remove'
    updates metadata description
        PS C:\Users\Administrator> Update-OTCImage '34b565df-9963-4fba-8571-9264e50bdd14' '/__description' 'aei test image' 
    updates image name
        PS C:\Users\Administrator> Update-OTCImage '34b565df-9963-4fba-8571-9264e50bdd14' '/name' 'test_image' 
#>
export-modulemember -function Update-OTCImage


function Export-OTCImage {

    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$id,
            [Parameter(Position=1,Mandatory=$true)][string]$bucket_url,
            [Parameter(Position=2,Mandatory=$false)][string][ValidateNotNullOrEmpty()][ValidateSet("qcow2", "vhd", "vmdk","zvhd")]$file_format = 'zvhd',
            [Parameter(Position=3,Mandatory=$false)][switch]$async 
        )
            
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # POST /v1/cloudimages/{image_id}/file
    Set-Variable -Name URL -Value "$IMAGE_URL/v1/cloudimages/$id/file"
    Set-Variable -Name body -Value (' 
       {"file_format": "' + $file_format + '",
        "bucket_url": "' + $bucket_url + '"
        }
    ')

    Write-Verbose "Export-OTCImage: id: $id"
    Write-Verbose "Export-OTCImage: file_format: $file_format"
    Write-Verbose "Export-OTCImage: bucket_url: $bucket_url"
    Write-Verbose "Export-OTCImage: URL: $URL"
    Write-Verbose "Export-OTCImage: body: $body"
    write-verbose "Export-OTCImage: async: $async"

    ## Making the call to the API
    try {
        $resultbody = Invoke-RestMethod -Uri $URL -Headers $HeaderDictionary -Body $body -ContentType application/json -Method Post
        #$resultbody
        if (!$async ) {
            $i = 0
            $SavedTime = ([System.DateTime]::Now)
            $jobstatus = (Get-OTCJobStatus $resultbody.job_id -ErrorAction Continue).status
            write-verbose "Export-OTCImage: job status: $jobstatus"
            while (($jobstatus -ne "SUCCESS") -and ($jobstatus -ne "FAIL")) {
                Write-Progress -Activity "Job in Status $jobstatus" -Status ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)) -PercentComplete $i
                if ($i -lt 100) {$i++} # if $i > 100 then the script (Write-Progress) will fail
                sleep 10
                $jobstatus = (Get-OTCJobStatus $resultbody.job_id -ErrorAction Continue).status
                write-verbose "Export-OTCImage: job status: $jobstatus"
                }
            if ($jobstatus -eq "SUCCESS") {
                write-verbose ('Export-OTCImage: image export time: ' + ("{0:HH:mm:ss}" -f ([datetime](([System.DateTime]::Now) - $SavedTime).Ticks)))
            } 
            else {write-error "Export-OTCImage: Image export failed" }
        } 

        if ($resultbody.job_id) {
            return $resultbody.job_id
            }

        } 
    catch {Catch-Error $_ }
    
    ## Handling empty response bodies 
    # api call does not return anything
}
<#
 .SYNOPSIS
 The Export-OTCImage cmdlet exports an image to obs

 .DESCRIPTION
 See the synopsis field.

 .PARAMETER 
    ID
    bucket_url
    file_format (zvhd (default), vhd, vmdk, qcow2

 .EXAMPLE
    $newimage = Get-OTCprivateImages 'aei-bms-glance'|Get-OTCImage
    Export-OTCImage -id $newimage.id -bucket_url 'backet-name:file-name.ext' -file_format 'zvhd'

#>
export-modulemember -function Export-OTCImage


