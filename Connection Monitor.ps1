$str_time = Get-Date -Format "dd-MM-yyyy"

$ui_dots = 10

$path = (Get-Location).Path

$log = New-Item "C:\users\omadmin\desktop\logs\ping_log_($string_time).txt" -Force

$lan_d = (Get-NetRoute "0.0.0.0/0" | Select-Object -Property NextHop).NextHop

$wan_d = "8.8.8.8"

$log_path = "$path" + "\logs\"

If(!(test-path -PathType container $log_path))
{
      New-Item -ItemType Directory -Path $log_path
}

clear

Write-Host("CTRL+C to Exit")

$wan_d_alt = Read-Host("Input alternate WAN address? [default (google) $wan_d] ")
$lan_d_alt = Read-Host("Input alternate LAN address? [default (default gateway) $lan_d] ")
$req_delay = Read-Host("Delay request by num second? [default $($dots / 2)] ")

if($wan_d_alt)
{
    $wan_d = $wan_d_alt
}

if($lan_d_alt)
{
    $lan_d = $lan_d_alt
}

if($req_delay -and (($req_delay / 2.0) -gt 1))
{
    $ui_dots = $req_delay / 0.5
}

clear

while($true)
{
    if(!(Test-Connection -ComputerName $wan_d -Count 1 -Quiet))
    {
        $log_cont = "Unreachable;$wan_d;$(Get-Date -Format 'u')"
        Write-Host ("$log_cont")
        Add-Content $log -value $log_cont
    }
    
    else
    {
        Write-Host("Response;$wan_d")
    }
    
    
    if(!(Test-Connection -ComputerName $lan_d -Count 1 -Quiet))
    {
        $log_cont = "Unreachable;$lan_d;$(Get-Date -Format 'u')"
        Write-Host ("$log_cont")
        Add-Content $log -value $log_cont
    }
    
    else
    {
        Write-Host("Response;$lan_d")
    }

    for($dot_iter = 0; $dot_iter -lt $ui_dots; $dot_iter++)
    {
        Write-Host(".") -NoNewline
        Start-Sleep -Milliseconds 500
    }

    clear
}