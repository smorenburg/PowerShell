<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER InputFile
    Comma-separated values input file.

.PARAMETER RemoveFromRecycleBin
    Remove user directly from the recycle bin.

.EXAMPLE
    Remove-MsolUsers -InputFile <file> -RemoveFromRecycleBin
    Remove-MsolUsers -InputFile <file>

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
    [switch]$RemoveFromRecycleBin
)

$lines = Import-Csv $InputFile -Delimiter ";"

Connect-MSolService

foreach ($line in $lines) {
    if ($RemoveFromRecycleBin.IsPresent) {
        Remove-MsolUser -UserPrincipalName $rule.UserPrincipalName -RemoveFromRecycleBin
    }
    else {
        Remove-MsolUser -UserPrincipalName $rule.UserPrincipalName
    }
}