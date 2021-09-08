Set-Location ./deploy/

$admin_username = terraform output -raw "admin_username"
$admin_password = terraform output -raw "admin_password"
$instance_ip = terraform output -raw "instance_ip"

Set-Location ..

# SSH PS Session
$session = New-PSSession -HostName $instance_ip -UserName $admin_username -Password $admin_password

Enter-PSSession $session

# Run post-deploy script as Powershell over ssh
. .\post-deploy-script.ps1