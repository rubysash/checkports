<#

-----------------
DESCRIPTION
-----------------
Given a host and a list of ports, tells you if they are open/closed

SIMPLER ONELINER:
(cannot specify timeout or multiple ports, but does TCP Connect)
	PS> while(1) {sleep -sec 2; Test-NetConnection -Computername 'yourhost.com' -Port 443 -Information Quiet}

THIS VERSION:
Allows 1 host and multiple ports, colorizes output, measures time taken
(based on Chapmans code with a few adjustments because the timewait was annoying)

-----------------
OUTPUT:
-----------------
PS C:\Users\James\Desktop> &".\checkports.ps1" 'yourhost.com',22,80,443,3389
MM/DD/YYY HH:MM:SS      STAT    PORT    HOST            TIME TAKEN
12/09/2020 13:09:32     OPEN    22      yourhost.com     0.0491842
12/09/2020 13:09:34     OPEN    80      yourhost.com     0.0401987
12/09/2020 13:09:36     OPEN    443     yourhost.com     0.0426557
12/09/2020 13:09:40     FAIL    3389    yourhost.com     1.5036415


MM/DD/YYY HH:MM:SS      STAT    PORT    HOST            TIME TAKEN
12/09/2020 13:09:42     OPEN    22      yourhost.com     0.0436378
12/09/2020 13:09:44     OPEN    80      yourhost.com     0.0413645
12/09/2020 13:09:46     OPEN    443     yourhost.com     0.0415196
12/09/2020 13:09:49     FAIL    3389    yourhost.com     1.5025818


-----------------
INSTRUCTIONS:   
-----------------
CHECK PERMISSION:
Get-ExecutionPolicy -List

SET PERMISSION:
Set-ExecutionPolicy Unrestricted

SAVE AND RUN:
Save as "checkports.ps1"

USAGE:
	PS> & ".\checkports.ps1" "yourhost.com",21,22,80,443,3389


#>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$False)]
	[string[]]$in=@()
)
if ( $PSBoundParameters.Values.Count -eq 0 ){ 
    write-host "USAGE:" -ForegroundColor Red
    write-host "`tPS> & '.\checkports.ps1' 'yourhost.com',21,22,80,443,3389" -ForegroundColor Red
    return
}


$h,$ps = $in


while(1){
	write-host "MM/DD/YYYY HH:MM:SS`tSTAT`tPORT`tHOST`t`tTIME TAKEN" -ForegroundColor Yellow		
	foreach ($p in $ps) {
		# measure it
		Measure-Command {
			
			# try a connection
			try {
				$client = new-object System.Net.Sockets.TcpClient
				$opened = $client.ConnectAsync($h,$p).Wait(1500)
				
				# if actively closed or fails timeout
				if($opened){
					$client.Close()
					write-host -NoNewline "$(Get-Date)`tOPEN`t$p`t$h`t" -ForegroundColor Green
				} else {
					write-host -NoNewline "$(Get-Date)`tFAIL`t$p`t$h`t" -ForegroundColor Red
				}
			}

			# default if it fails connect
			catch {
				write-host -NoNewline "$(Get-Date)`t????`t$p`t$h`t" -ForegroundColor Red
			}
		} | % TotalSeconds
	
		# wait 2 seconds between each port to prevent blocking
		Start-Sleep -Seconds 2
	}

	write-host "`n"
}