variable "region" {
    type = string
    default = "us-east-1"
}

variable "availability_zone"{
    type = string
    default = "us-east-1b"
}

variable "blueprint_id"{
    type = string
    default = "amazon_linux_2"
}

variable "name" {
    default = "wordpress"
    type = string  
}

variable "tags" {
    description = "Tags to apply on all the resources in the bucket"
    type        = map(string)
    default     = {
        Project   = "Wordress-blog"
        ManagedBy = "Terraform"
    }
}

