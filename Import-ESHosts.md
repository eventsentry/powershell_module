---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Import-ESHosts

## SYNOPSIS
{{ Imports hosts from a CSV file }}

## SYNTAX

```
Import-ESHosts [-Path] <String> [-GroupType <ESGroupType>] [-Delimiter <String>] [-SaveConfig <Boolean>]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Imports hosts from a CSV file. The CSV file does not contain a header row and consists of the columns Groupname,Hostname,IP - the IP address is optional and ignored when it is not specified.

Groups that do not exist are created automatically, using the group type specified with -GroupType. Hosts that already exist in any group are skipped with a warning, the remaining rows are still processed.

The configuration is only saved once after all rows have been processed. }}

## EXAMPLES

### Example 1
```
PS C:\> {{ Import-ESHosts C:\Temp\hosts.csv }}
```

{{ Imports all hosts from C:\Temp\hosts.csv, e.g.

Default Group,MAILSERVER01,192.168.1.10
Default Group,MAILSERVER02
Web Servers,WEBSERVER01,192.168.1.20

Groups that are created during the import are created as Full groups }}

### Example 2
```
PS C:\> {{ Import-ESHosts -Path C:\Temp\switches.csv -GroupType HeartbeatOnly }}
```

{{ Imports all hosts from C:\Temp\switches.csv, any group that is created during the import is created as a heartbeat-only group }}

### Example 3
```
PS C:\> {{ Import-ESHosts -Path C:\Temp\hosts.csv -Delimiter ";" }}
```

{{ Imports all hosts from a semicolon-delimited file }}

## PARAMETERS

### -Path
{{ Path of the CSV file to import. The file must not contain a header row, the columns are Groupname, Hostname and IP (optional) }}

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
{{ Group type assigned to groups that are created during the import, one of Full, HeartbeatOnly or ManageOnly. Defaults to Full. Existing groups are not modified }}

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

### -Delimiter
{{ Character separating the columns in the CSV file, defaults to a comma }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: ,
Accept pipeline input: False
Accept wildcard characters: False
```

### -SaveConfig
{{ Set to $false to prevent the config to be saved automatically after the import completes }}

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

[Add-ESHost](Add-ESHost.md)

[Add-ESGroup](Add-ESGroup.md)

[Test-ESGroup](Test-ESGroup.md)