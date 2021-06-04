---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Set-ESAuthPasswordWindows

## SYNOPSIS
{{ Updates the Windows password for the specified credentials }}

## SYNTAX

```
Set-ESAuthPasswordWindows [-AuthName] <String> [-AuthPassword] <String> [<CommonParameters>]
```

## DESCRIPTION
{{ Updates the windows password for the specified credentials }}

## EXAMPLES

### Example 1
```
PS C:\> {{ Set-ESAuthPasswordWindows "AuthLab5" "NewPassword" }}
```

{{ Sets the Windows password for the authentication credentials "AuthLab5" to "NewPassword" }}

## PARAMETERS

### -AuthName
{{ Name of the account "Account Name" in the EventSentry authentication manager }}

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

### -AuthPassword
{{ The new password for the specified account }}

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
