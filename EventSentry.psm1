New-Variable -Name 'ESRegPath' -Value 'HKLM:\Software\netikus.net\EventSentry\' -Option ReadOnly

New-Variable -Name 'ESRegPathGroups' -Value 'HKLM:\Software\netikus.net\EventSentry\Filtergroups\' -Option ReadOnly

New-Variable -Name 'ESRegPathAuthenticationHKLM' -Value 'HKLM:\SOFTWARE\netikus.net\EventSentry\Authentication\' -Option ReadOnly
New-Variable -Name 'ESRegPathAuthenticationHKCU' -Value 'HKCU:\SOFTWARE\netikus.net\EventSentry\Authentication\' -Option ReadOnly

New-Variable -Name 'ESRegPathTrigger' -Value 'HKLM:\Software\netikus.net\EventSentry\Notify\' -Option ReadOnly
New-Variable -Name 'ESRegPathCollectorDeployConfig' -Value 'HKLM:\Software\netikus.net\EventSentry\Collector\' -Option ReadOnly

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

function saveConfig
{
	TriggerIncrease
}

function writeRegistryValueAllPlatforms($regPath, $regName, $regValue, $regType)
{
	New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType $retType -Force | Out-Null
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

function Save-ESConfig
{
	saveConfig
	
	$trigger = Get-ItemPropertyValue $ESRegPathTrigger -Name "trigger"
	
	Write-Host "Config Revision: $trigger"
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
		$regPathPassword = $ESRegPathAuthenticationHKCU + $authID
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
	
	saveConfig
}

function Remove-ESGroup
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Group
    )
    $ErrorActionPreference = "Stop"
    
    If (ManagementConsoleIsRunning)
        { throw "EventSentry Management Console is running, only read-only actions can be performed." }
        
	$groupExists = Test-ESGroup $Group
	If ($groupExists -eq $false)
		{ throw "The specified group $Group does not exist" }
		
	$regPathGroup = $ESRegPathGroups + "\" + $Group
	
	Remove-Item -Path $regPathGroup -Force
	
	saveConfig
}

function Set-ESHostProperty
{
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Group,
        [Parameter(Mandatory=$true,Position=1)]
        [string]$Hostname,
        [Parameter(Mandatory=$false)]
        [bool]$EnableAgent = $false,
        [Parameter(Mandatory=$false)]
        [bool]$EnablePing = $true,
        [Parameter(Mandatory=$false)]
        [Int32]$PacketCount=4,
        [Parameter(Mandatory=$false)]
        [Int32]$PacketSize=32,
        [Parameter(Mandatory=$false)]
        [Int32]$SuccessPercentage=50,
        [Parameter(Mandatory=$false)]
        [Int32]$RoundTrip=500,
        [Parameter(Mandatory=$false)]
        [string]$TcpPorts,
        [Parameter(Mandatory=$false)]
        [bool]$RequirePing = $true,
        [Parameter(Mandatory=$false)]
        [Int32]$RequiredErrorCount = $true,
        [Parameter(Mandatory=$false)]
        [bool]$RepeatFailed = $true,
        [Parameter(Mandatory=$false)]
        [bool]$CollectPingStats = $true,
        [Parameter(Mandatory=$false)]
        [String]$Notes,
        [Parameter(Mandatory=$false)]
        [String]$IPAddress
    )
	
	$boolToText = @{$true = '1'; $false = '0'}
	
    If (ManagementConsoleIsRunning)
        { throw "EventSentry Management Console is running, only read-only actions can be performed." }

	$groupExists = Test-ESGroup $Group
	If ($groupExists -eq $false)
		{ throw "The specified group $Group does not exist" }
		
	$hostID = GetHostID $Group $Hostname
    
    If ($hostID -eq "")
        { throw "Host $Hostname does not exist in group $Group" }

	$regPathGroup = $ESRegPathGroups + "\" + $Group

	# Always disable SNMP
	$regName = $hostID + "_snmp_error"
	Set-ItemProperty -Path $regPathGroup -Name $regName -Value 1 -Type DWORD -Force | Out-Null
	
	$regName = $hostID + "_hb_customize"
	Set-ItemProperty -Path $regPathGroup -Name $regName -Value 1 -Type DWORD -Force | Out-Null
	
	# Read reg value
	$regName = $hostID + "_hb_options"
	
	# Merge existing settings
	try
	{
		$hbSettings = Get-ItemPropertyValue $regPathGroup -Name $regName
		$hbTokens = $hbSettings.Split(":");
		If ($hbTokens.Count -eq 12)
		{
			If ($PSBoundParameters.ContainsKey('EnableAgent') -eq $false) {
				if ($hbTokens[0] -eq "1") { $EnableAgent = $true }
			}
			If ($PSBoundParameters.ContainsKey('EnablePing') -eq $false) {
				If ($hbTokens[1] -eq "0") { $EnablePing = $true }
			}
			
			If ($PSBoundParameters.ContainsKey('PacketCount') -eq $false) { $PacketCount = $hbTokens[2] }
			If ($PSBoundParameters.ContainsKey('PacketSize') -eq $false) { $PacketSize = $hbTokens[3] }
			If ($PSBoundParameters.ContainsKey('SuccessPercentage') -eq $false) { $SuccessPercentage = $hbTokens[4] }
			If ($PSBoundParameters.ContainsKey('RoundTrip') -eq $false) { $RoundTrip = $hbTokens[5] }
			If ($PSBoundParameters.ContainsKey('RequiredErrorCount') -eq $false) { $RequiredErrorCount = $hbTokens[9] }
			
			If ($PSBoundParameters.ContainsKey('RepeatFailed') -eq $false) {
				If ($hbTokens[10] -eq "0") { $RepeatFailed = $false }
			}
			
			If ($PSBoundParameters.ContainsKey('CollectPingStats') -eq $false) { $CollectPingStats = $hbTokens[11] }
		}
	}
	catch {}
		
	$regValue = $boolToText[($EnableAgent)] + ":" + $boolToText[($EnablePing)] + ":" + $PacketCount.ToString() + ":" + $PacketSize.ToString() + ":" + $SuccessPercentage.ToString() + ":" + $RoundTrip.ToString() + ":1:500:0:" + $RequiredErrorCount.ToString() + ":" + $boolToText[($RepeatFailed)] + ":" + $boolToText[($CollectPingStats)]
	Set-ItemProperty -Path $regPathGroup -Name $regName -Value $regValue -Type String -Force | Out-Null

	# TCP Port(s)
	If ($TcpPorts.Length -gt 0)
	{
		$tcpTokens = $TcpPorts.Split(":");
		
		For ($i = 0; $i -lt $tcpTokens.Count; $i++)
		{
			[Int32]$numPort = $null

			If ([Int32]::TryParse($tcpTokens[$i],[ref]$numPort))
			{
				$regName = $hostID + "_hb_ports"
				Set-ItemProperty -Path $regPathGroup -Name $regName -Value $TcpPorts -Type String -Force | Out-Null
			}
			Else {
				Write-Host "Invalid TCP ports specified, TCP ports will not be set"
			}
		}
	}
	
	# Notes
	If ($PSBoundParameters.ContainsKey('Notes'))
	{
		$regName = $hostID + "_notes"
		
		If ($Notes.Length -gt 0)
		{
			Set-ItemProperty -Path $regPathGroup -Name $regName -Value $Notes -Type String -Force | Out-Null
		}
		Else
		{
			Remove-ItemProperty -Path $regPathGroup -Name $regName -Force | Out-Null
		}
	}
	
	# IP Address
	If ($PSBoundParameters.ContainsKey('IPAddress'))
	{
		$regName = $hostID + "_ip"

		If ($IPAddress.Length -gt 0)
		{
			Set-ItemProperty -Path $regPathGroup -Name $regName -Value $IPAddress -Type String -Force | Out-Null
		}
		Else
		{
			Remove-ItemProperty -Path $regPathGroup -Name $regName -Force | Out-Null
		}
	}

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

	Set-ItemProperty -Path $regPathGroup -Name $regName -Value $regValue -Type DWORD -Force | Out-Null
	
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
					
	$regName = "var_" + $variableCount + "_value"
	New-ItemProperty -Path $ESRegPathGroups -Name $regName -Value $DefaultValue -PropertyType String -Force | Out-Null
	
	++$variableCount
	
	Set-ItemProperty -Path $ESRegPathGroups -Name "variables" -Value $variableCount -Force | Out-Null
	
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

		$regName = "var_" + $variableID + "_value"
	
		Set-ItemProperty -Path $regPathGroup -Name $regName -Value $variableValue -Force | Out-Null
	}
}

function Reset-ESSharedSecret
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Hostname
    )
    
    if (ManagementConsoleIsRunning)
        { throw "EventSentry Management Console is running, only read-only actions can be performed." }

	$regPathCollector = $ESRegPath + "\collector"
    
    Set-ItemProperty -Path $regPathCollector -Name "reset_shared_secrets_hosts" -Value $Hostname -Force | Out-Null
	
	saveConfig
}

function Remove-ESHost
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Group,
        [Parameter(Mandatory=$true)]
        [string]$Hostname,
		[Parameter(Mandatory=$false)]
		[bool]$SaveConfig = $true
    )

    $ErrorActionPreference = "Stop"
    
    if (ManagementConsoleIsRunning)
        { throw "EventSentry Management Console is running, only read-only actions can be performed." }
    
	$computerCount = Get-HostCount($Group)
	$hostID = GetHostID $Group $Hostname
    
    If ($hostID -eq "")
        { throw "Host $Hostname does not exist in group $Group" }

	$regPathGroup = $ESRegPathGroups + "\" + $Group
	
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
				}
			}
		}
    }
	
	--$computerCount
	writeRegistryValueAllPlatforms $regPathGroup "total" $computerCount DWORD
	
	if ($saveConfig -eq $true)
		{ saveConfig }
}

function Add-ESHost
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Group,
        [Parameter(Mandatory=$true)]
        [string]$Hostname,
        [Parameter(Mandatory=$false)]
        [string]$IP,
		[Parameter(Mandatory=$false)]
		[bool]$SaveConfig = $true
    )

    $ErrorActionPreference = "Stop"
    
    if (ManagementConsoleIsRunning)
        { throw "EventSentry Management Console is running, only read-only actions can be performed." }
        
    if (Check-Host $Group $Hostname $IP -eq 1)
        { throw "Host $Hostname already exists in group $Group" }

    $regPath = $ESRegPathGroups + $Group
	
    $computerCount = Get-HostCount($Group)
    
    $regName = $computerCount
    
    New-ItemProperty -Path $regPath -Name $regName -Value $Hostname -PropertyType String -Force | Out-Null
    
	If ($IP.length -gt 0)
	{
		$regName_ip = $regName.ToString() + "_ip"
		
		writeRegistryValueAllPlatforms $regPath $regName_ip $IP String
	}
	
    $computerCount = $computerCount -as [int]
    $computerCount++
    
	writeRegistryValueAllPlatforms $regPath "total" $computerCount DWORD

	if ($saveConfig -eq $true)
		{ saveConfig }
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
#Export-ModuleMember -Function 'Set-ESHostProperty'

#Export-ModuleMember -Function 'Add-ESGroup'
#Export-ModuleMember -Function 'Remove-ESGroup'
#Export-ModuleMember -Function 'Test-ESGroup'
#Export-ModuleMember -Function 'Set-ESGroupProperty'

#Export-ModuleMember -Function 'Save-ESConfig'

#Export-ModuleMember -Function 'Add-ESMaintenance'

#Export-ModuleMember -Function 'Set-ESAuthPasswordWindows'

#Export-ModuleMember -Function 'Add-ESVariable'
#Export-ModuleMember -Function 'Set-ESVariable'

# SIG # Begin signature block
# MIISGwYJKoZIhvcNAQcCoIISDDCCEggCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1+u/HwesyuOK9k6FJiTCi2Ls
# vP+ggg54MIIG6DCCBNCgAwIBAgIQd70OBbdZC7YdR2FTHj917TANBgkqhkiG9w0B
# AQsFADBTMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEp
# MCcGA1UEAxMgR2xvYmFsU2lnbiBDb2RlIFNpZ25pbmcgUm9vdCBSNDUwHhcNMjAw
# NzI4MDAwMDAwWhcNMzAwNzI4MDAwMDAwWjBcMQswCQYDVQQGEwJCRTEZMBcGA1UE
# ChMQR2xvYmFsU2lnbiBudi1zYTEyMDAGA1UEAxMpR2xvYmFsU2lnbiBHQ0MgUjQ1
# IEVWIENvZGVTaWduaW5nIENBIDIwMjAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDLIO+XHrkBMkOgW6mKI/0gXq44EovKLNT/QdgaVdQZU7f9oxfnejlc
# wPfOEaP5pe0B+rW6k++vk9z44rMZTIOwSkRQBHiEEGqk1paQjoH4fKsvtaNXM9JY
# e5QObQ+lkSYqs4NPcrGKe2SS0PC0VV+WCxHlmrUsshHPJRt9USuYH0mjX/gTnjW4
# AwLapBMvhUrvxC9wDsHUzDMS7L1AldMRyubNswWcyFPrUtd4TFEBkoLeE/MHjnS6
# hICf0qQVDuiv6/eJ9t9x8NG+p7JBMyB1zLHV7R0HGcTrJnfyq20Xk0mpt+bDkJzG
# uOzMyXuaXsXFJJNjb34Qi2HPmFWjJKKINvL5n76TLrIGnybADAFWEuGyip8OHtyY
# iy7P2uKJNKYfJqCornht7KGIFTzC6u632K1hpa9wNqJ5jtwNc8Dx5CyrlOxYBjk2
# SNY7WugiznQOryzxFdrRtJXorNVJbeWv3ZtrYyBdjn47skPYYjqU5c20mLM3GSQS
# cnOrBLAJ3IXm1CIE70AqHS5tx2nTbrcBbA3gl6cW5iaLiPcDRIZfYmdMtac3qFXc
# AzaMbs9tNibxDo+wPXHA4TKnguS2MgIyMHy1k8gh/TyI5mlj+O51yYvCq++6Ov3p
# Xr+2EfG+8D3KMj5ufd4PfpuVxBKH5xq4Tu4swd+hZegkg8kqwv25UwIDAQABo4IB
# rTCCAakwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBIGA1Ud
# EwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFCWd0PxZCYZjxezzsRM7VxwDkjYRMB8G
# A1UdIwQYMBaAFB8Av0aACvx4ObeltEPZVlC7zpY7MIGTBggrBgEFBQcBAQSBhjCB
# gzA5BggrBgEFBQcwAYYtaHR0cDovL29jc3AuZ2xvYmFsc2lnbi5jb20vY29kZXNp
# Z25pbmdyb290cjQ1MEYGCCsGAQUFBzAChjpodHRwOi8vc2VjdXJlLmdsb2JhbHNp
# Z24uY29tL2NhY2VydC9jb2Rlc2lnbmluZ3Jvb3RyNDUuY3J0MEEGA1UdHwQ6MDgw
# NqA0oDKGMGh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5jb20vY29kZXNpZ25pbmdyb290
# cjQ1LmNybDBVBgNVHSAETjBMMEEGCSsGAQQBoDIBAjA0MDIGCCsGAQUFBwIBFiZo
# dHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5LzAHBgVngQwBAzAN
# BgkqhkiG9w0BAQsFAAOCAgEAJXWgCck5urehOYkvGJ+r1usdS+iUfA0HaJscne9x
# thdqawJPsz+GRYfMZZtM41gGAiJm1WECxWOP1KLxtl4lC3eW6c1xQDOIKezu86Jt
# vE21PgZLyXMzyggULT1M6LC6daZ0LaRYOmwTSfilFQoUloWxamg0JUKvllb0EPok
# ffErcsEW4Wvr5qmYxz5a9NAYnf10l4Z3Rio9I30oc4qu7ysbmr9sU6cUnjyHccBe
# jsj70yqSM+pXTV4HXsrBGKyBLRoh+m7Pl2F733F6Ospj99UwRDcy/rtDhdy6/KbK
# Mxkrd23bywXwfl91LqK2vzWqNmPJzmTZvfy8LPNJVgDIEivGJ7s3r1fvxM8eKcT0
# 4i3OKmHPV+31CkDi9RjWHumQL8rTh1+TikgaER3lN4WfLmZiml6BTpWsVVdD3FOL
# JX48YQ+KC7r1P6bXjvcEVl4hu5/XanGAv5becgPY2CIr8ycWTzjoUUAMrpLvvj19
# 94DGTDZXhJWnhBVIMA5SJwiNjqK9IscZyabKDqh6NttqumFfESSVpOKOaO4ZqUmZ
# XtC0NL3W+UDHEJcxUjk1KRGHJNPE+6ljy3dI1fpi/CTgBHpO0ORu3s6eOFAm9CFx
# ZdcJJdTJBwB6uMfzd+jF1OJV0NMe9n9S4kmNuRFyDIhEJjNmAUTf5DMOId5iiUgH
# 2vUwggeIMIIFcKADAgECAgw/RuE7RRJ1uSmNYaEwDQYJKoZIhvcNAQELBQAwXDEL
# MAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExMjAwBgNVBAMT
# KUdsb2JhbFNpZ24gR0NDIFI0NSBFViBDb2RlU2lnbmluZyBDQSAyMDIwMB4XDTIz
# MDgyNDAxNDAyMFoXDTI2MDgyNDAxNDAyMFowge0xHTAbBgNVBA8MFFByaXZhdGUg
# T3JnYW5pemF0aW9uMREwDwYDVQQFEwg2MzY3Mzg0NjETMBEGCysGAQQBgjc8AgED
# EwJVUzEZMBcGCysGAQQBgjc8AgECEwhJbGxpbm9pczELMAkGA1UEBhMCVVMxETAP
# BgNVBAgTCElsbGlub2lzMRAwDgYDVQQHEwdDaGljYWdvMSEwHwYDVQQJExgxNTAg
# UyBXYWNrZXIgRHIgU3RlIDI0MDAxGTAXBgNVBAoTEE5FVElLVVMuTkVUIExURC4x
# GTAXBgNVBAMTEE5FVElLVVMuTkVUIExURC4wggIiMA0GCSqGSIb3DQEBAQUAA4IC
# DwAwggIKAoICAQDGZCrBLmd4la7HQ+HY81iKJ2Wj/aa69Xd/kk/Vyjcylcv6gPJT
# QXeHAg4S16gFj+7lOY0Ss9v4yZ3jxqdac8LgzEDxXEV0f27x9z/IpXAOsIjIxNok
# X9qENN9UK6SSOvR11+WqRVal4yviAcGXkXw6ks+vxb4rsimgL5Hh+UWuj5N2Y79y
# GUro/gogIhyLhCzLWJKweYELrhZyONcH8ERVGbm24gnXSTgGpK5EdiTSWISUu/LZ
# md4UWAt6xSezEfajitFo2BjgxcymxN5tO3gPXT1GZo0IFfrOVpY6Wyz9RZPMHLNO
# inzNPcOwoxIs8s57uNcNlZz5lBFbhVbiricis07GUgLEWViSQDi8qp0RAwYutKnu
# aDS4b6cWr6BK3o5I133U+f6aw7kzp8jjAl9eqyr97U4xkdcnw73KwOrBBFc1ZksX
# UtqSgczV7fUsCQgWpVbWJfDVttG9IuuQmIqy4U+ibo5U4fmYRVrJQXt6YA1nQNTW
# 381Ld15A+0HUldtq6/7KXfj1daxSVUOX81/26gR7ruajN64yOZlq+AWEThUgyowx
# rJtpeOI+Y0qGVpZQnSWuVo1Hnjg1GsM1T56Z06lozFZo1kpsau41ByF85IWFIlBI
# Fn7QWdmu2pwD3iDHvL1r8R50khwsRJvfuJgcY6y3SAem1GL/hYUrdKaZ8wIDAQAB
# o4IBtjCCAbIwDgYDVR0PAQH/BAQDAgeAMIGfBggrBgEFBQcBAQSBkjCBjzBMBggr
# BgEFBQcwAoZAaHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9jYWNlcnQvZ3Nn
# Y2NyNDVldmNvZGVzaWduY2EyMDIwLmNydDA/BggrBgEFBQcwAYYzaHR0cDovL29j
# c3AuZ2xvYmFsc2lnbi5jb20vZ3NnY2NyNDVldmNvZGVzaWduY2EyMDIwMFUGA1Ud
# IAROMEwwQQYJKwYBBAGgMgECMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmds
# b2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAcGBWeBDAEDMAkGA1UdEwQCMAAwRwYD
# VR0fBEAwPjA8oDqgOIY2aHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9nc2djY3I0
# NWV2Y29kZXNpZ25jYTIwMjAuY3JsMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB8GA1Ud
# IwQYMBaAFCWd0PxZCYZjxezzsRM7VxwDkjYRMB0GA1UdDgQWBBR8MU/cehTUeI1C
# GA/8L+micJm9jzANBgkqhkiG9w0BAQsFAAOCAgEAOGcU5qtNq0RRS21ENaJszDn6
# 9KHAdjbOrfhPk3/VAhP5oTIpSUEkliGVSf25hNLj8gG7iAbC3XDQSoS6RMEXfkj9
# Pm/3AIGao4Lv6HKbD492nfVnmnT361pNQDOdD7orSXt10RnR9F7rkIaEKh0d0mNp
# IhxduFXpvZH1POTn3XSBp7XaZtGIKjvP7dfokG3Q7xYs0UMHdXO0IfFYdkYKlt2/
# lGg5JBgrrJ3xUG78FrfO16FFnm1ueFjBxkJvuE0efIsnD69FXtaWZiFIebWpWnHE
# THP6QTivmpBEkPQaHiPp2/8t7Zo1lIJxHVDOVoN5BKK5cEYssSKWGKucNxQPg88I
# L94Rk4mBZZ3NJG7WSNkxbEkDdBznF4Sluu6apqyVG14vqxXOSIFT+WaDOKlZiiJT
# xFswFTAQkoAjAIXgt8H7Ju0ApIlcZmh9by5/M794ADbvu0fTMpzDU6JtOXFlU7sV
# oNQ4C+NlxLM8tnh/XNbYBBMuvwXc0rYdkR4o0bzqRyCm/ZlSmOJuAS3XSfmeQaR6
# paTRrt/Radj1CCm5OYo+ghwvFncUiLe/hywDnksJ0QAdCM68/vq0t0xfRCovWiV5
# 88VskgzN5PgtKhOhSxc138290UeGTmlO8j9Yvx2FzmNz3R0oZiqsWmdvMaGiGsui
# opYmQo2X4N6vg3lYxRYxggMNMIIDCQIBATBsMFwxCzAJBgNVBAYTAkJFMRkwFwYD
# VQQKExBHbG9iYWxTaWduIG52LXNhMTIwMAYDVQQDEylHbG9iYWxTaWduIEdDQyBS
# NDUgRVYgQ29kZVNpZ25pbmcgQ0EgMjAyMAIMP0bhO0USdbkpjWGhMAkGBSsOAwIa
# BQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3
# DQEJBDEWBBTYzO9BOr+N6ZdWZm7n3q/u/zNIlzANBgkqhkiG9w0BAQEFAASCAgAT
# dnn0ausJLgLQolGXuXktuIIva+ZSRdKAgThkFC64uqbiTpg8KOzGPZaYqAbBaUNm
# bW3PdCYBfvsSEB9sxQxqNyifb/S1+CzpsUiLT58GeIeR1sdWO8l85ScTmde8VQ40
# sVVGxALKd6aomzA6qFTJ/DPg9yL9FHIGKQuNh8afIO2x0BLnRLFq6bztX0s/c8y8
# ns+83WVQfjM6Qx88aG4Xs/crPKxbh3GhSZmIROdrzAmgQ/FqVUpD7tkgIs/XRbIm
# wd2lC4nd+hd+IR7nWTH5wiWLoQSXUURCL7rliaJuLbd0ccSVpS5DFINm2QsRgo58
# 1Y/BNCmUkWqsbw2yOX1SjskA+VY+eShJntJDHgyRLq5cauCRXyehPG0ytYVRBZ5d
# hR75v9SG53Pp52Q7PLMm1uWCosQFe1M77tEibN7CQNuL6Bc/01xtpRMwHniTrODO
# 3Q+J9sBKssLr/RebFs++4isKQc2jOqA1N8MTmE/KbEqKHblOLRH3vp6uoBwONn1b
# ZKkRkAcPLk4+4KCY49O6Tiht5ywDEEakh3t5wsgRFxbk4IAkvTn16ND7l3vt+ySN
# v0HcGLMUMDyWfIfyFNhMKq0CiNhn1W8+4pwk1KyyzpMNuhglAb5taX1Igq90e/uQ
# t+cFSLmgBVhUeExrGWqmJ5s+LJseJPbN1k0joE4Zqg==
# SIG # End signature block
