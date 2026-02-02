output "instance_ip" {
    value = aws_lightsail_static_ip.wordpress_static_ip.ip_address
  
}

output "ssh_command" {
  
  value = "ssh bitnami@${aws_lightsail_static_ip.wordpress_static_ip.ip_address}"
}

output "password_command" {
    value = "cat bitnami_application_password"
  
}