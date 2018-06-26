chocolatey-git
==============

This repository is a collection of chocolatey tools to be used with git. It's purpose is to demonstrate
how to lint/validate choco packages in a pipeline and use git and chocolatey together in harmony.

## CI/CD Pipeline tools

`chocopackages.Tests.ps1` - a set of pester tests to validatate packages.  Simply place in root of choco repo, and run pester in pipeline
`Invoke-Analyzer.ps1` - validate/lint powershell

## Additional Tools
----------------

build.ps1 can take a properly tagged git repository and create nupkg files
in a directory.  This could be very useful for rebuilding a chocolatey.org, nugetgallery, myget
or other similar repository and maintain every package version.  Tagging method is mentioned below.

###Remove-ObsoleteVersion.ps1

If you maintain your own chocolatey feed, and you use [AU](https://github.com/majkinetor/au) this might be of interest.
You can specify a set number of packages you want to maintain online.  After all binaries can grow to be huge!
This requires a properly tagged repo.

Usage:

```
function global:au_AfterUpdate ($Package)  {

  $ROVArgs = @{
    maximumversions = 2
    packagename = 'office365-x64'
    matcher = '^\s*url\s*= ''https://chocopackages.3rdpoint.corp/office365-x64/(.*)'''
  }
  Remove-ObsoleteVersion @ROVArgs
}

````


### Additional information
----------------------

I tag all choco packages created in a chocopackages repository using the format `packagename-packageversion` using this command:
`git tag -a $tag -m `'tag`'`.   

Ex: git tag -a mypkg-1.0.0 -m 'mypkg-1.0.0'

This allows for some additional awesomeness if you use [AU](https://github.com/majkinetor/au) as mentioned above
