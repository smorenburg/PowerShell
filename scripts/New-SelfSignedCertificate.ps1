<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER Name

.PARAMETER Password

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
    [string]$Name,

    [Parameter(
        Mandatory = $true
    )]
    [int]$YearsValid,

    [Parameter(
        Mandatory = $true
    )]
    [securestring]$Password
)

$currentDate = Get-Date 
$notAfter = $currentDate.AddYears($YearsValid)
$store = "cert:\CurrentUser\My"
$thumbprint = $(New-SelfSignedCertificate -DnsName $name -CertStoreLocation $store -KeyExportPolicy Exportable -NotAfter $notAfter).Thumbprint
$cerFilePath = ".\$($name).cer"
$pfxFilePath = ".\$($name).pfx"

Export-Certificate -Cert "$($store)\$($thumbprint)" -FilePath $cerFilePath
Export-PfxCertificate -Cert "$($store)\$($thumbprint)" -FilePath $pfxFilePath -Password $Password
Get-ChildItem -Path "$($store)\$($thumbprint)" | Remove-Item