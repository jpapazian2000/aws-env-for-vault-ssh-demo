output "ubuntu_pub-server_name" {
    value = aws_instance.ubuntu_public.public_dns
}

output "ubuntu_pub-server_public_ip" {
    value = aws_instance.ubuntu_public.public_ip
}

output "ssh-ca-public_key" {
    value = data.terraform_remote_state.ssh_ca_public_key.outputs.vault_public_key
}

#output "ubuntu_pub-server_private_ip" {
#    value = aws_instance.ubuntu_public.private_ip
#}

#output "ubuntu_priv-server_private_ip" {
#    value = aws_instance.ubuntu_private.private_ip
#}

output "vpc" {
    value = aws_vpc.ssh_project.tags.Name
}

output "private_subnet" {
    value = aws_subnet.private.tags.Name
}

output "aws_region" {
    value = var.region
}
