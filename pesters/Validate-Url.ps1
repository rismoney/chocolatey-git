function Validate-Url([string] $url) {
 
$isValid = $false

# Create a request object to "ping" the URL
$request = [System.Net.WebRequest]::Create($url);
$request.Method = "HEAD"
$request.set_Timeout(4000)
$Request.UseDefaultCredentials = $true 
$Request.Proxy.Credentials = $Request.Credentials
     
# Capture the response from the "ping"
$response = $request.GetResponse()
$httpStatus = $response.StatusCode

# Check the status code to see if the URL is valid
$isValid = ($httpStatus -eq "OK")

$response.Close()
$httpStatus=$null

return $isValid
}
