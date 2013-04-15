function Validate-Posh ($path, [switch]$verbose) {

  if ($verbose) {
    $VerbosePreference = ‘Continue’
  } 

  trap { Write-Warning $_; $false; continue }
  & `
  {
    $contents = get-content $path
    $contents = [string]::Join([Environment]::NewLine, $contents)
    [void]$ExecutionContext.InvokeCommand.NewScriptBlock($contents)
    Write-Verbose "Parsed without errors"
    $true
  } 
}