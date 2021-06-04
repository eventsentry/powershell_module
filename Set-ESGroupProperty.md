---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Set-ESGroupProperty

## SYNOPSIS
{{ Customizes heartbeat monitoring settings for a given group }}

## SYNTAX

```
Set-ESGroupProperty [-Group] <String> [-PropertyType] <String> [-PropertyValue] <String> [<CommonParameters>]
```

## DESCRIPTION
{{ Customizes heartbeat monitoring settings for a given group }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Set-ESGroupProperty "Network Devices" RequiredErrorCount 3 }}
```

{{ Sets the option "Require X failed accounts before error" to 3 }}

## PARAMETERS

### -Group
{{ Name of the group }}

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

### -PropertyType
{{ Name of the property to update, supported options are: RepeatFailed, CollectPingStats, RequiredErrorCount, PacketCount, PacketSize, RoundTrip, SuccessPercentage }}

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

### -PropertyValue
{{ The value of the property to be set, for boolean values use "yes", "no", "true" or "false" }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
