$TenantID = "<your tenant>"

Write-Host "Starting backup process for tenant $($TenantID)"
Get-CyAPI -Console $TenantID

if ((Get-CyAPIHandle) -eq $null) {
    throw "Could not connect."
}

$Timestamp = get-date -Format "yyyyMMdd-hhmmss"
$File = "$($Timestamp)_$($TenantID)_Backup.json"
$TenantID = (Get-CyAPIHandle).APITenantId

Write-Host -NoNewline "Retrieving devices... "
$Devices = Get-CyDeviceList
Write-Host -ForegroundColor Green "Done"

Write-Host -NoNewline "Retrieving policies... "
$Policies = Get-CyPolicyList | Get-CyPolicy
Write-Host -ForegroundColor Green "Done"

Write-Host -NoNewline "Retrieving zones... "
$Zones = Get-CyZoneList | Get-CyZone
Write-Host -ForegroundColor Green "Done"

Write-Host -NoNewline "Retrieving users... "
$Users = Get-CyUserList | Get-CyUserDetail
Write-Host -ForegroundColor Green "Done"

$ZoneMembership = foreach($zone in $Zones)  {
    Write-Host -NoNewline "Retrieving device membership for zone $($zone.name)... "
    $Members = Get-CyDeviceList -Zone $zone
    @{
        "Zone" = $Zone
        "ZoneMembers" = $Members
    }
    Write-Host -ForegroundColor Green "Done"
}

$Backup = @{
    Timestamp = "$($Timestamp)"
    TenantConsoleID = $TenantID
    TenantID = $TenantID
    Devices = $Devices
    Policies = $Policies
    Zones = $Zones
    ZoneMembership = $ZoneMembership
    Users = $Users
}

ConvertTo-Json $Backup -Depth 100 | Out-File $File
