chocolatey-git
==============


this is a container for tooling around chocolatey and git. 

currently it is in experimental phase with build.ps1

build.ps1 can take a properly tagged git repository and create nupkg files
in a c:\packages folder.  This could be very useful for rebuilding a 
chocolatey.org, nugetgallery, myget or other similar repository and have
every package version.

some functionality is being explored:
* extend build.ps1 to cpush packages
* extend build.ps1 to take an pipeline input of packages
* create-package.ps1 package-version against any tag
* point chocolatey to a git repository as a source, and be able
to install a package. 
* tag new choco relates dynamically
* chocopackage testing suite using pester

