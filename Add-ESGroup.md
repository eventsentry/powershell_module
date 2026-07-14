---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Add-ESGroup

## SYNOPSIS
{{ Adds a group }}

## SYNTAX

```
Add-ESGroup [-Group] <String> [-GroupType <ESGroupType>] [-SaveConfig <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
{{ Adds a group }}

## EXAMPLES

### Example 1
```
PS C:\> {{ Add-ESGroup Switches }}
```

{{ Creates the Switches group with the default group type Full }}

### Example 2
```
PS C:\> {{ Add-ESGroup Switches -GroupType HeartbeatOnly }}
```

{{ Creates the Switches group as a heartbeat-only group }}

## PARAMETERS

### -Group
{{ EventSentry Group }}

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

### -GroupType
{{ Type of the group, one of Full, HeartbeatOnly or ManageOnly. Defaults to Full }}

```yaml
Type: ESGroupType
Parameter Sets: (All)
Aliases:
Accepted values: ManageOnly, Full, HeartbeatOnly

Required: False
Position: Named
Default value: Full
Accept pipeline input: False
Accept wildcard characters: False
```

### -SaveConfig
{{ Set to $false to prevent the config to be saved automatically, useful when adding many groups in sequence }}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
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

[Import-ESHosts](Import-ESHosts.md)