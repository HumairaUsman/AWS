provider "aws" {
    region = var.region
}

resource "aws_lightsail_instance" "wordpress_blog"{
    name              = var.name
    availability_zone = var.availability_zone
    blueprint_id      = var.blueprint_id
    bundle_id         = "nano_3_0"

    add_on {
        type          = "AutoSnapshot"
        snapshot_time = "06:00"
        status        = "Enabled"
    }
    tags = var.tags

}

resource "aws_lightsail_static_ip" "wordpress_static_ip" {
  name = "wordpress_static_ip"
}

resource "aws_lightsail_static_ip_attachment" "wordpress_static_ip_attach" {
  static_ip_name = aws_lightsail_static_ip.wordpress_static_ip.id
  instance_name  = aws_lightsail_instance.wordpress_blog.id
}

resource "aws_lightsail_instance_public_ports" "wordpress_public_ip" {
  instance_name = aws_lightsail_instance.wordpress_blog.name

  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
  }

  port_info {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
  }
}