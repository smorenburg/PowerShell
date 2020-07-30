<#
.SYNOPSIS

.DESCRIPTION 

.LINK
    https://www.smorenburg.io

.NOTES
    Author: Robin Smorenburg
#>

$auditAdminProperties = "AddFolderPermissions, ApplyRecord, Copy, Create, FolderBind, HardDelete, ModifyFolderPermissions, Move, MoveToDeletedItems, RecordDelete, RemoveFolderPermissions, SendAs, SendOnBehalf, SoftDelete, Update, UpdateFolderPermissions, UpdateCalendarDelegation, UpdateInboxRules"
$auditDelegateProperties = "AddFolderPermissions, ApplyRecord, Create, FolderBind, HardDelete, ModifyFolderPermissions, Move, MoveToDeletedItems, RecordDelete, RemoveFolderPermissions, SendAs, SendOnBehalf, SoftDelete, Update, UpdateFolderPermissions, UpdateInboxRules"
$auditOwnerProperties = "AddFolderPermissions, ApplyRecord, Create, HardDelete, MailboxLogin, ModifyFolderPermissions, Move, MoveToDeletedItems, RecordDelete, RemoveFolderPermissions, SoftDelete, Update, UpdateFolderPermissions, UpdateCalendarDelegation, UpdateInboxRules"
$mailboxes = Get-Mailbox -ResultSize Unlimited -Filter { RecipientTypeDetails -eq "UserMailbox" -or RecipientTypeDetails -eq "SharedMailbox" -or RecipientTypeDetails -eq "RoomMailbox" -or RecipientTypeDetails -eq "DiscoveryMailbox" }

foreach ($mailbox in $mailboxes) {
    Set-Mailbox -Identity $mailbox.UserPrincipalName -AuditEnabled:$true -AuditLogAgeLimit 365:00:00:00 -AuditOwner $auditOwnerProperties -AuditDelegate $auditDelegateProperties -AuditAdmin $auditAdminProperties
}