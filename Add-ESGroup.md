---
external help file: EventSentry-help.xml
Module Name: EventSentry
online version:
schema: 2.0.0
---

# Add-ESGroup

## SYNOPSIS
Adds a new EventSentry group.

## SYNTAX

```
Add-ESGroup [-Group] <String> [<CommonParameters>]
```

## DESCRIPTION
The Add-ESGroup cmdlet creates a new EventSentry group in the local EventSentry configuration.

The cmdlet cannot run while the EventSentry Management Console is open. It also checks whether the specified group already exists and throws an error if a duplicate group name is provided.

After the group is created, the EventSentry configuration is saved automatically.

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-ESGroup -Group Workstations
```

Creates an EventSentry group named Workstations.

## PARAMETERS

### -Group
Specifies the name of the EventSentry group to create.

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
