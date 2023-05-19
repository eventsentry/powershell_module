# powershell_module
EventSentry PowerShell Module

A small number of EventSentry tasks can be automated with the EventSentry PowerShell module that can be downloaded below. The module is under development and new versions with additional functionality will be posted here. Suggestions for new functionality are welcome.

# Prerequisites
* Requires EventSentry build v4.2.3.56 or later
* All listed commands must be performed on the host where EventSentry was installed.
* The EventSentry Management Console may not be running commands that change the configuration are executed.
* PowerShell must be launched as Administrator

If you get an error message about the module not being loaded, execute:

`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

The EventSentry PowerShell module should automatically, if it does not then execute:

`Import-Module EventSentry`

# Installation
Download the zip file (from green "Code" button, then click Download Zip) and extract all files into an **EventSentry** sub folder, in one of the supported modules directories. You can find out which module directories are in PowerShell's search path with the following command:

`$ENV:PSModulePath`

For example:
```
C:\Program Files\WindowsPowerShell\Modules\EventSentry
C:\Program Files\PowerShell\7\Modules\EventSentry
C:\Users\[Username]\Documents\WindowsPowerShell\Modules\EventSentry\
```

No other steps are necessary to install the EventSentry PowerShell module.

# Usage
In most cases the module should be automatically loaded as soon as any of the included functions are called. To utilize the module, execute any of its funtions, e.g.

`Get-ESHosts "Default Group"`
