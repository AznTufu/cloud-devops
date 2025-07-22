output "frontend_url" {
  value = "http://${aws_instance.app.public_dns}"
  description = "URL de votre application React"
}

output "backend_url" {
  value = "http://${aws_instance.app.public_dns}:3005"
  description = "URL de votre API Express"
}

output "public_ip" {
  value = aws_instance.app.public_ip
  description = "Adresse IP publique du serveur"
}