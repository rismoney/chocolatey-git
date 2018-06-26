$target = "D:\tools\chocolatey.server\App_Data\Packages"
$choco = "choco"
$gitrepo="D:\gitrepos\chocopackages"
$tags = @()
$tags=git for-each-ref --sort=taggerdate --format="%(refname)" |Select-string -Pattern "^refs/tags"
$total=$tags.count
$i=0
$tag=''
foreach ($tag in $tags) {
  [string]$cleantag=$tag
  #$cleantag
  $cleantag = $cleantag.Substring($cleantag.LastIndexOf("/") + 1)
  write-output "$cleantag"
  git checkout -f $tag
  # handle preleases
  if (($cleantag.substring($cleantag.LastIndexOf("-"))).contains("-alpha")) {
    $packagename = $foo.substring(0,$foo.LastIndexOf("-",$foo.LastIndexOf("-")-1))
  }
  else {
    $packagename = $cleantag.substring(0,$cleantag.LastIndexOf("-"))
  }
  
  $packagepath=join-path $gitrepo $packagename
  write-output "packagepath: $packagepath"
  set-location $packagepath
  
  write-output "packagename: $packagename.nuspec"  
  $Arguments = "pack .\$packagename.nuspec --outputdirectory $target"
  start-process choco $arguments -NoNewWindow -Wait
  set-location $gitrepo
  $i++
  write-output "processed package $package $i of $total"
}
git checkout -f master 