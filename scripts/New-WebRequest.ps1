<#
.SYNOPSIS

.DESCRIPTION

.LINK
    https://www.smorenburg.io

.NOTES
    Author: Robin Smorenburg
#>

$uri = ""

$json = @(
    [ordered]@{ 
        Key01 = "Value01";
        Key02 = "Value02"
    },
    [ordered]@{
        Key01 = "Value01";
        Key02 = "Value02"
    }
)

$body = ConvertTo-Json -InputObject $json
$header = @{ message = "Started by Smorenburg" }

Invoke-WebRequest -Method Post -Uri $uri -Body $body -Headers $header