# Validate Schema
#
# Description
# -----------
# Validates an XML file against its inline provided schema reference
#
# Command line arguments
# ----------------------
# xmlFileName: Filename of the XML file to validate

# this file was converted to a posh function from a top down script
# by Rich Siegel on 11/27/2012   It was found on the interwebs
# and is not supported by anyone at this time to my knowledge.
# this should probably be cleaned up and possibly published.

function Validate-Schema($xmlFileName) {

# Check if the provided file exists
if((Test-Path -Path $xmlFileName) -eq $false)
{
    Write-Host "XML validation not possible since no XML file found at '$xmlFileName'"
    exit 2
}

# Get the file
$XmlFile = Get-Item($xmlFileName)

# Keep count of how many errors there are in the XML file
$errorCount = 0

# Perform the XSD Validation
$readerSettings = New-Object -TypeName System.Xml.XmlReaderSettings
$readerSettings.ValidationType = [System.Xml.ValidationType]::Schema
$readerSettings.ValidationFlags = [System.Xml.Schema.XmlSchemaValidationFlags]::ProcessInlineSchema -bor [System.Xml.Schema.XmlSchemaValidationFlags]::ProcessSchemaLocation
$readerSettings.add_ValidationEventHandler(
{
    # Triggered each time an error is found in the XML file
    Write-Host $("`nError found in XML: " + $_.Message + "`n") -ForegroundColor Red
    $errorCount++
});
$reader = [System.Xml.XmlReader]::Create($XmlFile.FullName, $readerSettings)
while ($reader.Read()) { }
$reader.Close()

# Verify the results of the XSD validation
if($errorCount -gt 0)
{
    # XML is NOT valid
    return $false
}
else
{
    # XML is valid
    return $true
}
}