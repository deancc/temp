#
# string[] to string _or no return
function StringBuilder()
{
    param( [string[]] $ParameterName )
    
    foreach ($Parameter in $ParameterName)
    {
        [string] $Result += $Parameter
    }
    
    if(![string]::IsNullOrEmpty($Result))
    {
        return $Result
    }
}

function ParseDestinationList()
{

}

function TestDestination()
{

}

# Variable Declarations
[string]$time = Get-Date -Format "dd-MM-yyyy"

[string]$log_name = "connection_log"

[string]$log_directory = "\logs\"

[string]$current_directory = (Get-Location).Path

[string]$log_path = StringBuilder($current_directory, $log_directory)

[string]$wan_destination = "8.8.8.8"

[string]$lan_destination = (Get-NetRoute "0.0.0.0/0" | Select-Object -Property NextHop).NextHop

[string]$prompt_info = "CTRL+C to Exit"

[string]$prompt_wan = "Input alternate WAN? [default] $([string]$wan_destination)"

[string]$prompt_lan = "Input alternate LAN? [default] $([string]$lan_destination)"

[string]$prompt_delay = "Request delay in seconds?"

[int]$request_delay = 10

[int]$ui_dots = $request_delay * 2

# Validate / Generate Log Path and Log File
If(!(test-path -PathType container $log_path))
{
      New-Item -ItemType Directory -Path $log_path
}

$log = New-Item (StringBuilder($current_directory, $log_directory, $log_name, "_", $time, ".txt")) -Force

Clear-Host

# User Prompt and Inpu
Write-Host($prompt_info)
$wan_destination_alt = Read-Host($prompt_wan)
$lan_destination_alt = Read-Host($prompt_lan)
$request_delay = Read-Host($prompt_delay)

#
# User Input (kinda) Validation
if(![string]::IsNullOrEmpty($wan_destination_alt))
{
    if(Test-Connection $wan_destination_alt)
    {
        $wan_destination = $wan_destination_alt
    }
}

if(![string]::IsNullOrEmpty($lan_destination_alt))
{
    if(Test-Connection $lan_destination_alt)
    {
        $lan_destination = $lan_destination_alt
    }
}

if($request_delay -ge 1)
{
    [int]$ui_dots = ([int]$request_delay) * 2
}
else { $request_delay = 10 }

Clear-Host

# Test Connections Loop
while($true)
{
    Write-Host(StringBuilder("Log Directory: ", $log_path, "`n"))

    if(!(Test-Connection -ComputerName $wan_destination -Count 1 -Quiet))
    {
        $log_content = StringBuilder("Unreachable", ";", $wan_destination, ";", $(Get-Date))
        Write-Host ("$log_content")
        Add-Content $log -value $log_content
    }
    else{ Write-Host("Response;$wan_destination") }
    
    if(!(Test-Connection -ComputerName $lan_destination -Count 1 -Quiet))
    {
        $log_content = StringBuilder("Unreachable", ";", $lan_destination, ";", $(Get-Date))
        Write-Host ("$log_content")
        Add-Content $log -value $log_content
    } 
    else{ Write-Host("Response;$lan_destination") }

    # Display Output and Progress
    Write-Host("[$($request_delay)s]|") -NoNewline

    for($i = 0; $i -lt $ui_dots; $i++)
    {
        Write-Host(".") -NoNewline
        Start-Sleep -Milliseconds 500
    }

    Clear-Host
}
