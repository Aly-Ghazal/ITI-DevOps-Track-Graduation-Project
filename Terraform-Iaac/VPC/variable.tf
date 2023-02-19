variable "VPC-cidr" {
  type = string
}
variable "VPC-name" {
  type = string
}
variable "publicSubnets-cidr" {
  type = list(any)
}
variable "Subnet-Availability-zones" {
  type = list(any)
}
variable "publicSubnets-tag-names" {
  type = list(any)
}
variable "privateSubnets-cidr" {
  type = list(any)
}
variable "privateSubnets-tag-names" {
  type = list(any)
}