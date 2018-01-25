<#
        .SYNOPSIS
        Veeam Restore Point and Count Script
  
        .DESCRIPTION
        This script gathers all restore points, along with the sizes. and output this information and pushes it into influxdb
	
        .Notes
        NAME:  veeam-restorepoints.ps1
        ORIGINAL NAME: veeam-restorepoints.ps1
        LASTEDIT: 25/01/2018
        VERSION: 0.1
        KEYWORDS: Veeam
   
        .Link
        https://helpcenter.veeam.com/docs/backup/powershell/getting_started.html
        https://docs.influxdata.com/influxdb/v1.4/write_protocols/line_protocol_tutorial/
 
 #Requires PS -Version 3.0
 #Requires -Modules VeeamPSSnapIn    
 #>

FunctionRestorePointStats{
    $out= @()
    ForEach($backupin$backups){
        $restorePoint=Get-VBRRestorePoint-Backup$backup
        $out=$restorePoint|SelectName,ApproxSize
    
    foreach($oin$out)
       {
       $na= ($o.name).replace(" ","\")
       $as=$o.approxsize
       $ct=$o.creationtime
       write-output"veeam-stats,name=$na approxsize=$as"
       }
  }
}

FunctionRestorePointCount{
    $out= @()
    Foreach($backupin$backups){
        $restorePoint=Get-VBRRestorePoint-Backup$backup
        $out+=$restorePoint|Group-Object-PropertyVmName|Select-Object-PropertyName, @{Name='RestorePoints';Expression={$PSItem.Count}}

    foreach($oin$out)
    {
    $na=$o.Name.replace(" ","\")
    $count=$o.RestorePoints
    write-output"veeam-stats,name=$na numberofrestores=$Count"
       }
  }
}

asnpVeeamPSSnapin
$backups=Get-VBRBackup
RestorePointStats
RestorePointCount
