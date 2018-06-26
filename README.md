chocolatey-git
==============


This repository is a collect of chocolatey tools to be used with git.

build.ps1 can take a properly tagged git repository and create nupkg files
in a D:\tools\chocolatey.server\app_data\packages folder.
This could be very useful for rebuilding a chocolatey.org, nugetgallery, myget
or other similar repository and have every package version.

chocopackages.Tests.ps1 - a set of pester tests to validatate packages

Invoke-Analyzer.ps1 - validate/lint powershell


