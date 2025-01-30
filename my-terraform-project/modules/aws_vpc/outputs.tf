output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "The public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "The private subnet IDs"
  value       = aws_subnet.private[*].id
}

