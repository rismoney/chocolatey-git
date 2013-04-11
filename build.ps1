mkdir C:\packages
$gitrepo="C:\gitrepos\chocopackages"
$tags = @()
$tags=git for-each-ref --format="%(refname)" |Select-string -Pattern "^refs/tags"
$total=$tags.count
$i=0
$tag=''
foreach ($tag in $tags) {
  [string]$cleantag=$tag
  #$cleantag
  $cleantag = $cleantag.Substring($cleantag.LastIndexOf("/") + 1)
  write-output "$cleantag"
  git checkout $tag
  # handle preleases
  if (($cleantag.substring($cleantag.LastIndexOf("-"))).contains("-alpha")) {
    $packagename = $foo.substring(0,$foo.LastIndexOf("-",$foo.LastIndexOf("-")-1))
  }
  else {
    $packagename = $cleantag.substring(0,$cleantag.LastIndexOf("-"))
  }

  $packagepath=join-path $gitrepo $packagename
  set-location $packagepath
  
  & nuget pack "$packagename.nuspec" -NoPackageAnalysis -OutputDirectory C:\packages
  set-location $gitrepo
  $i++
  write-output "processed package $package $i of $total"
}
git checkout master