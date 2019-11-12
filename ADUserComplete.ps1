<#
.SYNOPSIS
  Name: ADUserComplete.ps1
  The purpose of this script is to help with creating and modifying AD accounts.
  
.DESCRIPTION
  This script can perform multiple different functions related to AD accounts
  1.Create new AD users in bulk from .csv 
    This script gets the users from ulist.csv (Format: Firstname,Lastname,Email) which needs to be in the same directory as the script.
    It will create the user in the current quarter folder in \Meat Grinders\ and set up basic settings for the user (Naming, default password, expiry date and group memberships).
    In case of duplicate names the script will throw a warning and skip the name.
  2.Create a single new AD user 
    This script asks the user for a firstname, a lastname and an email to create a new AD account.
    It will create the user in the current quarter folder in \Meat Grinders\ and set up basic settings for the user (Naming, default password, expiry date and group memberships).
    In case of duplicate names the script will throw a warning and skip the name.
  3.Reset AD user password 
    This script asks the user account name (firstname.lastname)
    It will then attempt to find the account and proceed to reset it's password to the default.
    User has to reset the password on next login.
  4.Enable an AD account
    This script asks the user account name (firstname.lastname)
    It will then attempt to find the account and proceed to enable it and set it to expire in 3 months from current date.
.NOTES
  Created: 16-5-2019
  Author: alexfour
.EXAMPLE
  Run the ADUserComplete script and enter the function you want to launch by inputting the respective number.
#>



Import-Module ActiveDirectory



#Setup dates
$CurrentDate = Get-Date -Format dd/MM/yyyy
$CurrentDate = $CurrentDate -replace '\.','/' 
$CurrentDate = $CurrentDate + " 18:00:00"
$ExpiryDate = Get-Date (Get-Date).AddMonths(3) -Format dd/MM/yyyy
$ExpiryDate = $ExpiryDate -replace '\.','/' 
$ExpiryDate = $ExpiryDate + " 18:00:00"

#Set Quarter
$CurrentMonth = [int](Get-Date -Format MM)
$CurrentYear= [int](Get-Date -Format yyyy)
$CurrentQuarter = 0

if ($CurrentMonth -ge 0 -And $CurrentMonth-le 3){    $CurrentQuarter = 1}
elseif ($CurrentMonth -ge 4 -And $CurrentMonth-le 6){    $CurrentQuarter = 2}
elseif ($CurrentMonth -ge 7 -And $CurrentMonth-le 9){    $CurrentQuarter = 3}
elseif ($CurrentMonth -ge 10 -And $CurrentMonth-le 12){    $CurrentQuarter = 4}

$Quarter = "$('Q')$CurrentQuarter$('/')$CurrentYear"

$Success = $false;

#Create users in bulk from ulist.csv
function Create-Bulk
{
    $UserList = Import-Csv -Path 'PATHTO.CSV'

    #Start looping trough the userinfo
    foreach ($User in $UserList) {

        #Confirmation
        Write-Output "$('Creating ')$($User.First).$($User.Last)$(' to ')$Quarter$('\PATH\TOUSERFOLDER')"

        #Search for the user in the AD
        $UserListFilter="$('*')$($User.First).$($User.Last)$('*')"
        $UserList = get-aduser -f {SamAccountName -like $UserListFilter} | format-list name
    
        if ($UserList.Count -gt 0) #If same accountname is found throw error
        {
            #If user does exist, output a warning message
            Write-Warning "$('A user account named ')$($User.First).$($User.Last)$(' already exists in Active Directory.')"
        }
        else #Else go ahead and create user
        {
            $Attributes = @{ #Set all the attributes for the new user

            Enabled = $true
            ChangePasswordAtLogon = $true
            Path = "$('OU=')$Quarter$(',OU=PATH,OU=TOUSERS,DC=YOURDOMAIN,DC=COM')"

            Name = "$($User.First) $($User.Last)"
            UserPrincipalName = "$($User.First).$($User.Last)"
            SamAccountName = "$($User.First).$($User.Last)"
            DisplayName = "$($User.First) $($User.Last)"
            Email = "$($User.Email)"

            GivenName = $User.First
            Surname = $User.Last

            AccountPassword = "PASSWORD" | ConvertTo-SecureString -AsPlainText -Force
            Description = "Created with ADUserComplete " + $CurrentDate # Set starting date

            }

            New-ADUser @Attributes #Create new user
    
            Set-ADAccountExpiration -Identity "$($User.First).$($User.Last)" -DateTime $ExpiryDate #Set expiry date
            Add-ADGroupMember -Identity S-1-5-21-784906344-1131387286-3893974291-2651 <# WG-AR #> -Members "$($User.First).$($User.Last)" #Set group memberships
            Add-ADGroupMember -Identity S-1-5-21-784906344-1131387286-3893974291-1111 <# DU #> -Members "$($User.First).$($User.Last)"
            Write-Output "OK"
            Write-Output " "
        }
    }
}

#Create single user
function Create-Single
{
    $Firstname = Read-Host -Prompt 'Input firstname'
    $Lastname = Read-Host -Prompt 'Input lastname'
    $Email = Read-Host -Prompt 'Input email (leave empty if none)'

    #Confirmation
    Write-Output "$('Creating ')$($Firstname).$($Lastname)$(' to ')$Quarter$('\PATH\TOUSERFOLDER')"

    #Search for the user in the AD
    $UserListFilter="$('*')$($Firstname).$($Lastname)$('*')"
    $UserList = get-aduser -f {SamAccountName -like $UserListFilter} | format-list name
    
    if ($UserList.Count -gt 0) #If same accountname is found throw error
    {
        #If user does exist, output a warning message
        Write-Warning "$('A user account named ')$($($Firstname).$($Lastname))$(' already exists in Active Directory.')"
    }
    else #Else go ahead and create user
    {
        $Attributes = @{ #Set all the attributes for the new user

        Enabled = $true
        ChangePasswordAtLogon = $true
        Path = "$('OU=')$Quarter$(',OU=PATH,OU=TOUSERS,DC=YOURDOMAIN,DC=COM')"

        Name = "$($Firstname) $($Lastname)"
        UserPrincipalName = "$($Firstname).$($Lastname)"
        SamAccountName = "$($Firstname).$($Lastname)"
        DisplayName = "$($Firstname) $($Lastname)"
        Email = "$($Email)"

        GivenName = $Firstname
        Surname = $Lastname

        AccountPassword = "PASSWORD" | ConvertTo-SecureString -AsPlainText -Force
        Description = "Created with ADUserComplete " + $CurrentDate # Set starting date

        }

        New-ADUser @Attributes #Create new user
    
        Set-ADAccountExpiration -Identity "$($Firstname).$($Lastname)" -DateTime $ExpiryDate #Set expiry date
        Add-ADGroupMember -Identity S-1-5-21-784906344-1131387286-3893974291-2651 <# WG-AR #> -Members "$($Firstname).$($Lastname)" #Set group memberships
        Add-ADGroupMember -Identity S-1-5-21-784906344-1131387286-3893974291-1111 <# DU #> -Members "$($Firstname).$($Lastname)"
        Write-Output "OK"
        Write-Output " "
    }
    $Firstname = $Lastname = $Email = ""
}

#Reset a users password
function Reset-Password
{
    $Firstname = Read-Host -Prompt 'Input firstname'
    $Lastname = Read-Host -Prompt 'Input lastname'

    #Confirmation
    Write-Output "$('Resetting password for ')$($Firstname).$($Lastname)"

    #Search for the user in the AD
    $UserListFilter="$('*')$($Firstname).$($Lastname)$('*')"
    $UserList = Get-ADUser -Filter{SamAccountName -like $UserListFilter}
    #Write-Output ($UserList | Measure-Object).Count Count of array

    if (($UserList | Measure-Object).Count -ge 2) #If more than one hit make user choose the account they want
    {
        Write-Output "Multiple matches choose user"
        for ($i=0; $i -lt ($UserList | Measure-Object).Count; $i++)
        {
            $paddedName = $($UserList[$i].Name).PadRight(20)
            $paddedSamName= $($UserList[$i].SamAccountName).PadRight(30)
            $paddedIndex= '['+$i+']'
            Write-Output $paddedName$paddedSamName$paddedIndex
        }
        $Selection = Read-Host -Prompt 'Selection'
        #Write-Output $UserList[$Selection]
        Set-ADAccountPassword -Identity $UserList[$Selection].SamAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "Qwerty123!" -Force)
        Set-ADUser -Identity $UserList[$Selection].SamAccountName -ChangePasswordAtLogon:$true
        $Success = $true;
    }
    elseif (($UserList | Measure-Object).Count -eq 0) #If user is not found write warning and stop
    {
        Write-Warning "$('A user account named ')$($($Firstname).$($Lastname))$(' was not found in Active Directory.')"
    }
    elseif (($UserList | Measure-Object).Count -eq 1) #If only one result then go ahead and reset password to default
    {
        if ($Firstname.length -le 0 -Or $Lastname.length -le 0)
        {
            Write-Warning "$('Please write both the first and lastname of the user and try again')"
        }
        else
        {
            Set-ADAccountPassword -Identity "$($Firstname).$($Lastname)" -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "Qwerty123!" -Force)
            Set-ADUser -Identity "$($Firstname).$($Lastname)" -ChangePasswordAtLogon:$true
            $Success = $true;
        }
    }

    if ($Success)
    {
        Write-Output "OK - Password reset to PASSWORD"
    }
    Write-Output " "
    $Firstname = $Lastname = ""
    $Success = $false;
}

#Enable account and set new expiry in 3 months
function Enable-Account
{
    $Firstname = Read-Host -Prompt 'Input firstname'
    $Lastname = Read-Host -Prompt 'Input lastname'

    #Confirmation
    Write-Output "$('Enabling account ')$($Firstname).$($Lastname)"

    #Search for the user in the AD
    $UserListFilter="$('*')$($Firstname).$($Lastname)$('*')"
    $UserList = Get-ADUser -Filter{SamAccountName -like $UserListFilter}
    #Write-Output ($UserList | Measure-Object).Count #Count of array

    if (($UserList | Measure-Object).Count -ge 2) #If more than one hit make user choose the account they want
    {
        Write-Output "Multiple matches choose user"
        for ($i=0; $i -lt ($UserList | Measure-Object).Count; $i++)
        {
            $paddedName = $($UserList[$i].Name).PadRight(20)
            $paddedSamName= $($UserList[$i].SamAccountName).PadRight(30)
            $paddedIndex= '['+$i+']'
            Write-Output $paddedName$paddedSamName$paddedIndex
        }
        $Selection = Read-Host -Prompt 'Selection'
        #Write-Output $UserList[$Selection]
        Enable-ADAccount -Identity $UserList[$Selection].SamAccountName
        Set-ADAccountExpiration -Identity $UserList[$Selection].SamAccountName -DateTime $ExpiryDate #Set expiry date
        $Success = $true;
    }
    elseif (($UserList | Measure-Object).Count -eq 0) #If user is not found write warning and stop
    {
        Write-Warning "$('A user account named ')$($($Firstname).$($Lastname))$(' was not found in Active Directory.')"
    }
    elseif (($UserList | Measure-Object).Count -eq 1) #If only one result then go ahead and reset password to default
    {
        if ($Firstname.length -le 0 -Or $Lastname.length -le 0)
        {
            Write-Warning "$('Please write both the first and lastname of the user and try again')"
        }
        else
        {
            Enable-ADAccount -Identity "$($Firstname).$($Lastname)"
            Set-ADAccountExpiration -Identity "$($Firstname).$($Lastname)" -DateTime $ExpiryDate #Set expiry date
            $Success = $true;
        }
    }

    if ($Success)
    {
        Write-Output "OK - Enabled account!"
    }
    Write-Output " "
    $Firstname = $Lastname = ""
    $Success = $false;
}

#Begin main loop
while ($true)
{
    Write-Output "=====   Make Selection   ====="
    Write-Output "Add users from .csv (Bulk) [1]"
    Write-Output "Add single user            [2]"
    Write-Output "Reset user password        [3]"
    Write-Output "Enable user account        [4]"
    Write-Output "Exit                       [5]"
    $Selection = Read-Host -Prompt '                 Selection'
    switch($Selection)
    {
        '1'{
            Create-Bulk
        }
        '2'{
            Create-Single
        }
        '3'{
            Reset-Password
        }
        '4'{
            Enable-Account
        }
        '5'{
            exit 0
        }
    }
}
