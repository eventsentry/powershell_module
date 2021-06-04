---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Add-ESHost

## SYNOPSIS
{{ Adds host to a group }}

## SYNTAX

```
Add-ESHost [-Group] <String> [-Hostname] <String> [[-IP] <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Adds host to a group }}

## EXAMPLES

### Example 1
```
PS C:\> {{ Add-ESHost "Default Group" MAILSERVER01 }}
```

{{ Adds host MAILSERVER01 to group "Default Group" }}

## PARAMETERS

### -Group
{{ Name of the EventSentry group to add the host to }}

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
{{ Name of the host to add }}

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
{{ IP address of the specified host }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
