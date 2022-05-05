Get-AdGroupMember -identity "DistributionListName" -Recursive | 
Get-ADUser -Properties Mail,TelephoneNumber | 
select Name, Mail, TelephoneNumber | 
Export-Csv -path .\users.csv -NoTypeInformation -Encoding Unicode
