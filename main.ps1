
Set-Location .\deploy\

terraform init


az login

terraform apply -auto-approve -json

# $admin_username = terraform output -raw "admin_username"
# $admin_password = terraform output -raw "admin_password"
# $instance_ip = terraform output -raw "instance_ip"
# $my_ip = (Resolve-DnsName -Name myip.opendns.com -Server 208.67.222.220).IPAddress

# Set-Location ..




# we no longer use ansible as we're using windows machines to execute
# $ini_location = "ansible/hosts.ini"
# (Get-Content -path $ini_location -Raw) | -replace '%myIp%', $my_ip

# and ansible isn't supported by windows
# python -m pip install ansible --user
# ansible-playbook -i ansible/hosts.ini ansible/main.yml --extra-vars "admin_username = ${admin_username}"