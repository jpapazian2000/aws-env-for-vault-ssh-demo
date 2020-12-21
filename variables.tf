variable "region" {
    default     = "eu-west-3"
    description = "region to start the instances"
}

variable "allowed_public_ip" {
    default     = ""
    description = "remote ip allowed to connect to instances"
}

 variable "ubuntu_ami" {
     default        = "ami-0d3f551818b21ed81"
     description    = "ami of the ubuntu serveur we want to create"
 }

 variable "instance_type" {
     default        = "t2.micro"
     description    = "smallest size to get a free tier for testing purposes"
 }

 variable "remote_public_ip" {
     description    = "remote ip allowed to connect to instances"
 }

 variable "public_key" {
     default        = ""
     description    = "public key pair for the instance"
 }
