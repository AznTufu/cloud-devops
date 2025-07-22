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

output "dynamodb_table_name" {
  value = aws_dynamodb_table.todos_table.name
  description = "Nom de la table DynamoDB pour les todos"
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.todos_table.arn
  description = "ARN de la table DynamoDB"
}