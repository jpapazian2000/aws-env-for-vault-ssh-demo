terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "terraform_remote_state" "ssh_ca_public_key" {
    backend                 = "remote"
    config                  = {
        organization        = "jpapazian-org"
        workspaces          = {
            name            = "vault-ssh-conf"
        }
    }
}

provider "aws" {
    region = var.region
}
resource "aws_vpc" "ssh_project" {
    cidr_block              = "10.10.0.0/16"
    enable_dns_hostnames    = true

    tags = {
        Name        = "jpapazian-${var.project}-public"
        owner       = "jpapazian"
        se-region   = "europe west 3"
        purpose     = "vault ssh demo for customer"
        ttl         = "8"
        terraform   = "yes"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id          = aws_vpc.ssh_project.id

    tags = {
        Name        = "jpapazian-${var.project}-public"
        owner       = "jpapazian"
        se-region   = "europe west 3"
        purpose     = "vault ssh demo for customer"
        ttl         = "8"
        terraform   = "yes"
    }
}

resource "aws_default_route_table" "main" {
    default_route_table_id = aws_vpc.ssh_project.default_route_table_id

    tags = {
        Name        = "jpapazian-${var.project}-public"
        owner       = "jpapazian"
        se-region   = "europe west 3"
        purpose     = "vault ssh demo for customer"
        ttl         = "8"
        terraform   = "yes"
    }

    route {
        cidr_block  = "0.0.0.0/0"
        gateway_id  = aws_internet_gateway.gw.id
    }
}

resource "aws_route_table_association" "route-to-private" {
    subnet_id       = aws_subnet.private.id
    route_table_id  = aws_default_route_table.main.id
}

resource "aws_subnet" "private" {
    vpc_id          = aws_vpc.ssh_project.id
    cidr_block      = "10.10.20.0/24"

    tags = {
        Name        = "jpapazian-${var.project}-public"
        owner       = "jpapazian"
        se-region   = "europe west 3"
        purpose     = "vault ssh demo for customer"
        ttl         = "8"
        terraform   = "yes"
    }
}
resource "aws_default_network_acl" "ssh_vpc_nacl" {
  default_network_acl_id = aws_vpc.ssh_project.default_network_acl_id

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "default network acl-JP"
  }
}

data "aws_subnet" "select_private" {
    id              = aws_subnet.private.id
}

#resource "aws_network_interface" "private_if" {
#    subnet_id       = aws_subnet.private.id
#}

resource "aws_key_pair" "ubuntu_kp" {
    key_name        = "ubuntu_public_key"
    public_key      = var.public_key
}

resource "aws_default_security_group" "allow_ssh_from_public" {
    #name            = "allow_ssh_from_public"
    #description     = "allow_ssh_inbound_traffic"
    vpc_id          = aws_vpc.ssh_project.id

    tags = {
        Name        = "jpapazian-${var.project}-public"
        owner       = "jpapazian"
        se-region   = "europe west 3"
        purpose     = "vault ssh demo for customer"
        ttl         = "8"
        terraform   = "yes"
    }

    ingress {
        description = "allow ingress ssh from public"
        #self        = "true"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.allowed_public_ip]
    }
}

resource "aws_security_group" "allow_ssh_from_private" {
    name            = "allow ssh from private"
    description     = "allow ssh inbound traffic from private"
    vpc_id         = aws_vpc.ssh_project.id

    tags = {
        Name        = "${var.project}-private-sg"
    }

    ingress {
        description = "allow ingress ssh from private"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [data.aws_subnet.select_private.cidr_block]
    }
}
data "template_file" "user_data" {
  template = file("${path.root}/scripts/add-ssh-config.yaml")
vars = {
    ssh_key  = chomp(data.terraform_remote_state.ssh_ca_public_key.outputs.vault_public_key)
  }
}

resource "aws_instance" "bastion" {
    ami                         = var.ubuntu_ami
    instance_type               = var.instance_type
    key_name                    = aws_key_pair.ubuntu_kp.key_name
    subnet_id                   = aws_subnet.private.id
    vpc_security_group_ids      = [
        aws_default_security_group.allow_ssh_from_public.id,
    ]
    associate_public_ip_address = true
    depends_on      = [aws_internet_gateway.gw]

    tags = {
        Name        = "jpapazian-${var.project}-bastion"
        owner       = "jpapazian"
        se-region   = "europe west 3"
        purpose     = "vault ssh demo for customer"
        ttl         = "8"
        terraform   = "yes"
    }
}

resource "aws_instance" "ubuntu_server" {
    ami                         = var.ubuntu_ami
    key_name                    = aws_key_pair.ubuntu_kp.key_name
    instance_type               = var.instance_type
    subnet_id                   = aws_subnet.private.id
    #vpc_security_group_ids      = [
    #    aws_security_group.allow_ssh_from_private.id,
    #]
    associate_public_ip_address = true
    user_data                   = data.template_file.user_data.rendered
    depends_on      = [aws_internet_gateway.gw]

    tags = {
        Name        = "jpapazian-${var.project}-server"
        owner       = "jpapazian"
        se-region   = "europe west 3"
        purpose     = "vault ssh demo for customer"
        ttl         = "8"
        terraform   = "yes"
    }
}