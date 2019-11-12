# ADUserModifier
Powershell script aimed at making basic domain user actions easier
```powershell
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
```
