---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Add-ESHost

## SYNOPSIS
Adds a host to an EventSentry group.

## SYNTAX

```
Add-ESHost [-Group] <String> [-Hostname] <String> [[-IP] <String>] [-SaveConfig <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
The Add-ESHost cmdlet adds a host to an existing EventSentry group in the local EventSentry configuration.

The cmdlet cannot run while the EventSentry Management Console is open. It checks whether the host already exists in any EventSentry group and throws an error if the host is already present.

You can optionally store an IP address for the host. By default, the EventSentry configuration is saved after the host is added. Use the SaveConfig parameter to defer saving when adding multiple hosts in sequence.

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-ESHost -Group "Default Group" -Hostname MAILSERVER01
```

Adds the host MAILSERVER01 to the EventSentry group named Default Group.

### Example 2
```powershell
PS C:\> Add-ESHost -Group "Network Devices" -Hostname FIREWALL01 -IP 192.168.10.1
```

Adds the host FIREWALL01 to the Network Devices group and stores 192.168.10.1 as its IP address.

### Example 3
```powershell
PS C:\> Add-ESHost -Group Workstations -Hostname DESKTOP01 -SaveConfig $false
```

Adds DESKTOP01 to the Workstations group without immediately saving the EventSentry configuration.

## PARAMETERS

### -Group
Specifies the name of the EventSentry group to add the host to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hostname
Specifies the name of the host to add.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IP
Specifies an optional IP address to store for the host.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SaveConfig
Specifies whether to save the EventSentry configuration after the host is added. The default value is $true. Set this parameter to $false when adding multiple hosts and call Save-ESConfig after the batch is complete.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
