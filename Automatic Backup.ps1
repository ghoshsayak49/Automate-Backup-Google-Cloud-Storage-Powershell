### Session
$otherScriptInstances=get-wmiobject win32_process | where{$_.processname -eq 'powershell.exe' -and $_.ProcessId -ne $pid -and $_.commandline -match $("Automatic Backup.ps1")}
if ($otherScriptInstances -ne $null)
{
   Exit
}
$Session="New Session started at $(Get-Date)"
Add-content "synclog.txt" -value $Session
### User Setup
$backupdir = Read-Host -Prompt 'Enter you Backup Directory'
$buk = Read-Host -Prompt 'Enter You Google Cloud Bucket Name'
$num = $env:computername
$syn = Read-Host -Prompt 'Do You Want To Perform? 1.Sync 2.Backup '
$ini1 = Read-Host -Prompt 'Backup to Cloud? 1.Yes 2.No [Always select yes at the start of a session as best practice]' 
### Initial Upload
if($ini1 -eq 1)
{
                gsutil rsync -r "$backupdir" gs://"$buk/$num" 
                $status="$(Get-Date): Initial Upload To Cloud - Done!" 
                Add-content "synclog.txt" -value $status
}
$ini = Read-Host -Prompt 'Recover from Cloud? 1.Yes 2.No [Select yes if you have deleted any file in you local directory]' 
### Parsing Variable to Sync
$env:backupdir=$backupdir
$env:buk=$buk
$env:num=$num
### Initial Download 
if($ini -eq 1)
{
                gsutil rsync -r gs://"$buk/$num" "$backupdir"
                $status="$(Get-Date): Initial Download From Cloud - Done!" 
                Add-content "synclog.txt" -value $status
}

###Syncing Start

Write-Host "`n `n Real-Time Sync/backup Started." -ForegroundColor Green
Write-Host "`n #WARNING: Do Not Close This Script. Sync/Backup will Stop" -ForegroundColor Red
$status6="$(Get-Date): Real-Time Sync/backup Started from $num : $backupdir To Google Cloud Storage Bucket: $buk" 
Add-content "synclog.txt" -value $status6

if($syn -eq 1) 
{
### SET FOLDER TO WATCH + FILES TO WATCH + SUBFOLDERS YES/NO
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = "$backupdir"
    $watcher.Filter = "*.*"
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true  

### DEFINE ACTIONS AFTER AN EVENT IS DETECTED
    $action = {
	            $path = $Event.SourceEventArgs.FullPath
                $changeType = $Event.SourceEventArgs.ChangeType
                $logline = "$(Get-Date): $path was $changeType"
                Add-content "synclog.txt" -value $logline
	            $status="$(Get-Date): Syncing" 
                Add-content "synclog.txt" -value $status
				./scriptbi.bat
			    $status2="$(Get-Date): Sync With Google Cloud - DONE!" 
                Add-content "synclog.txt" -value $status2
              }    
### DECIDE WHICH EVENTS SHOULD BE WATCHED 
    Register-ObjectEvent $watcher "Created" -Action $action
    Register-ObjectEvent $watcher "Changed" -Action $action
    Register-ObjectEvent $watcher "Deleted" -Action $action
    Register-ObjectEvent $watcher "Renamed" -Action $action
    while ($true) {sleep 5}
}
else
{
### SET FOLDER TO WATCH + FILES TO WATCH + SUBFOLDERS YES/NO
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = "$backupdir"
    $watcher.Filter = "*.*"
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true  

### DEFINE ACTIONS AFTER AN EVENT IS DETECTED
    $action = {
	            $path = $Event.SourceEventArgs.FullPath
                $changeType = $Event.SourceEventArgs.ChangeType
                $logline = "$(Get-Date): $path was $changeType"
                Add-content "synclog.txt" -value $logline
	            $status="$(Get-Date): Syncing" 
                Add-content "synclog.txt" -value $status
				./scriptnorm.bat
			    $status2="$(Get-Date): Sync With Google Cloud - DONE!" 
                Add-content "synclog.txt" -value $status2
              }    
### DECIDE WHICH EVENTS SHOULD BE WATCHED 
    Register-ObjectEvent $watcher "Created" -Action $action
    Register-ObjectEvent $watcher "Changed" -Action $action
    Register-ObjectEvent $watcher "Deleted" -Action $action
    Register-ObjectEvent $watcher "Renamed" -Action $action
    while ($true) {sleep 5}
}
