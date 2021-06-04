---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Set-ESVariable

## SYNOPSIS
{{ Sets the value of a variable for the specified group }}

## SYNTAX

```
Set-ESVariable [-variableName] <String> [-variableValue] <String> [-Group] <String> [<CommonParameters>]
```

## DESCRIPTION
{{ Sets the value of a variable for the specified group }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Set-ESVariable EMAILRECIPIENT admin.john@yourcompany.com "Network Devices" }}
```

{{ Set the value of the variable EMAILRECIPIENT to admin.john@yourcompany.com for all hosts in the "Network Devices" group }}

## PARAMETERS

### -Group
{{ Name of the group in which the variable will be set }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -variableName
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

### -variableValue
{{ Value of the variable }}

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
