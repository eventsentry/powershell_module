---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Reset-ESSharedSecret

## SYNOPSIS
{{ Resets the shared secret of one or more hosts with the collector }}

## SYNTAX

```
Reset-ESSharedSecret [-Hostname] <String> [<CommonParameters>]
```

## DESCRIPTION
{{ Resets the shared secret of one or more hosts with the collector, for example when reinstalling the OS or the remote agent }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Reset-ESSharedSecret SRV-LOC1-0017 }}
```

{{ Resets the shared secret of SRV-LOC1-0017 }}

## PARAMETERS

### -Hostname
{{ Hostname to reset the shared secret for. Multiple hostnames can be separated with a colon }}

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
