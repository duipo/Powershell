<#
- Add Users to Group by OU
- Revision: 1.0

Searches an array with different OUs, and adds users to a group.
#>

Import-Module  a c t i v e d i r e c t o r y  
  
 #   O U   A r r a y   -   A d d   O U s   h e r e   i f   y o u   w a n t   t o   s c a n   m o r e   a r e a s   o f   A D  
$ous   =    @{
  " O U = C o m m e r c i a l , O U = M B   U s e r s , O U = M o o r e B l a t c h , D C = m o o r e b l a t c h , D C = l o c a l " , 
   " O U = P e r s o n a l   I n j u r y   &   R e g u l a t o r y , O U = M B   U s e r s , O U = M o o r e B l a t c h , D C = m o o r e b l a t c h , D C = l o c a l " , 
   " O U = P r i v a t e   C l i e n t , O U = M B   U s e r s , O U = M o o r e B l a t c h , D C = m o o r e b l a t c h , D C = l o c a l " , 
   " O U = S u p p o r t   F u n c t i o n s , O U = M B   U s e r s , O U = M o o r e B l a t c h , D C = m o o r e b l a t c h , D C = l o c a l " 
}

# Security Group (CN)
$groupName = "PaperCutMF"
$secGroup = "CN=PaperCutMF,OU=PaperCutMG,OU=Groups,OU=MooreBlatch,DC=mooreblatch,DC=local"

foreach($ou in $ous)
{
  $users = Get-ADUser -SearchBase $ou -Filter 'Enabled -eq $true' -Properties *
  foreach ($user in $users)
  {
    $userdn = $user.displayName
    if ((Get-ADUser $user -Properties memberof).memberof -like $secGroup)
    {
      Write-Host "$userdn is a member"
    }
    Else
    {
      Write-Host "adding $userdn to group"
      Add-ADGroupMember $groupName $user.distinguishedName
    }
  }
}
  
Exit
