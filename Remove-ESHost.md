---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Remove-ESHost

## SYNOPSIS
Removes a host from an EventSentry group.

## SYNTAX

```
Remove-ESHost [[-Group] <String>] [-Hostname] <String> [-SaveConfig <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
The Remove-ESHost cmdlet removes a host from an EventSentry group in the local EventSentry configuration.

The cmdlet cannot run while the EventSentry Management Console is open. If you do not specify a group, the cmdlet searches all EventSentry groups and removes the host from the first group where it is found.

After the host is removed, the remaining hosts in the group are renumbered and the group host count is updated. By default, the EventSentry configuration is saved after the host is removed. Use the SaveConfig parameter to defer saving when removing multiple hosts in sequence.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-ESHost -Group "Default Group" -Hostname SERVER17
```

Removes the host SERVER17 from the EventSentry group named Default Group.

### Example 2
```powershell
PS C:\> Remove-ESHost -Hostname SERVER17
```

Searches all EventSentry groups for SERVER17 and removes it from the first group where it is found.

### Example 3
```powershell
PS C:\> Remove-ESHost -Group Workstations -Hostname DESKTOP01 -SaveConfig $false
```

Removes DESKTOP01 from the Workstations group without immediately saving the EventSentry configuration.

## PARAMETERS

### -Group
Specifies the name of the EventSentry group that contains the host. If this parameter is omitted, all groups are searched and the host is removed from the first matching group.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hostname
Specifies the name of the host to remove.

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

### -SaveConfig
Specifies whether to save the EventSentry configuration after the host is removed. The default value is $true. Set this parameter to $false when removing multiple hosts and call Save-ESConfig after the batch is complete.

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
