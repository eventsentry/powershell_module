---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Add-ESMaintenance

## SYNOPSIS
{{ Adds a maintenance schedule to a host }}

## SYNTAX

```
Add-ESMaintenance [-Group] <String> [-Hostname] <String> [-timeframe] <Int32> [-scaleMC] <String>
 [<CommonParameters>]
```

## DESCRIPTION
{{ Adds a maintenance schedule to a host }}

## EXAMPLES

### Example 1
```
PS C:\> {{ Add-ESMaintenance "Default Group" SERVER01 15 min }}
```

{{ Starts a 15 minute maintenance schedule for host SERVER01 in group "Default Group" }}

## PARAMETERS

### -Group
{{ Name of the EventSentry group of the host }}

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
{{ Name of the host to which to add the maintenance schedule }}

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

### -scaleMC
{{ Time scale, can be one of the following: sec min hour day }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -timeframe
{{ Length of the maintenance schedule in seconds, minutes, hours or days  }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
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
