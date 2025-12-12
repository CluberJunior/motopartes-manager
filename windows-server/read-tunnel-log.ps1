$securePass = ConvertTo-SecureString "Jomoponse_1" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("Administrador", $securePass)

Invoke-Command -ComputerName 192.168.1.104 -Credential $cred -ScriptBlock {
    Get-Content "C:\inetpub\wwwroot\motopartes-manager\localtunnel-output.txt"
}
