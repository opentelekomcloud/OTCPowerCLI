

add-type @"
public struct OTCVolume {
   public string VolumeID;
   public string VolumeName;
   public string VolumeUrlBookmark;
   public string VolumeUrlSelf;
}
"@
#export-modulemember -type OTCVolume




function Get-DiskScsiLuns {
<#
  .SYNOPSIS
    Retrieves the SCSI Lun information for a disk.
 
  .DESCRIPTION
    Retrieves the SCSI Lun information for a disk.
 
  .PARAMETER  DevicePort
    Specify the physical port name e.g. /dev/sda , /dev/sdb ...
 
  .EXAMPLE
    PS C:\> Get-DiskScsiLuns
 
  .EXAMPLE
    PS C:\> Get-DiskScsiLuns -DevicePort /dev/sdn
 
  .OUTPUTS
    PSObject
 
  .NOTES
    Author: Andreas Eichhorn
    Version: 1.0
    Date: 13-11-2017
 
  .LINK
    https://
 
#>
 
 [CmdletBinding()]
  param([Parameter(Mandatory = $false,
                   Position = 0)]
 #       [alias("DevicePort")]
        [string] $DevicePort = '*'
  )
   
    process {
        try {
 #             $Win32_LogicalDisk = Get-WmiObject -Class Win32_LogicalDisk  |            Where-Object {$_.DeviceID -like $DeviceID}
              $Win32_LogicalDiskToPartition = Get-WmiObject -Class Win32_LogicalDiskToPartition 
              $Win32_DiskDriveToDiskPartition = Get-WmiObject -Class Win32_DiskDriveToDiskPartition 
              if ($DevicePort -match '/') {
                   $PnPid = ''
                   switch -wildcard ($DevicePort) {

                        #kvm
                        '/dev/sda' {$PnPid = 'E079AC4'}
                        '/dev/sdb' {$PnPid ='16D8363B' }
                        '/dev/sdc' {$PnPid ='134DCAD' } 
                        '/dev/sdd' {$PnPid ='79BBECA' } 
                        '/dev/sde' {$PnPid ='1071541E' }
                        '/dev/sdf' {$PnPid ='7A0B8A7' }
                        '/dev/sdg' {$PnPid ='1FADCB8F' }
                        '/dev/sdh' {$PnPid ='16DD3018' }
                        '/dev/sdi' {$PnPid ='2EEA4300' }
                        '/dev/sdj' {$PnPid ='2619A789' }
                        '/dev/sdk' {$PnPid ='28BF06A' }
                        '/dev/sdl' {$PnPid ='35561EFA' }
                        '/dev/sdm' {$PnPid ='11C867DB' }
                        '/dev/sdn' {$PnPid ='8F7CC64' }
                        '/dev/sdo' {$PnPid ='2104DF4C' }
                        '/dev/sdp' {$PnPid ='183443D5' }
                        '/dev/sdq' {$PnPid ='15E38109' }
                        '/dev/sdr' {$PnPid ='D12E592' }
                        '/dev/sds' {$PnPid ='251FF87A' }
                        '/dev/sdt' {$PnPid ='1C4F5D03' }
                        '/dev/sdu' {$PnPid ='345C6FEB' }
                        '/dev/sdv' {$PnPid ='2B8BD474' }
                        '/dev/sdw' {$PnPid ='7FE1D55' }
                        '/dev/sdx' {$PnPid ='3AC84BE5' } 
                       
                    }
                    $filter = "PNPDeviceID like '%" + $PnPid + "%'"
                    $Win32_DiskDrive = Get-WmiObject -Class Win32_DiskDrive -filter "$filter" 

                    # try to find a xen id
                    if (-not $Win32_DiskDrive) {

                          switch -wildcard ($DevicePort) {
                                #xen
                                '/dev/sda' {$PnPid = '12BC8F15'} 
                                '/dev/sdb' {$PnPid ='12741CA2' }
                                '/dev/sdc' {$PnPid ='313A69C0' }
                                '/dev/sdd' {$PnPid ='1465ECD7' }
                                '/dev/sde' {$PnPid ='3996988E' }
                                '/dev/sdf' {$PnPid ='306D8646' }
                                '/dev/sdg' {$PnPid ='343750B3' }
                                '/dev/sdh' {$PnPid ='15710395' }
                                '/dev/sdi' {$PnPid ='9554989' }
                                '/dev/sdj' {$PnPid ='2E85F540' }
                                '/dev/sdk' {$PnPid ='11B17857' }
                                '/dev/sdl' {$PnPid ='36E2240E' }
                                '/dev/sdm' {$PnPid ='2081A6E3' }
                                '/dev/sdn' {$PnPid ='1BB59C5' }
                                '/dev/sdo' {$PnPid ='18257815' }
                                '/dev/sdp' {$PnPid ='6A0D509' }
                                '/dev/sdq' {$PnPid ='44C4F5F' }
                                '/dev/sdr' {$PnPid ='19DFE910' }
                                '/dev/sds' {$PnPid ='25D4E2F3' }
                                '/dev/sdt' {$PnPid ='24EF222C' }
                                '/dev/sdu' {$PnPid ='27E267FA' }
                                '/dev/sdv' {$PnPid ='1623FED9' }
                                '/dev/sdw' {$PnPid ='2669CF35' }
                                '/dev/sdx' {$PnPid ='1740941D' }

                            }
                            $filter = "PNPDeviceID like '%" + $PnPid + "%'"
                            $Win32_DiskDrive = Get-WmiObject -Class Win32_DiskDrive -filter "$filter" 
                    } #end if not $Win32_DiskDrive


              } else { 
                $Win32_DiskDrive = Get-WmiObject -Class Win32_DiskDrive 
                $DevicePort = '' 
              }
              # Search the SCSI Lun Unit for the disk
              # $Win32_DiskDrive | fl *
              $Win32_DiskDrive |
                ForEach-Object {
                  if ($_)
                  {
                    $DiskDrive = $_
                    #$DiskDrive|fl *
                    $DiskDriveToDiskPartition = $Win32_DiskDriveToDiskPartition | Where-Object {$_.Antecedent -eq $DiskDrive.Path}
                    if ($DiskDriveToDiskPartition) {
                        $LogicalDiskToPartition = $Win32_LogicalDiskToPartition | Where-Object {$_.Antecedent -eq $DiskDriveToDiskPartition.Dependent}
                        if ($LogicalDiskToPartition) {
                            $LogicalDisk = $Win32_LogicalDisk|? {$_.Path.path -eq $LogicalDiskToPartition.Dependent}
                        } else {$LogicalDisk = $null}
                    } else {$LogicalDisk = $null}
#Write-Verbose "DevicePort: $DevicePort "
#Write-Verbose $PnPid
#$(($DiskDrive|?{$_.Partitions -eq $DiskDrive.Partitions}).PNPDeviceID) |Out-String|Write-Verbose
                        $DevicePort = '' 
                    if ($DiskDrive) {
                        #map physical device name to PNPDeviceID
                        switch -wildcard (($DiskDrive|?{$_.Partitions -eq $DiskDrive.Partitions}).PNPDeviceID) {

                            #kvm
                            '*E079AC4*' {$DevicePort = '/dev/sda'} 
                            '*12741CA2*' {$DevicePort = '/dev/sdb'}
                            '*134DCAD*' {$DevicePort = '/dev/sdc'} 
                            '*79BBECA*' {$DevicePort = '/dev/sdd'} 
                            '*1071541E*' {$DevicePort = '/dev/sde'}
                            '*7A0B8A7*' {$DevicePort = '/dev/sdf'}
                            '*1FADCB8F*' {$DevicePort = '/dev/sdg'}
                            '*16DD3018*' {$DevicePort = '/dev/sdh'}
                            '*2EEA4300*' {$DevicePort = '/dev/sdi'}
                            '*2619A789*' {$DevicePort = '/dev/sdj'}
                            '*28BF06A*' {$DevicePort = '/dev/sdk'}
                            '*35561EFA*' {$DevicePort = '/dev/sdl'}
                            '*11C867DB*' {$DevicePort = '/dev/sdm'}
                            '*8F7CC64*' {$DevicePort = '/dev/sdn'} 
                            '*2104DF4C*' {$DevicePort = '/dev/sdo'}
                            '*183443D5*' {$DevicePort = '/dev/sdp'}
                            '*15E38109*' {$DevicePort = '/dev/sdq'}
                            '*D12E592*' {$DevicePort = '/dev/sdr'}
                            '*251FF87A*' {$DevicePort = '/dev/sds'}
                            '*1C4F5D03*' {$DevicePort = '/dev/sdt'}
                            '*345C6FEB*' {$DevicePort = '/dev/sdu'} 
                            '*2B8BD474*' {$DevicePort = '/dev/sdv'}
                            '*7FE1D55*' {$DevicePort = '/dev/sdw'}
                            '*3AC84BE5*' {$DevicePort = '/dev/sdx'}



                            #xen
                            '*12BC8F15*' {$DevicePort = '/dev/sda'}
                            '*16D8363B*' {$DevicePort = '/dev/sdb'}
                            '*313A69C0*' {$DevicePort = '/dev/sdc'}
                            '*1465ECD7*' {$DevicePort = '/dev/sdd'}
                            '*3996988E*' {$DevicePort = '/dev/sde'}
                            '*306D8646*' {$DevicePort = '/dev/sdf'}
                            '*343750B3*' {$DevicePort = '/dev/sdg'}
                            '*15710395*' {$DevicePort = '/dev/sdh'}
                            '*9554989*' {$DevicePort = '/dev/sdi'}
                            '*2E85F540*' {$DevicePort = '/dev/sdj'}
                            '*11B17857*' {$DevicePort = '/dev/sdk'}
                            '*36E2240E*' {$DevicePort = '/dev/sdl'}
                            '*2081A6E3*' {$DevicePort = '/dev/sdm'}
                            '*1BB59C5*' {$DevicePort = '/dev/sdn'}
                            '*18257815*' {$DevicePort = '/dev/sdo'}
                            '*6A0D509*' {$DevicePort = '/dev/sdp'}
                            '*44C4F5F*' {$DevicePort = '/dev/sdq'}
                            '*19DFE910*' {$DevicePort = '/dev/sdr'}
                            '*25D4E2F3*' {$DevicePort = '/dev/sds'}
                            '*24EF222C*' {$DevicePort = '/dev/sdt'}
                            '*27E267FA*' {$DevicePort = '/dev/sdu'}
                            '*1623FED9*' {$DevicePort = '/dev/sdv'}
                            '*2669CF35*' {$DevicePort = '/dev/sdw'}
                            '*1740941D*' {$DevicePort = '/dev/sdx'}

                        }
#Write-Verbose "2 DevicePort: $DevicePort "
                       # Return the results
                        New-Object -TypeName PSObject -Property @{
                            Index = $DiskDrive.Index
                            DeviceID = $LogicalDisk.DeviceID
                            SCSIBus = $DiskDrive.SCSIBus
                            SCSIPort = $DiskDrive.SCSIPort  
                            SCSITargetId = $DiskDrive.SCSITargetId
                            SCSILogicalUnit = $DiskDrive.SCSILogicalUnit
                            DiskSize = [math]::round($DiskDrive.Size / 1GB,2) 
                            PNPDeviceID = $DiskDrive.PNPDeviceID
                            DevicePort = $DevicePort

    #                        DiskSize = ($DiskDrive.Size / 1GB).ToString(".00 GB")
    #                        Index = $DiskDrive.Index
    #                        InterfaceType = $DiskDrive.InterfaceType
    #                        Partitions = $DiskDrive.Partitions
    #                       get all properties
    #                       $DiskDrive.Properties

                        }
                    }
                }
            }

        }
        catch {
          Write-Warning "Unable to get disk information for computer $Computer.`n$($_.Exception.Message)"
        }
    }
}
export-modulemember -function Get-DiskScsiLuns


function Get-OTCVolumes {
    
    Param(  [Parameter(Mandatory=$false)][string]$Name,
            [Parameter(Mandatory=$false)][string]$ID
            )    

    ## Authentication token check/retrieval
    Get-AuthToken
    #$id = 'b1e5da8c-e327-49e6-a184-820ebe051084'
    Write-Verbose ('$Name: ' + $Name)
    Write-Verbose ('$ID: ' + $ID)

    ## Setting variables needed to execute this function
    # GET /v2/{tenant_id}/cloudvolumes 
    # GET /v2/{tenant_id}/volumes 
    Set-Variable -Name URL -Value "$VOLUMEV2_URL/cloudvolumes"

    ## Making the call to the API 
    $VolumeList = (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary)

    ## Handling empty response bodies
    if ($VolumeList -eq $null) {
        Write-error 'No volumes found.'
    }
    else {
        if ((!$Name) -and (!$ID)) { 
            $volumes = $VolumeList.volumes
        } 
        else {
            if ($Name -and $ID) {
                $volumes = ($VolumeList.volumes|?{($_.name -match $Name) -and $($_.ID -match $ID) })
            }else {
                if ($Name ) {
                   $volumes = ($VolumeList.volumes|?{$_.name -match $Name})
                }else {
                    if ($ID ) {
                       $volumes = ($VolumeList.volumes|?{$_.id -match $ID})
                    }# end if ($ID)
                }# end if ($Name)
            }# end if ($Name -and $ID)
        }# end if (!$Name)
 
        if ($volumes -eq $null) {
            Write-error 'No volumes found.'
        }
        else {
            foreach ($volume in $volumes) {
                New-Object -TypeName OTCVolume -Property @{
                   VolumeID =  $volume.id
                   VolumeName =  $volume.name
                   VolumeUrlBookmark =  ($volume.links | Where-Object {$_.rel -eq 'bookmark'}).href
                   VolumeUrlSelf =  ($volume.links | Where-Object {$_.rel -eq 'self'}).href
                }
            }
        }
    }
}
export-modulemember -function Get-OTCVolumes


function Get-OTCVolume () {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$false)][OTCVolume]$OTCVolume,
            [Parameter(Mandatory=$false)]$id
            )

    if (($OTCVolume) -or ($id)) {
        ## Authentication token check/retrieval
        Get-AuthToken

        ## Setting variables needed to execute this function
        if ($OTCVolume) {$id = $OTCVolume.volumeid}
        Write-Verbose ('$id: ' + $id)
        # GET /v2/{tenant_id}/volumes/{volume_id}  
        Set-Variable -Name URL -Value "$VOLUMEV2_URL/volumes/$id"
        Write-Verbose ('$url: ' + $url)
    #    Set-Variable -Name URL -Value $volume.VolumeUrlBookmark
    #    Write-Verbose ('$url: ' + $url)

        ## Making the call to the API 
        $VolumeDetails = Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary -timeout 30

        ## Handling empty response bodies 
        if ($VolumeDetails -eq $null) {
            write-error 'No volume found.'
        }
        else {
            ## return results
            $VolumeDetails.volume | Sort-Object Name 

        }
    } else {
        Write-error 'No parameter given.'
        break
    }
}
export-modulemember -function Get-OTCVolume 


function New-OTCVolume {

    Param(  [Parameter(Position=0,Mandatory=$true)][string]$VolumeName,
            [Parameter(Position=1,Mandatory=$true)][Int]$volumeSize,
            [Parameter(Position=2,Mandatory=$true)][string]$availability_zone,
            [Parameter(Position=3,Mandatory=$false)][string]$volume_type
            )

    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # POST /v2/{tenant_id}/volumes 
    Set-Variable -Name URL -Value "$VOLUMEV2_URL/volumes"
    Set-Variable -Name Volume -Value (' 
                 { 	"volume":
                    { 
 					"name": "' + $VolumeName + '", 
 					"size": "' + $volumeSize + '" ,
 					"availability_zone": "' + $availability_zone + '" ,
 					"volume_type" : "' + $volume_type + '",
                    "bootable":"True"
 	                }   
                 }' )

    ## Making the call to the token authentication API and saving it's output as a global variable for reference in every other function.
    Set-Variable -Name volume -Value (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary -Body $Volume -ContentType application/json -Method Post) 

    ## Making the call to the API
    #$Volume = (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary)

    ## Handling empty response bodies 
    if ($Volume -eq $null) {
        write-error 'No cloud volumes found.'
    }
    else {
        ## return results
        $Volume.volume | Sort-Object Name

    }
}
export-modulemember -function New-OTCVolume


function Remove-OTCVolume () {
    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string[]]$volumeID
            )
 
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # DELETE /v2/{tenant_id}/volumes/{volume_id} 
    Set-Variable -Name URL -Value "$VOLUMEV2_URL/volumes/$volumeID" 

    ## Making the call to the API
    $Volume = Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary -Method Delete

    ## Handling empty response bodies 
    if ($Volume -eq $null) {
        write-error 'No cloud volumes found.'
    }
    else {
        ## return results
        $Volume.volume | Sort-Object Name 

    }
}
export-modulemember -function Remove-OTCVolume


function Mount-OTCVolume  {

    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$ServerID,
            [Parameter(Position=1,Mandatory=$true)][string]$VolumeID,
            [Parameter(Position=2,Mandatory=$true)][string]$device,
            [Parameter(Position=3,Mandatory=$false)][switch]$async 
           )

    Write-Verbose "Mount-OTCVolume: start"
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # POST /v2/{tenant_id}/servers/{server_id}/os-volume_attachments 
    # Set-Variable -Name URL -Value "$COMPUTE_URL/servers/$ServerID/os-volume_attachments"

    # POST /v1/{tenant_id}/cloudservers/{server_id}/attachvolume
    Set-Variable -Name URL -Value "$($COMPUTE_URL.Replace('/v2/','/v1/'))/cloudservers/$ServerID/attachvolume"

    Set-Variable -Name Volume -Value (' 
                 { 	"volumeAttachment":
                    { 
 					"volumeId": "' + $VolumeID + '",
                    "device":"' + $device + '"
 	                }   
                 }' )
                
    ## Making the call to the API 
    try {
        Set-Variable -Name result -Value (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary -Body $Volume -ContentType application/json -Method Post) 
        if (!$async ) {
            $i = 0
            $Volume = get-OTCVolume -ID $VolumeID
            $VolumeStatus = $Volume.status
            Write-Verbose "Mount-OTCVolume: Info: VolumeStatus: $VolumeStatus"
            while (($VolumeStatus -match 'available') -and ($i -le 5)) {
                Write-Progress -Activity "Volume is in status $VolumeStatus" -Status "$i" -PercentComplete ($i/30*10)
                $i++
                sleep 10
                $Volume = get-OTCVolume -ID $VolumeID
                $VolumeStatus = (get-OTCVolume -ID $VolumeID).status
                Write-Verbose "Mount-OTCVolume: Info: VolumeStatus: $VolumeStatus"
            }
            while (($VolumeStatus -match 'attaching') -and ($i -le 30)) {
                Write-Progress -Activity "Volume is in status $VolumeStatus" -Status "$i" -PercentComplete ($i/30*10)
                $i++
                sleep 10
                $Volume = get-OTCVolume -ID $VolumeID
                $VolumeStatus = (get-OTCVolume -ID $VolumeID).status
                Write-Verbose "Mount-OTCVolume: Info: VolumeStatus: $VolumeStatus"
            }
            if ($VolumeStatus -eq 'in-use') {
                 write-verbose "Mount-OTCVolume: Info: Volume $VolumeID  was successfully atached, Job takes $i x10 seconds"
                 } else {

                 write-error "Mount-OTCVolume: Error: Volume $VolumeID  was not atached"
                 }
        } 
        $Volume.volumeAttachment
    }
    catch {Catch-Error $_}
}
export-modulemember -function Mount-OTCVolume



function Dismount-OTCVolume  {

    Param(  [Parameter(ValueFromPipeline,Position=0,Mandatory=$true)][string]$ServerID,
            [Parameter(Position=1,Mandatory=$true)][string]$VolumeID,
            [Parameter(Position=2,Mandatory=$false)][switch]$async 
           )

    Write-Verbose "Dismount-OTCVolume: Info: start"
    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # DELETE /v2/{tenant_id}/servers/{server_id}/os-volume_attachments/{volume_id} 
    # Set-Variable -Name URL -Value "$COMPUTE_URL/servers/$ServerID/os-volume_attachments/$VolumeID"

    # DELETE /v1/{tenant_id}/cloudservers/{server_id}/detachvolume/{volume_id}
    Set-Variable -Name URL -Value "$($COMPUTE_URL.Replace('/v2/','/v1/'))/cloudservers/$ServerID/detachvolume/$VolumeID"

    ## Making the call to the API 
    try {
        Set-Variable -Name result -Value (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary -Body $Volume -ContentType application/json -Method Delete) 

        if (!$async ) {
            $i = 0
            $Volume = get-OTCVolume -ID $VolumeID
            $VolumeStatus = $Volume.status
            Write-Verbose "Dismount-OTCVolume: Info: VolumeStatus: $VolumeStatus"
            while (($VolumeStatus -match 'in-use') -and ($i -le 5)) {
                Write-Progress -Activity "Volume is in status $VolumeStatus" -Status "$i" -PercentComplete ($i/30*10)
                $i++
                sleep 10
                $Volume = get-OTCVolume -ID $VolumeID
                $VolumeStatus = $Volume.status
                Write-Verbose "Dismount-OTCVolume: Info: VolumeStatus: $VolumeStatus"
            }
            while (($VolumeStatus -match 'detaching') -and ($i -le 30)) {
                Write-Progress -Activity "Volume is in status $VolumeStatus" -Status "$i" -PercentComplete ($i/30*10)
                $i++
                sleep 10
                $Volume = get-OTCVolume -ID $VolumeID
                $VolumeStatus = $Volume.status
                Write-Verbose "Dismount-OTCVolume: Info: VolumeStatus: $VolumeStatus"
            }
            if ($VolumeStatus -match 'available') {
                 write-verbose "Dismount-OTCVolume: Info: Volume $VolumeID  was successfully detached, Job takes $i x10 seconds"
            } else {

                 write-error "Dismount-OTCVolume: Error: Volume $VolumeID  was not detached"
            }
        } 
        $Volume.volumeAttachment
    }
    catch {Catch-Error $_ }
}
export-modulemember -function Dismount-OTCVolume


function Update-OTCVolume {

    Param(  [Parameter(Position=0,Mandatory=$true)][string]$VolumeID,
            [Parameter(Position=2,Mandatory=$true)][string]$VolumeName,
            [Parameter(Position=3,Mandatory=$true)][Int]$volumeSize,
            [Parameter(Position=4,Mandatory=$false)][string]$description,
            [Parameter(Position=5,Mandatory=$false)][string]$bootable
            )

    ## Authentication token check/retrieval
    Get-AuthToken

    ## Setting variables needed to execute this function
    # POST /v2/{tenant_id}/volumes/{volume_id} 
    # PUT /v2/{tenant_id}/cloudvolumes/{volume_id}
    Set-Variable -Name URL -Value "$VOLUMEV2_URL/volumes/$VolumeID"
    Set-Variable -Name Volume -Value (' 
                 { 	"volume":
                    { 
 					"name": "' + $VolumeName + '", 
 					"size": "' + $volumeSize + '" ,
 					"availability_zone": "' + $availability_zone + '" ,
 					"description" : "' + $description + '",
                    "bootable":"' + $bootable + '"
 	                }   
                 }' )
    <#
    Request URL:https://console.otctest.t-systems.com/ecm/rest/v2/updateVolumes/6428303d77004289a940cb2e1d1fa959/volumes/76f8a59b-de78-4cf6-be86-5f120ad8d29e

    volume:{
        availability_zone:"eu-de-01"
        description:"test"
        metadata:{}
        name:"aeitest"
        size:30
        snapshot_id:null
        source_volid:null
        volume_type:"SSD"
    }
    #>

    ## Making the call to the token authentication API and saving it's output as a global variable for reference in every other function.
    Set-Variable -Name volume -Value (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary -Body $Volume -ContentType application/json -Method PUT) 

    ## Making the call to the API
    #$Volume = (Invoke-RestMethod -Uri $URL  -Headers $HeaderDictionary)

    ## Handling empty response bodies 
    if ($Volume -eq $null) {
        write-error 'No cloud volumes found.'
    }
    else {
        ## return results
        $Volume.volume | Sort-Object Name

    }
}
export-modulemember -function Update-OTCVolume