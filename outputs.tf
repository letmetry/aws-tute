output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The unique tracking reference signature of the network architecture blueprint."
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "A listing profile containing all active public subnet signatures."
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "A listing profile containing all insulated active private subnet signatures."
}

output "private_instance_id" {
  value       = aws_instance.app_server.id
  description = "Target identification token used when creating internal SSM connection loops."
}

output "secret_arn" {
  value       = aws_secretsmanager_secret.app_secret.arn
  description = "The security scope Amazon Resource Name pointing towards production keys."
}
