$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Validate-Schema.ps1"
. "$here\Validate-Posh.ps1"
. "$here\Validate-Url.ps1"

$choco_repo = "chocolatey.myco.com"

$posh_list=@()
$nuspec_list=@()
$choco=@()

$changed_files=git diff --diff-filter=ACMRTUXB --name-only origin/master
write-output "changed files:"
write-output $changed_files
foreach ($file in $changed_files) {

  $ext= [System.IO.Path]::GetExtension($file)
  $dirname = [System.IO.Path]::GetDirectoryName($file)
  $filepath= Get-ChildItem $file


  if ($ext -eq ".ps1") { $posh_list += $filepath}
  if ($ext -eq ".nuspec") { $nuspec_list += $filepath}

  if ($dirname -match '\\' -and $dirname.length -gt 0) {
    $dirpos=$dirname.indexof('\')
    $parentdir = $dirname.substring(0,$dirpos)
    [array]$choco=$choco + $parentdir
  }
}
[string]$choco = $choco | Select-Object -uniq

try {
  $chocopkg = Get-Item $choco -ea silentlycontinue
}
catch {
  exit 0
}
$tools_folders = Get-Item "$choco\tools"
$chocoinstall= $tools_folders | ForEach-Object {Join-Path $_.Fullname 'chocolateyInstall.ps1'}
$chocouninstall= $tools_folders | ForEach-Object {Join-Path $_.Fullname 'chocolateyUnInstall.ps1'}


Describe "Chocopackages should have valid XML" {

  foreach ($file in $nuspec_list) {
    $str_filename=$file.fullname

    It "$str_filename should be a valid nuspec file" {
      $valid_nuspec = Validate-Schema $str_filename
      $valid_nuspec | Should Be $true
    }
  }
}

Describe "Chocopackages should have valid Powershell" {

  foreach ($file in $posh_list) {
    $str_filename=$file.fullname

    It "$str_filename should be a valid powershell file" {
      $valid_posh = Validate-Posh $str_filename
      $valid_posh | Should Be $true
    }
  }
}

Describe "Chocopackages should contain the minimal ps1 files" {

  foreach ($file in $chocoinstall) {
    $pkgname=(get-item "$file\..").parent.name
    It "$pkgname should contain chocolateyInstall.ps1" {
        $install_filetest = test-path $file -ErrorAction SilentlyContinue
        $install_filetest | Should Be $true
    }
  }
}

# only run this test if the repo is available
if (Test-Connection -Computername $choco_repo -Quiet -Count 1) {
  Describe "Chocopackages should contain valid url" -Tags 'url' {
    foreach ($file in $chocoinstall) {
      $pkgname=(get-item "$file\..").parent.name
      $array = @()
      $urlsplit = @()
      $array += Get-Content $file
      $array | foreach-object {
        if ($_ -match "\b(?:(?:https?|ftp|file)://|www\.|ftp\.)(?:\([-A-Z0-9+&@#/%=~_|$?!:,. ]*\)|[-A-Z0-9+&@#/%=~_|$?!:,. ])*(?:\([-A-Z0-9+&@#/%=~_|$?!:,.]*\)|[A-Z0-9+&@#/%=~_|$ ])") {
          $rawurl = $matches[0]
          if ($rawurl.contains('$')) {
           write-output "cannot interpolate urls with variables"
          }
          else {
            It "$pkgname contains url $rawurl and should be reachable" {
              $valid_url = Validate-Url $rawurl
              $valid_url | Should Be $true
            }
          }
        }
      }
    }
  }
}

Describe "chocolateyinstall.ps1 should not have trailing spaces" -Tags 'whitespace' {
  foreach ($file in $chocoinstall) {
    
    $pkgname=(get-item "$file\..").parent.name
    $array = @()
    $array += Get-Content $file

    $linenumber = 0
    $array | foreach-object {
      $whitespace=$false
      $linenumber +=1
      if ($_ -match "[ \t\v]+$") {
        $whitespace = $true
        It "$pkgname $file $linenumber should not have trailing whitespace" {
          $whitespace | Should Be $false
        }
      }
    }
  }
}
