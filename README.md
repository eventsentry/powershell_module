# powershell_module
EventSentry PowerShell Module

A small number of EventSentry tasks can be automated with the EventSentry PowerShell module that can be downloaded below. The module is under development and new versions with additional functionality will be posted here. Suggestions for new functionality are welcome.

# Prerequisites
* Requires EventSentry build v4.2.3.56 or later
* All listed commands must be performed on the host where EventSentry was installed.
* The EventSentry Management Console may not be running commands that change the configuration are executed.
* PowerShell must be launched as Administrator

If you get an error message about the module not being loaded, execute:

`set-executionpolicy remotesigned`

The EventSentry PowerShell module should automatically, if it does not then execute:

`Import-Module EventSentry`
