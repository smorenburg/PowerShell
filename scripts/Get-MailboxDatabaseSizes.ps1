<#
.SYNOPSIS
    
.DESCRIPTION
    
.EXAMPLE
    
.LINK
    https://www.smorenburg.io
.NOTES
    Author: Robin Smorenburg
#>

$databases = @()

$outputFile = ".\Mailbox Database Sizes $(Get-Date -Format yyyyMMdd-HHmm).csv"
$pattern = [regex]::new("^([\d\.]+).*")
$output = New-Object -TypeName System.Collections.ArrayList

foreach ($database in $databases) {
    $database = Get-MailboxDatabase $database -Status
    $databaseSize = $database.DatabaseSize -Replace $pattern, "`$1"
    $availableNewMailboxSpace = $database.AvailableNewMailboxSpace -Replace $pattern, "`$1"

    $details = [ordered]@{
        "Name"                          = [string]$database.Name
        "DatabaseSize (GB)"             = [int]$databaseSize
        "AvailableNewMailboxSpace (GB)" = [int]$availableNewMailboxSpace
    }

    [void]$output.Add((New-Object -TypeName PSObject -Property $details))
}

$output | Export-Csv -Path $outputFile -Delimiter ";" -NoTypeInformation -Encoding UTF8