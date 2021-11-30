
output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "nat_public_ips" {
  value = "${module.vpc.nat_public_ips}"
}

# output "private_subnet_ids" {
#   value = "${module.vpc.private_subnets}"
# }

output "gateway_private_subnet_ids" {
  value = "${module.vpc.gateway_private_subnets}"
}

output "frontend_private_subnet_ids" {
  value = "${module.vpc.frontend_private_subnets}"
}

output "backend_private_subnet_ids" {
  value = "${module.vpc.backend_private_subnets}"
}

output "db_private_subnet_ids" {
  value = "${module.vpc.db_private_subnets}"
}

output "managed_private_subnet_ids" {
  value = "${module.vpc.managed_private_subnets}"
}
output "bigdata_private_subnet_ids" {
  value = "${module.vpc.bigdata_private_subnets}"
}

output "public_subnet_ids" {
  value = "${module.vpc.public_subnets}"
}

output "private_routetable_ids" {
    value = "${module.vpc.private_route_table_ids}"
}

output "public_routetable_ids" {
    value = "${module.vpc.public_route_table_ids}"
}
    
# output "bastion_ec2_id" {
#     value = "${module.ec2_bastion.id}"
# }
