<#
.Synopsis
    Analyze the quality of your code.
.DESCRIPTION
    Analyze-Script.ps1 utilizes PSScriptAnalyzer. PSScriptAnalyzer is a static code checker
    for Windows PowerShell modules and scripts. PSScriptAnalyzer checks the quality of Windows
    PowerShell code by running a set of rules. The rules are based on PowerShell best practices
    identified by PowerShell Team and the community. It generates DiagnosticResults
    (errors and warnings) to inform users about potential code defects and suggests possible
    solutions for improvements.

    Reference:
    https://github.com/PowerShell/PSScriptAnalyzer
.FUNCTIONALITY
    We consider ALL errors and MOST warnings violations. Warnings that we do not consider
    violations are stored in the variable #DoNotFailOnRules. All violations must be
    remediated.

    PSSCriptAnalyzer Rule Documentation:
    https://github.com/PowerShell/PSScriptAnalyzer/tree/development/RuleDocumentation
#>
[CmdletBinding()]
Param()

$ErrorActionPreference = 'Stop'

$changedFiles = git diff --name-only --diff-filter=ACMRTUXB origin/master..HEAD | Where-Object { $_ -like "*.ps1" }

$DoNotFailOnRules = @(
    'PSAvoidGlobalVars',
    'PSUseDeclaredVarsMoreThanAssignments',
    'PSUseApprovedVerbs'
)

$exceptionfiles = @(
'office365-visio/tools/functions.ps1',
'office365-x64-visio/tools/functions.ps1',
'office365-x64/tools/functions.ps1',
'office365/tools/functions.ps1'
)

$WarningRules = Get-ScriptAnalyzerRule -Severity Warning
$FailOnRules = $WarningRules | Where-Object { -not ($DoNotFailOnRules -contains $_.RuleName) }


$Results = ForEach ($file in $changedFiles) {
  if ($exceptionfiles -notcontains $file) {
    Invoke-ScriptAnalyzer -Path $File -Recurse -ErrorAction SilentlyContinue
  }
}
$Violations = $Results | Where-Object {($FailOnRules.RuleName -contains $_.RuleName) -or ($_.Severity -eq 'Error')}

If ($Violations) {
  $ViolationString = $Violations | Out-String
  #Write-Warning $ViolationString
  $violations | Format-Table -wrap
  # Failing the build
  Throw "Build failed"
  exit 1
}
Else {
  write-output "passed"
}