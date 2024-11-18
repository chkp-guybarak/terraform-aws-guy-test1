output "subnet_id" {
  description = "The ID of the created subnet"
  value       = aws_subnet.minimal_subnet.id
}
