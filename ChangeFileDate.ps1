$path=$args[0]

Set-ItemProperty -Path "\path\to\file" -Name LastWriteTime -Value (Get-Date)
