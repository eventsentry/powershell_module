---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Add-ESVariable

## SYNOPSIS
{{ Defines a new variable }}

## SYNTAX

```
Add-ESVariable [-Name] <String> [-DefaultValue] <String> [<CommonParameters>]
```

## DESCRIPTION
{{ Defines a new variable }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add-ESVariable EMAILRECIPIENT first.lastname@yourcompany.com }}
```

{{ Adds a new EMAILRECIPIENT variable with the default value of first.lastname@yourcompany.com }}

## PARAMETERS

### -DefaultValue
{{ Default value of the variable if not overwritten on a per-group or per-host basis }}

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

### -Name
{{ Name of the variable }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
