Get-ADComputer -Filter {CN -like '*KEYWORD*'} -Properties * | select Description, CN | Export-Csv -path "C:\Destination\Path" -NoTypeInformation -Encoding Unicode
