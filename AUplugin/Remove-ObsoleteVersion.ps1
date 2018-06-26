[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
param()

function Remove-ObsoleteVersion {

 Param(
    [string]$Matcher,
    [string]$PackageName,
    [int32]$MaximumVersions,
    [string]$gitrepo = $env:au_gitrepo,
    [string]$SimpleServerPath = $env:au_SimpleServerPath
  )
  
  $tags = @()
  $filehash = ""
  $content = ""
  $matches = ""
  $lstree = ""
  
  $tags = git for-each-ref --sort=taggerdate --format="%(refname)" |Select-string -Pattern "^refs/tags/$($PackageName)"
  $tagObj = foreach ($tag in $tags) {
    [string]$cleantag = $tag
    $name = split-path $cleantag.Substring(0,$cleantag.LastIndexOf('-')) -leaf
     
    $splittag = $cleantag.split('-')
    
    [pscustomobject]@{
      name = $name
      ver=[System.Version]$splittag[-1]
      tag = $cleantag.Substring($cleantag.LastIndexOf("/") + 1)
    }
  }
  # we need the tags in system.version tag order not ascii
  $tagobj=$tagobj |Sort-Object ver
  
  if ($tagObj.count -gt $MaximumVersions) {
    $tagObj=$tagObj[0..($tagObj.Count-($MaximumVersions+1))]
    $total=$tags.count
    $i=0

    foreach ($item in $tagObj) {
      $content = $null
      # we stash to preserve non commited changes while we peruse historical commit tags/branches
      $matches = ''
      # git is case sensitive and we didn't historically enforce this
      $filevariations = @('ChocolateyInstall.ps1','Chocolateyinstall.ps1','chocolateyInstall.ps1','chocolateyinstall.ps1')
      foreach ($filevariation in $filevariations) {
        if (!($lstree)) {
     
          $lstree =  (git ls-tree $item.tag $packageName/tools/$filevariation)
        }
      }
      $filehash =  $lstree.split(" ")[2].split("`t")[0]
      $content = git show $filehash
      $packagefile = $content | ForEach-Object {$_ -match $matcher}
  
      if ($matches[1]) {
        try {
          remove-item "$($env:au_chocopackagepath)/$($PackageName)/$($matches[1])" -ErrorAction SilentlyContinue
          $nupkgfilename = "$($item.name).$($item.ver).nupkg"
          remove-item "$SimpleServerPath\$nupkgfilename" -ErrorAction SilentlyContinue
          set-location $gitrepo
          $i++
          git tag -d $item.tag
          git push upstream :$($item.tag)
          write-output "removed $($item.tag) from repository as we store $($MaximumVersions) versions"
        }
        catch {
          write-output "error removing items and tag deleting because $($matches[1]) empty"
        }
      }
      else {
        write-host "Error with regex for parsing package history"
      }
    }
  }
}