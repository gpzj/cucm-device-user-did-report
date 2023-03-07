class DeviceRecord {
    [string]$Location
    [string]$PhoneLicenseType
    [string]$Owner
    [string]$PhoneType
    [string]$DID
}


class LocationCount {
    [string]$Location
    [int]$UserCount
    [int]$UserDIDCount
    [int]$CAPCount
    [int]$CAPDIDCount
    [int]$AnalogCount
    [int]$AnalogDIDCount
}

$deviceExportPath        = 'path/to/your/device/csv/see/readme'
$translationPatternsPath = 'path/to/your/translationpatterns/csv/see/readme'

if (-not $phones) {$phones = Import-Csv $deviceExportPath} else {write-host 'phones already imported, manually reimport if needed'}
if (-not $patterns) {$patterns = Import-Csv $translationPatternsPath} else {write-host 'patterns already imported, manually reimport if needed'}
$devicepools = $phones | Select-Object -Unique -Property 'Device Pool'
$allDeviceRecords = @()
$allLocationCounts = @()

foreach ($devicepool in $devicepools) {

    $LocationLoopProgressParameters = @{
        Activity         = "Changing Locations - $($devicepool.'device pool')"
        Status           = "Progress-> $([math]::Round($devicepools.IndexOf($devicepool) / $devicepools.count * 100))%"
        PercentComplete  = $devicepools.IndexOf($devicepool) / $devicepools.count * 100
        CurrentOperation = 'LocationLoop'
    }
    Write-Progress @LocationLoopProgressParameters
    Start-Sleep -Seconds 1

    $locationCount = new-object LocationCount
    $locationCount.Location = $devicepool.'Device Pool'

    $locationPhones = $phones | Where-Object {$_.'Device Pool' -like $devicepool.'Device Pool'}

    foreach ($phone in $locationPhones) {

        $DeviceLoopProgressParameters = @{
            Activity         = "Counting Devices in $($devicepool.'device pool')"
            Status           = "Progress-> $([math]::Round($locationPhones.IndexOf($phone) / $locationPhones.count * 100))%"
            PercentComplete  = $locationPhones.IndexOf($phone) / $locationPhones.count * 100
            CurrentOperation = 'DeviceLoop'
        }
        Write-Progress @DeviceLoopProgressParameters

        if ($phone.'Directory Number 1' -in $patterns.'Called Party Transform Mask') {
            $DID = $true
        } else {
            $DID = $false
        }

        if ($phone.'Device Name' -inotlike 'SEP*' -and $phone.'Device Name' -inotlike 'AN*') {continue}

        if ($phone.'Owner User ID') {
            $locationCount.UserCount += 1
            if ($DID) {$locationCount.UserDIDCount += 1}
            $PhoneLicenseType = 'User'
        } else {
            $locationCount.CAPCount += 1
            if ($DID) {$locationCount.CAPDIDCount += 1}
            $PhoneLicenseType = 'CAP'
        }

        if ($phone.'Device Name' -ilike 'AN*') {
            $locationCount.AnalogCount += 1
            if ($DID) {$locationCount.AnalogDIDCount += 1}
        }


        $deviceRecord = new-object DeviceRecord

        $deviceRecord.Location         = $devicepool.'Device Pool'
        $deviceRecord.PhoneLicenseType = $PhoneLicenseType
        $deviceRecord.Owner            = $phone.'Owner User ID'.ToLower()
        $deviceRecord.PhoneType        = if ($phones.'Device Name' -ilike 'SEP*') {'VOIP'} elseIf ($phones.'Device Name' -ilike 'AN*') {'ANALOG'} else {'UNKNOWN'}
        $deviceRecord.DID              = $DID

        $allDeviceRecords += $deviceRecord
        #$deviceRecord
               

    } # end phone foreach

    $allLocationCounts += $locationCount

} # end devicepool foreach


#$count = 0
#foreach ($pattern in $patterns) {
#    $PatternLoopProgressParameters = @{
#        Activity         = 'Checking for multiple counts'
#        Status           = "Progress-> $([math]::Round(($patterns.IndexOf($pattern) / $patterns.count * 100), 2))%"
#        PercentComplete  = $patterns.IndexOf($pattern) / $patterns.count * 100
#        CurrentOperation = 'patterns'
#    }
#    Write-Progress @PatternLoopProgressParameters
#    if (($patterns | Where-Object {$_.'Called Party Transform Mask' -like $pattern.'Called Party Transform Mask'}).count -eq 1) {write-host 'bingo' }
#}
#  
