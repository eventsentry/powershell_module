New-Variable -Name 'ESRegPath' -Value 'HKLM:\Software\Wow6432Node\netikus.net\EventSentry\' -Option ReadOnly

New-Variable -Name 'ESRegPathGroups' -Value 'HKLM:\Software\Wow6432Node\netikus.net\EventSentry\Filtergroups\' -Option ReadOnly
New-Variable -Name 'ESRegPathGroupsX64' -Value 'HKLM:\Software\netikus.net\EventSentry\Filtergroups\' -Option ReadOnly

New-Variable -Name 'ESRegPathAuthenticationHKLM' -Value 'HKLM:\SOFTWARE\WOW6432Node\netikus.net\EventSentry\Authentication\' -Option ReadOnly
New-Variable -Name 'ESRegPathAuthenticationHKCUx64' -Value 'HKCU:\SOFTWARE\netikus.net\EventSentry\Authentication\' -Option ReadOnly

New-Variable -Name 'ESRegPathTrigger' -Value 'HKLM:\Software\Wow6432Node\netikus.net\EventSentry\Notify\' -Option ReadOnly
New-Variable -Name 'ESRegPathCollectorDeployConfig' -Value 'HKLM:\Software\Wow6432Node\netikus.net\EventSentry\Collector\' -Option ReadOnly

function GetAuthenticationID($authName)
{
	$authID = ""
	
	$regAuth = Get-ChildItem $ESRegPathAuthenticationHKLM
	
	foreach ($key in $regAuth)
	{
		$regKey = $key.Name.Replace("HKEY_LOCAL_MACHINE", "HKLM:")
		$temp = Get-ItemPropertyValue $regKey -Name 'name'

		if ($authName -eq $temp)
		{
			$authID = $regKey.substring($regKey.length - 36, 36)
			return $authID
		}
	}
	
	return $authID
}

function TriggerIncrease
{
	$trigger = Get-ItemPropertyValue $ESRegPathTrigger -Name "trigger"
	$trigger++
	
	writeRegistryValueAllPlatforms $ESRegPathTrigger "trigger" $trigger DWORD
	
	$deployConfig = Get-ItemPropertyValue $ESRegPathCollectorDeployConfig -Name "deploy_config"
	If ($deployConfig -eq 2)
	{
		$installDir = Get-ItemPropertyValue $ESRegPath -Name "installdir"
		$remoteUpdateUtility = $installdir + "\\eventsentry_upd.exe"
		
		Start-Process $remoteUpdateUtility -Wait -ArgumentList "/exportconfig" -NoNewWindow -RedirectStandardOutput ".\NUL"
		
		writeRegistryValueAllPlatforms $ESRegPathTrigger "trigger_approved_for_deploy" $trigger DWORD
	}
}

function WriteHeartbeatTriggerFile
{
	Out-File -FilePath "$env:SYSTEMROOT\SYSTEM32\eventsentry\eventsentry_hb_svc.reg" 
}

function saveConfig
{
	TriggerIncrease
	
	WriteHeartbeatTriggerFile
}

function writeRegistryValueAllPlatforms($regPath, $regName, $regValue, $regType)
{
	$regPathX64 = $regPath.Replace("Wow6432Node", "")
	
	New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType $retType -Force | Out-Null
	New-ItemProperty -Path $regPathX64 -Name $regName -Value $regValue -PropertyType $retType -Force | Out-Null
}

function FileTimeToLowAndHigh
{
    Param(
        [Parameter(Mandatory=$true)]
        [uint64]$fileTime
    )

	$valueLow  = $fileTime -band [uint32]"0xFFFFFFFF"
	$valueHigh = $fileTime -shr 32
	
	$retVal = @()
	
	$retVal += $valueLow
	$retVal += $valueHigh
	
	return ,$retVal
}

function Get-HostCount($Group)
{
    $ErrorActionPreference = "Stop"
    
    If ($Group.length -eq 0) { throw "No group specified" }
    
    $regPath = $ESRegPathGroups + $Group
    
    try
    {
        $regKey = (Get-ItemProperty $regPath)
    }
    catch { throw "Group does not exist" }
    
    $computerCount = 0

    $regKey.PSObject.Properties | ForEach-Object {
        If ($_.Name -eq "total")
        {
            #Write-Host $_.Name ' = ' $_.Value
            $computerCount = $_.Value
        }
    }

    return $computerCount;
}

function ManagementConsoleIsRunning
{
    $guiIsActive32 = Get-Process eventsentry_gui -ErrorAction SilentlyContinue
    $guiIsActive64 = Get-Process eventsentry_gui_x64 -ErrorAction SilentlyContinue
    
    return $guiIsActive32 -or $guiIsActive64
}

function IsValidNumber
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$numberToCheck
    )
	
	[Int32]$numIndex = $null

	If ([Int32]::TryParse($numberToCheck,[ref]$numIndex))
		{ return $true }
	Else
		{ Write-Host "$numberToCheck is not a number" }
		
	return $false
}

function Get-ESHosts
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Group
    )
    $ErrorActionPreference = "Stop"
   
    $regPath = $ESRegPathGroups + $Group
    
    $computerCount = Get-HostCount($Group)
    
    $regKey.PSObject.Properties | ForEach-Object {
        If ($_.Name -eq 'total')
        {
            #Write-Host $_.Name ' = ' $_.Value
            $computerCount = $_.Value
        }
    }

    for ($i = 0; $i -lt $computerCount; $i++) 
    {
        $regValueIp = $i.ToString() + "_ip"

        $hostname = Get-ItemPropertyValue $regPath -Name $i
        $ip = ""

        try
        {
            $ip = Get-ItemPropertyValue $regPath -Name $regValueIp
        }
        catch
        {}
        
        Write-Host -NoNewLine $hostname;
        
        If ($ip.length -gt 0) 
            { Write-Host " ($ip)" }
        Else
            { Write-Host "" }
    }
}

function Check-Host($Group, $Hostname, $IP)
{
	$retVal = 0
	
    $regPath = $ESRegPathGroups + $Group
    
    $computerCount = Get-HostCount($Group)
    
    $regKey = (Get-ItemProperty $regPath)

    $regKey.PSObject.Properties | ForEach-Object {
        If ($_.Value -eq $Hostname)
            { $retVal = 1 }
    }

    return $retVal;
}

function GetHostID($Group, $Hostname, $IP)
{
	$retVal = ""
	
    $regPath = $ESRegPathGroups + $Group
    
    $computerCount = Get-HostCount($Group)
    
    $regKey = (Get-ItemProperty $regPath)

    $regKey.PSObject.Properties | ForEach-Object {
        If ($_.Value -eq $Hostname)
        { 
			$retVal = $_.Name
		}
    }

    return $retVal;
}

function Set-ESAuthPasswordWindows
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$AuthName,
        [Parameter(Mandatory=$true)]
        [string]$AuthPassword
    )
	$ErrorActionPreference = "Stop"
	
    if (ManagementConsoleIsRunning)
        { throw "EventSentry Management Console is running, only read-only actions can be performed." }

	$authID = GetAuthenticationID($AuthName)
	
	If ($authID.length -eq 0)
		{ throw "The specified authentication name cannot be found" }
	Else
	{
		# Verify this is windows-only authentication
		$regPathHKLM = $ESRegPathAuthenticationHKLM + $authID		
		$regValue = Get-ItemProperty -Path $regPathHKLM -Name 'windows_login' -ErrorAction SilentlyContinue
		if ($regValue.length -eq 0)
			{ throw "The password for the specififed authentication credentials cannot be updated since they are SNMP-only credentials" }

		# Create encrypted password
		Add-Type -AssemblyName System.Security

		$pwdAsBytes = $AuthPassword.ToCharArray() | % {[byte] $_}
		$pwdAsBytes += 0;

		$encryptedBytes = [System.Security.Cryptography.ProtectedData]::Protect(
							$pwdAsBytes, 
							$null, 
							[System.Security.Cryptography.DataProtectionScope]::CurrentUser)

		# Store in registry
		$regPathPassword = $ESRegPathAuthenticationHKCUx64 + $authID
		New-ItemProperty -Path $regPathPassword -Name 'windows_password' -Value $encryptedBytes -PropertyType Binary -Force | Out-Null
	}
	
	Remove-Variable -Name AuthPassword -Force -ErrorAction SilentlyContinue
	[System.GC]::Collect()
}

function Test-ESGroup
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Group
    )
    $ErrorActionPreference = "Stop"
	
	$success = $false
    
    $regPath = $ESRegPathGroups + $Group
	
	try
	{    
		$unused = Get-ItemProperty $regPath
		$success = $true
	}
	catch
	{}
	
	return $success
}

function Add-ESGroup
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Group
    )
    $ErrorActionPreference = "Stop"
    
    If (ManagementConsoleIsRunning)
        { throw "EventSentry Management Console is running, only read-only actions can be performed." }
        
    If (Test-ESGroup $Group)
        { throw "Group $Group already exists." }
    
    New-Item -Path $ESRegPathGroups -Name $Group | Out-Null
	New-Item -Path $ESRegPathGroupsX64 -Name $Group | Out-Null
	
	saveConfig
}

function Set-ESGroupProperty
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Group,
        [Parameter(Mandatory=$true)]
        [string]$PropertyType,
        [Parameter(Mandatory=$true)]
        [string]$PropertyValue
    )
	
    If (ManagementConsoleIsRunning)
        { throw "EventSentry Management Console is running, only read-only actions can be performed." }

	$groupExists = Test-ESGroup $Group
	If ($groupExists -eq $false)
		{ throw "The specified group $Group does not exist" }
		
	$PropertyValue = $PropertyValue.ToLower()
		
	$regName = ""
	$regValue = $PropertyValue
	
	$isValidNumber = IsValidNumber $PropertyValue
	$hasToBeNumber = $false

	If ($PropertyType -eq "RepeatFailed")
	{
		$regName = "RepeatFailed"
		
		If ($PropertyValue -eq "yes" -Or $PropertyValue -eq "true" -Or $PropertyValue -eq "1")
			{ $regValue = "1" }
		Else
			{ $regValue = "0" }
	}
	ElseIf ($PropertyType -eq "CollectPingStats")
	{
		$regName = "PingDB"
		
		If ($PropertyValue -eq "yes" -Or $PropertyValue -eq "true" -Or $PropertyValue -eq "1")
			{ $regValue = "1" }
		Else
			{ $regValue = "0" }
	}
	ElseIf ($PropertyType -eq "RequiredErrorCount")
	{
		$regName = "RequiredErrorCount"
		$hasToBeNumber = $true
	}
	ElseIf ($PropertyType -eq "PacketCount")
	{
		$regName = "PingPacketCount"
		$hasToBeNumber = $true
	}
	ElseIf ($PropertyType -eq "PacketSize")
	{
		$regName = "PingPacketSize"
		$hasToBeNumber = $true
	}
	ElseIf ($PropertyType -eq "RoundTrip")
	{
		$regName = "PingRoundtrip"
		$hasToBeNumber = $true
	}
	ElseIf ($PropertyType -eq "SuccessPercentage")
	{
		$regName = "PingSuccessrate"
		$hasToBeNumber = $true
	}

	If ($regName.Length -eq 0)
		{ throw "Unsupported property type specified" }
		
	If ($hasToBeNumber -And $isValidNumber -eq $false)
		{ throw "Invalid error count, must be a number" }
	
	$regPathGroup = $ESRegPathGroups + "\" + $Group
	$regPathGroupX64 = $ESRegPathGroupsX64 + "\" + $Group

	Set-ItemProperty -Path $regPathGroup -Name $regName -Value $regValue -Type DWORD -Force | Out-Null
	try {
		Set-ItemProperty -Path $regPathGroupX64 -Name $regName -Value $regValue -Type DWORD -Force | Out-Null
	} catch {}
	
	saveConfig
}

function Add-ESVariable
{
	Param(
        [Parameter(Mandatory=$true)]
		[ValidateLength(1,196)]
		[ValidatePattern("^[a-zA-Z0-9]+$")]
        [string]$Name,
        [Parameter(Mandatory=$true)]
		[ValidateLength(1,512)]
        [string]$DefaultValue
    )
	
    If (ManagementConsoleIsRunning)
        { throw "EventSentry Management Console is running, only read-only actions can be performed." }

	$variableCount = Get-ItemPropertyValue $ESRegPathGroups -Name "variables"
	
	# Check if variable already exists
	For ($i = 0; $i -lt $variableCount; $i++)
	{
		$regName = "var_" + $i + "_name"
		$variableName = Get-ItemPropertyValue $ESRegPathGroups -Name $regName
		
		If ($variableName -eq $Name)
			{ throw "Variable $Name already exists" }
	}
	
	$regName = "var_" + $variableCount + "_name"
	New-ItemProperty -Path $ESRegPathGroups -Name $regName -Value $Name.ToUpper() -PropertyType String -Force | Out-Null
	try {
		New-ItemProperty -Path $ESRegPathGroupsX64 -Name $regName -Value $Name.ToUpper() -PropertyType String -Force | Out-Null
	} catch {}
					
	$regName = "var_" + $variableCount + "_value"
	New-ItemProperty -Path $ESRegPathGroups -Name $regName -Value $DefaultValue -PropertyType String -Force | Out-Null
	try {
		New-ItemProperty -Path $ESRegPathGroupsX64 -Name $regName -Value $DefaultValue -PropertyType String -Force | Out-Null
	} catch {}
	
	++$variableCount
	
	Set-ItemProperty -Path $ESRegPathGroups -Name "variables" -Value $variableCount -Force | Out-Null
	try {
		Set-ItemProperty -Path $ESRegPathGroupsX64 -Name "variables" -Value $variableCount -Force | Out-Null
	} catch {}
	
	saveConfig
}

function Set-ESVariable
{
	Param(
        [Parameter(Mandatory=$true)]
		[ValidateLength(1,196)]
		[ValidatePattern("^[a-zA-Z0-9]+$")]
        [string]$variableName,
        [Parameter(Mandatory=$true)]
		[ValidateLength(1,512)]
        [string]$variableValue,
        [Parameter(Mandatory=$true)]
        [string]$Group
    )
	
    If (ManagementConsoleIsRunning)
        { throw "EventSentry Management Console is running, only read-only actions can be performed." }

	$groupExists = Test-ESGroup $Group
	If ($groupExists -eq $false)
		{ throw "The specified group $Group does not exist" }
		
	# Get variable ID
	$variableID = -1
	$variableCount = Get-ItemPropertyValue $ESRegPathGroups -Name "variables"
	
	# Check if variable exists
	For ($i = 0; $i -lt $variableCount; $i++)
	{
		$regName = "var_" + $i + "_name"
		$regValue = Get-ItemPropertyValue $ESRegPathGroups -Name $regName
		
		If ($regValue -eq $variableName)
		{
			$variableID = $i
			break
		}
	}
	
	if ($variableID -lt 0)
		{ throw "Variable $variableName does not exist and cannot be set" }

	# Setting a group variable
	If ($Hostname.Length -eq 0)
	{	
		$regPathGroup = $ESRegPathGroups + "\" + $Group
		$regPathGroupX64 = $ESRegPathGroupsX64 + "\" + $Group

		$regName = "var_" + $variableID + "_value"
	
		Set-ItemProperty -Path $regPathGroup -Name $regName -Value $variableValue -Force | Out-Null
		try {
			Set-ItemProperty -Path $regPathGroupX64 -Name $regName -Value $variableValue -Force | Out-Null
		} catch {}
	}
}

function Remove-ESHost
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Group,
        [Parameter(Mandatory=$true)]
        [string]$Hostname
    )

    $ErrorActionPreference = "Stop"
    
    if (ManagementConsoleIsRunning)
        { throw "EventSentry Management Console is running, only read-only actions can be performed." }
    
	$computerCount = Get-HostCount($Group)
	$hostID = GetHostID $Group $Hostname
    
    If ($hostID -eq "")
        { throw "Host $Hostname does not exist in group $Group" }

	$regPathGroup = $ESRegPathGroups + "\" + $Group
	$regPathGroupX64 = $ESRegPathGroupsX64 + "\" + $Group
	
	$regKey = (Get-ItemProperty $regPathGroup)
	
	# Remove all reg values for host that is being removed
	$regKey.PSObject.Properties | ForEach-Object {
		$regName = $_.Name
		
		$tokens = $regName.Split("_");
		If ($tokens.Count -ge 1)
		{
			[Int32]$numIndex = $null

			If ([Int32]::TryParse($tokens[0],[ref]$numIndex))
			{
				If ($numIndex -eq $hostID)
				{
					Remove-ItemProperty -Path $regPathGroup -Name $regName
					
					try {
						Remove-ItemProperty -Path $regPathGroupX64 -Name $regName
					} catch {}
				}
			}
		}
	}
	
	# Adjust all reg values of hosts with a higher ID
	$regKey.PSObject.Properties | ForEach-Object {
		$regName = $_.Name
		
		$tokens = $regName.Split("_");
		If ($tokens.Count -ge 1)
		{
			[Int32]$numIndex = $null

			If ([Int32]::TryParse($tokens[0],[ref]$numIndex))
			{
				If ($numIndex -gt $hostID)
				{
					$identifierNow = $numIndex.ToString()
					--$numIndex					
					$identifierNew = $numIndex.ToString()
					
					If ($regName.IndexOf("_") -ge 1)
					{
						$identifierNow = $identifierNow + "_"
						$identifierNew = $identifierNew + "_"
						
						$regNameUpdated = $regName.remove(0, $identifierNow.Length).insert(0, $identifierNew)
					}
					Else {
						$regNameUpdated = $identifierNew
					}
					
					Rename-ItemProperty -Path $regPathGroup -Name $regName -NewName $regNameUpdated
					
					try {
						Rename-ItemProperty -Path $regPathGroupX64 -Name $regName -NewName $regNameUpdated
					} catch {}
				}
			}
		}
    }
	
	--$computerCount
	writeRegistryValueAllPlatforms $regPathGroup "total" $computerCount DWORD
	writeRegistryValueAllPlatforms $regPathGroupX64 "total" $computerCount DWORD
	
	saveConfig
}

function Add-ESHost
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Group,
        [Parameter(Mandatory=$true)]
        [string]$Hostname,
        [Parameter(Mandatory=$false)]
        [string]$IP
    )

    $ErrorActionPreference = "Stop"
    
    if (ManagementConsoleIsRunning)
        { throw "EventSentry Management Console is running, only read-only actions can be performed." }
        
    if (Check-Host $Group $Hostname $IP -eq 1)
        { throw "Host $Hostname already exists in group $Group" }

    $regPath = $ESRegPathGroups + $Group
    $regPathX64 = $ESRegPathGroupsX64 + $Group
	
    $computerCount = Get-HostCount($Group)
    
    $regName = $computerCount
    
    New-ItemProperty -Path $regPath -Name $regName -Value $Hostname -PropertyType String -Force | Out-Null
	New-ItemProperty -Path $regPathX64 -Name $regName -Value $Hostname -PropertyType String -Force | Out-Null
    
	If ($IP.length -gt 0)
	{
		$regName_ip = $regName.ToString() + "_ip"
		
		writeRegistryValueAllPlatforms $regPath $regName_ip $IP String
	}
	
    $computerCount = $computerCount -as [int]
    $computerCount++
    
	writeRegistryValueAllPlatforms $regPath "total" $computerCount DWORD
		
	saveConfig
}

function Add-ESMaintenance
{
	Param(
        [Parameter(Mandatory=$true)]
        [string]$Group,
        [Parameter(Mandatory=$true)]
        [string]$Hostname,
        [Parameter(Mandatory=$true)]
        [int]$timeframe,
        [Parameter(Mandatory=$true)]
        [string]$scaleMC
    )
	
    if (ManagementConsoleIsRunning)
        { throw "EventSentry Management Console is running, only read-only actions can be performed." }
    
	$hostExists = Check-Host $Group $Hostname    
    if ($hostExists -eq 0)
        { throw "Host $Hostname does not exist in group $Group" }
		
    $hostID = GetHostID $Group $Hostname
	
	$scale = $scaleMC.ToLower()
	
	if ( ($scale -ne "s") -and ($scale -ne "sec") -and ($scale -ne "seconds") -and  
		 ($scale -ne "m") -and ($scale -ne "min") -and ($scale -ne "minutes") -and 
		 ($scale -ne "h") -and ($scale -ne "hr") -and ($scale -ne "hour") -and ($scale -ne "hours") -and
		 ($scale -ne "d") -and ($scale -ne "day") -and ($scale -ne "days") )
	{
		throw "Invalid time scale provided, $scale is not supported. Try sec, min, hour or day"
	}
	
	$timeStart = Get-Date
	
	if ( ($scale -eq "s") -or ($scale -eq "sec") -or ($scale -eq "seconds") )
	{
		$timeEnd = $timeStart.AddSeconds($timeframe)
	}
	elseif ( ($scale -eq "m") -or ($scale -eq "min") -or ($scale -eq "minutes") )
	{
		$timeEnd = $timeStart.AddMinutes($timeframe)
	}
	elseif ( ($scale -eq "h") -or ($scale -eq "hr") -or ($scale -eq "hour") -or ($scale -eq "hours") )
	{
		$timeEnd = $timeStart.AddHours($timeframe)
	}
	elseif ( ($scale -eq "d") -or ($scale -eq "day") -or ($scale -eq "days") )
	{
		$timeEnd = $timeStart.AddDays($timeframe)
	}
	
	$regPath = $ESRegPathGroups + $Group
	$regNameMaintSchedules = $hostID + "_maint_schedules"
	
	try
	{
		$maintScheduleCount = Get-ItemPropertyValue $regPath -Name $regNameMaintSchedules -ErrorAction SilentlyContinue
	}
	catch
	{
		$maintScheduleCount = 0
	}
	
	$arrayTimeStart = FileTimeToLowAndHigh($timeStart.ToFiletimeUtc())
	$arrayTimeEnd   = FileTimeToLowAndHigh($timeEnd.ToFiletimeUtc())

	$regValueLow  = $arrayTimeStart[0].ToString() + ":" + $arrayTimeEnd[0].ToString()
	$regValueHigh = $arrayTimeStart[1].ToString() + ":" + $arrayTimeEnd[1].ToString()
	
	$regNameHigh = $hostID + "_maint_schedule_" + $maintScheduleCount + "_fixed_high"
	$regNameLow  = $hostID + "_maint_schedule_" + $maintScheduleCount + "_fixed_low"
	
	$regMaintType = $hostID + "_maint_schedule_" + $maintScheduleCount + "_type"
	$regMaintUtc  = $hostID + "_maint_schedule_" + $maintScheduleCount + "_isutc"
	
	$maintScheduleCount++
	writeRegistryValueAllPlatforms $regPath $regNameMaintSchedules $maintScheduleCount DWORD
	
	writeRegistryValueAllPlatforms $regPath $regMaintType 0 DWORD
	writeRegistryValueAllPlatforms $regPath $regMaintUtc 1 DWORD
	
	writeRegistryValueAllPlatforms $regPath $regNameHigh $regValueHigh String
	writeRegistryValueAllPlatforms $regPath $regNameLow $regValueLow String
	
	Write-Host "Maintenance Schedule" $maintScheduleCount "added successfully (" $timeStart "to" $timeEnd ")"
	
	saveConfig
}

# Defined in manifest
#Export-ModuleMember -Function 'Add-ESHost'
#Export-ModuleMember -Function 'Remove-ESHost'
#Export-ModuleMember -Function 'Get-ESHosts'

#Export-ModuleMember -Function 'Add-ESGroup'
#Export-ModuleMember -Function 'Test-ESGroup'
#Export-ModuleMember -Function 'Set-ESGroupProperty'

#Export-ModuleMember -Function 'Add-ESMaintenance'

#Export-ModuleMember -Function 'Set-ESAuthPasswordWindows'

#Export-ModuleMember -Function 'Add-ESVariable'
#Export-ModuleMember -Function 'Set-ESVariable'