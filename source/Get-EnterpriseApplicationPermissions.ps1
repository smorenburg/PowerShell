<#
.SYNOPSIS
    Collect the enterprise application permissions and export 
    the permissions to a comma-separated values file.

.DESCRIPTION
    This script collects the enterprise application dpermissions.

.PARAMETER AccountId

.PARAMETER Application

.PARAMETER Delegated

.PARAMETER OutputFile

.EXAMPLE
    Get-EnterpriseApplicationPermissions -AccountId <upn>
    Get-EnterpriseApplicationPermissions -AccountId <upn> -Application
    Get-EnterpriseApplicationPermissions -AccountId <upn> -Delegated -OutputFile <file>

.LINK
    https://www.smorenburg.io

.NOTES
    Author: Robin Smorenburg
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$AccountId,

    [Parameter()]
    [switch]$Application,

    [Parameter()]
    [switch]$Delegated,
    
    [Parameter()]
    [object]$OutputFile = ".\Enterprise Application Permissions $(Get-Date -Format yyyyMMdd-HHmm).csv"
)

# Create functions
function Get-ApplicationPermissions {
    $principals | 
    ForEach-Object {
        Get-AzureADServiceAppRoleAssignedTo `
            -ObjectID $_.ObjectId `
            -All:$true |
        Where-Object { $_.PrincipalType -eq 'ServicePrincipal' } | 
        ForEach-Object {
            $assignment = $_
            $client = $principals |
            Where-Object { $_.ObjectId -eq $assignment.PrincipalId }

            $resource = $principals |
            Where-Object { $_.ObjectId -eq $assignment.ResourceId }
            
            $role = $resource.AppRoles |
            Where-Object { $_.Id -eq $assignment.Id }
            
            $details = [ordered]@{
                'PermissionType'       = 'Application'
                'ClientObjectId'       = $assignment.PrincipalId
                'ClientDisplayName'    = $client.DisplayName
                'ApplicationID'        = $client.AppId
                'ResourceObjectId'     = $assignment.ResourceId
                'ResourceDisplayName'  = $resource.DisplayName
                'Permission'           = $role.Value
                'ConsentType'          = $null
                'PrincipalObjectId'    = $null
                'PrincipalDisplayName' = $null
                'PrincipalUserName'    = $null
            }

            [void]$output.Add(
                (
                    New-Object `
                        -TypeName PSObject `
                        -Property $details
                )
            )
        }
    }
}

function Get-DelegatedPermissions {
    Get-AzureADOAuth2PermissionGrant -All:$true | 
    ForEach-Object {
        $grant = $_
        $user = $empty
        $client = $principals |
        Where-Object { $_.ObjectId -eq $grant.ClientId }

        $resource = $principals |
        Where-Object { $_.ObjectId -eq $grant.ResourceId }

        if ($grant.PrincipalId) {
            $user = Get-AzureADUser `
                -ObjectId $grant.PrincipalId
        }

        if ($grant.Scope) {
            $grant.Scope.Split(' ') | 
            ForEach-Object {
                $scope = $_
                $details = [ordered]@{
                    'PermissionType'       = 'Delegated'
                    'ClientObjectId'       = $grant.ClientId
                    'ClientDisplayName'    = $client.DisplayName
                    'ApplicationID'        = $client.AppId
                    'ResourceObjectId'     = $grant.ResourceId
                    'ResourceDisplayName'  = $resource.DisplayName
                    'Permission'           = $scope
                    'ConsentType'          = $grant.ConsentType
                    'PrincipalObjectId'    = $grant.PrincipalId
                    'PrincipalDisplayName' = $user.DisplayName
                    'PrincipalUserName'    = $user.UserPrincipalName
                }

                [void]$output.Add(
                    (
                        New-Object `
                            -TypeName PSObject `
                            -Property $details
                    )
                )
            }
        }
    }
}

# Connect to Azure
Connect-AzureAD `
    -AccountId $AccountId

# Prepare variables
$empty = @()
$output = New-Object `
    -TypeName System.Collections.ArrayList

$principals = Get-AzureADServicePrincipal `
    -All:$true

# Parameter logic
if ($Application.IsPresent) {
    Get-ApplicationPermissions
}

if ($Delegated.IsPresent) {
    Get-DelegatedPermissions
}

if (!$Application.IsPresent -and !$Delegated.IsPresent) {
    Get-ApplicationPermissions
    Get-DelegatedPermissions
}

# Export output to CSV
$output | 
Export-Csv `
    -Path $OutputFile `
    -Delimiter ";" `
    -NoTypeInformation `
    -Encoding UTF8