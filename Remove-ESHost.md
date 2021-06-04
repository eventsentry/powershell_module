---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Remove-ESHost

## SYNOPSIS
{{ Removes a host from a group }}

## SYNTAX

```
Remove-ESHost [-Group] <String> [-Hostname] <String> [<CommonParameters>]
```

## DESCRIPTION
{{ Removes a host from a group }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Remove-ESHost "Default Group" SERVER17 }}
```

{{ Removes host SERVER17 from Default Group }}

## PARAMETERS

### -Group
{{ Name of the group from which the host should be removed from }}

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
{{ Host to remove }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
