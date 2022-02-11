import-module activedirectory

$OUs =
    "ou=Wokingham,ou=Users,ou=Herrington & Carmichael,dc=hc,dc=local",
    "ou=Camberley,ou=Users,ou=Herrington & Carmichael,dc=hc,dc=local"

Foreach ($ou in $OUs)
{
    $users = Get-ADUser -Filter * -SearchBase $ou -Properties homephone, telephonenumber
    
    Foreach ($user in $users)
    {
        $tel = $user.telephonenumber
        $hometel = $user.homephone

        $user.telephonenumber = $hometel
        $user.homephone = $tel

        Set-ADUser -instance $user
    }
}
