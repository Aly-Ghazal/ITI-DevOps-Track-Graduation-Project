output "publicSubnets-ids" {
    value = [for subnet in aws_subnet.publicSubnets : subnet.id]
}
output "PrivateSubnets-ids" {
    value = [for subnet in aws_subnet.privateSubnets : subnet.id]
}