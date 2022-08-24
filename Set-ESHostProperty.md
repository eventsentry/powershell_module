---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Set-ESHostProperty

## SYNOPSIS
{{ Sets notes or custom heartbeat properties for a host }}

## SYNTAX

```
Set-ESHostProperty [-Group] <String> [-Hostname] <String> [-EnableAgent <Boolean>] [-EnablePing <Boolean>]
 [-PacketCount <Int32>] [-PacketSize <Int32>] [-SuccessPercentage <Int32>] [-RoundTrip <Int32>]
 [-TcpPorts <String>] [-RequirePing <Boolean>] [-RequiredErrorCount <Int32>] [-RepeatFailed <Boolean>]
 [-CollectPingStats <Boolean>] [-Notes <String>] [-IPAddress <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Sets notes or custom heartbeat properties for a host }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Set-ESHostProperty "Network Devices" FIREWALL -EnableAgent 0 -PacketCount 8 -TcpPorts 80:443 }}
```

{{ Sets the following custom heartbeat properties for host FIREWALL in group "Network Devices": Agent check is disabled, ICMP packet count is set to 8 and TCP ports 80 and 443 are monitored. }}

## PARAMETERS

### -CollectPingStats
{{ Collect ping response times in database }}

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

### -EnableAgent
{{ Enable EventSentry agent check }}

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

### -EnablePing
{{ Enable ICMP ping check }}

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

### -Group
{{ Name of the group host is a member of }}

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
{{ Name of the host for which properties should be set }}

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

### -IPAddress
{{ Sets the IP address for a host. Specify empty value to remove IP address. }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Notes
{{ Sets the notes for the host. Specify empty value to remove notes. }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PacketCount
{{ Number of packets to send when performing a ping check on the host }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PacketSize
{{ ICMP packet size when performing a ping check on the host }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepeatFailed
{{ Toggle option to retry a failed host check before the next monitoring interval }}

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

### -RequirePing
{{ Sets whether a successful PING check is required for TCP and/or EventSentry agent checks }}

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

### -RequiredErrorCount
{{ Number of errors that are required before a host check is considered failed }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RoundTrip
{{ Max allowed ping roundtrip time in ms }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SuccessPercentage
{{ Percentage of ICMP packets that need to be replied to in order to consider the check successful }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TcpPorts
{{ TCP ports to check, multiple ports can be separated with colon (:) }}

```yaml
Type: String
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
