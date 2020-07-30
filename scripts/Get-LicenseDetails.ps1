<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER InputFile 

.PARAMETER OutputFile

.EXAMPLE

.LINK
    https://www.smorenburg.io

.NOTES
    Author: Robin Smorenburg
#>

[CmdletBinding()]
param(
    [Parameter(
        Mandatory = $true
    )]
    [object]$InputFile,
    [Parameter()]
    [object]$OutputFile = ".\License Details $(Get-Date -Format yyyyMMdd-HHmm).csv"
)

$rules = Import-Csv $InputFile -Delimiter ","
$output = New-Object System.Collections.ArrayList

Connect-MSolService

foreach ($rule in $rules) {
    $user = Get-MsolUser -UserPrincipalName $rule.UserPrincipalName
    if ($user.Licenses) {
        $user.Licenses.AccountSkuId | Where-Object { $_ } | ForEach-Object {
            $license = $_
            $details = [ordered]@{
                "UserPrincipalName" = [string]$rule.UserPrincipalName
                "Present"           = "TRUE"
                "License"           = [string]$license
            }
            [void]$output.Add((New-Object PSObject -Property $details))
        }     
    }
    else {
        $details = [ordered]@{
            "UserPrincipalName" = [string]$rule.UserPrincipalName
            "Present"           = "FALSE"
            "License"           = $null
        }
        [void]$output.Add((New-Object PSObject -Property $details))
    }
}

$output | Export-Csv -Path $OutputFile -Delimiter ";" -NoTypeInformation -Encoding UTF8
