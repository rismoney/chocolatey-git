$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Validate-Schema.ps1"
. "$here\Validate-Posh.ps1"
. "$here\Validate-Url.ps1"

  $dir = gci . -recurse
  $nuspec_list=$dir | where {$_.extension -eq ".nuspec"} |select fullname
  $posh_list=$dir | where {$_.extension -eq ".ps1"} |select fullname
  $tools_Folders = gci -Filter "tools" -Recurse -Force



Describe "Chocopackages should have valid XML" {
  
  foreach ($file in $nuspec_list) {
    $str_filename=$file.fullname

    It "$str_filename should be a valid nuspec file" {
      $valid_nuspec = Validate-Schema $str_filename
      $valid_nuspec.should.be('True')
    }
  }
}

 Describe "Chocopackages should have valid Powershell" {
  
  foreach ($file in $posh_list) {
    $str_filename=$file.fullname

    It "$str_filename should be a valid powershell file" {
      $valid_nuspec = Validate-Posh $str_filename
      $valid_nuspec.should.be('True')
    }
  }
  
  $chocoinstall= $tools_folders | % {Join-Path $_.Fullname 'chocolateyInstall.ps1'}
  $chocouninstall= $tools_folders | % {Join-Path $_.Fullname 'chocolateyUnInstall.ps1'}
  foreach ($file in $chocoinstall) {
    $pkgname=(get-item "$file\..").parent.name
    It "$pkgname should contain chocolateyInstall.ps1" {
        $install_filetest = test-path $file -ErrorAction SilentlyContinue
        $install_filetest.should.be($true)
    }
  }
  foreach ($file in $chocouninstall) {
    $pkgname=(get-item "$file\..").parent.name
    It "$pkgname should contain chocolateyUnInstall.ps1" {
        $uninstall_filetest = test-path $file -ErrorAction SilentlyContinue
        $uninstall_filetest.should.be($true)
    }
  }

  foreach ($file in $chocoinstall) {
    $pkgname=(get-item "$file\..").parent.name
    $array = @()
    $urlsplit = @()
    $array += gc $file
    $array | foreach-object {
      if ($_ -match "\b(?:(?:https?|ftp|file)://|www\.|ftp\.)(?:\([-A-Z0-9+&@#/%=~_|$?!:,. ]*\)|[-A-Z0-9+&@#/%=~_|$?!:,. ])*(?:\([-A-Z0-9+&@#/%=~_|$?!:,.]*\)|[A-Z0-9+&@#/%=~_|$ ])") {
        $rawurl = $matches[0]
        if ($rawurl.contains('$')) {
         write-output "cannot interpolate urls with variables"
        }
        else {
          It "$pkgname contains url $url and should be reachable" {
            $valid_url = Validate-Url $rawurl
            $valid_url.should.be('True')
          }
        }
      }
    }
  }
}