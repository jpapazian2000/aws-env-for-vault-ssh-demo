output "ubuntu_bastion-server_name" {
    value = aws_instance.bastion.public_dns
}

output "ubuntu_bastion-server_public_ip" {
    value = aws_instance.bastion.public_ip
}

output "ssh-ca-public_key" {
    value = chomp(data.terraform_remote_state.ssh_ca_public_key.outputs.vault_public_key)
}

#output "ubuntu_bastion-server_private_ip" {
#    value = aws_instance.bastion.private_ip
#}

output "ubuntu_ubuntu-server_private_ip" {
    value = aws_instance.ubuntu_server.private_ip
}
 output "ubuntu_server-public_ip" {
     value = aws_instance.ubuntu_server.public_ip
 }

output "vpc" {
    value = aws_vpc.ssh_project.tags.Name
}

output "private_subnet" {
    value = aws_subnet.private.tags.Name
}

output "aws_region" {
    value = var.region
}
