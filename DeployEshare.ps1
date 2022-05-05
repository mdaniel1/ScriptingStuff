#Requires -RunAsAdministrator

#Dossier du fichier à installer
$ExeFolder = "$env:USERPROFILE\Downloads" #POUR TEST


#Chemin vers dossier temporaire sur le poste
$TemporaryFolder = "$env:TEMP"

#Ce programme s'installe toujours à cet endroit
$ExeInstallDestination = "${env:ProgramFiles(x86)}\Eshare\Eshare.exe"

#Nom de l'exécutable
$ExeName = "EShareClient.exe"

#Arguments
$Args = "/S"

#Il faut créer la source une seule fois afin de pouvoir créer des entrées dans les logs Windows => Check pour voir si elle existe
if ([System.Diagnostics.EventLog]::SourceExists("DeployEshareClient") -eq $False) {
    New-EventLog -Source "DeployEshareClient" -LogName Application
}
 
#Check si Eshare a déjà été installé
if((Test-Path "$ExeInstallDestination") -eq $False){
    if(Test-Path "$ExeFolder\$ExeName"){
        #On copie l'exécutable dans le dossier temporaire "TEMP" (%temp%)
        New-Item -ItemType Directory -Path "$TemporaryFolder" -Name "EshareClient" -ErrorAction SilentlyContinue -Verbose
        Copy-Item -Path "$ExeFolder\$ExeName" -Destination "$TemporaryFolder" -Force -Verbose

        #Check si le fichier s'est correctement copié
        if(Test-Path "$TemporaryFolder\$ExeName"){
            #Installation du programme en mode silencieux
            Start-Process -Wait -FilePath "$TemporaryFolder\$ExeName" -ArgumentList "$Args"
        }

        #Supprimer l'exe du dossier temporaire après l'installation
        Remove-Item "$TemporaryFolder\$ExeName" -Verbose

        Write-EventLog -LogName Application -Source "DeployEshareClient" -EntryType SuccessAudit -Message "EshareClient a été installé avec succès" -EventId 22223

    }
    else{
        Write-EventLog -LogName Application -Source "DeployEshareClient" -EntryType Error -Message "Fichier d'installation introuvable dans $ExeFolder\" -EventId 22222
    }
}
else{
    Write-EventLog -LogName Application -Source "DeployEshareClient" -EntryType Information -Message "EshareClient est déjà installé, il n'y a rien à faire" -EventId 22221
}
