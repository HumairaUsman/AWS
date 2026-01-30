variable "region"{
    description = "Region in which the bucket s hosted"
    type = string
    default = "us-east-1"
}
variable "domain_name" {
    description = "The root domain name for the website (e.g., example.com)."
    type        = string
}

variable "tags" {
    description = "Tags to apply on all the resources in the bucket"
    type        = map(string)
    default     = {
        Project   = "Static-Website"
        ManagedBy = "Terraform"
    }
}

variable "index_document"{
    description = "The main entry point for the website."
    type        = string
    default     = "index.html"
}