---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Remove-ESHost

## SYNOPSIS
{{ Removes a host }}

## SYNTAX

```
Remove-ESHost [-Group] <String> [-Hostname] <String> [-SaveConfig <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
{{ Removes a host }}

## EXAMPLES

### Example 1
```
PS C:\> {{ Remove-ESHost "Default Group" SERVER17 }}
```

{{ Removes host SERVER17 from Default Group }}

## PARAMETERS

### -Group
{{ Name of the group the host is a member of }}

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
{{ Name of the host to remove }}

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
{{ Set to $false to prevent the config to be saved automatically, useful when adding many hosts in sequence }}

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
