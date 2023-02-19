output "publicSubnets-ids" {
    value = [for subnet in aws_subnet.publicSubnets : subnet.id]
}