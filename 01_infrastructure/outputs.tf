output "shared_vpc_id_prod" {
  description = "ID of the shared VPC"
  value       = module.vpc.vpc_id
}

output "shared_vpc_id_prod_private_subnet_ids" {
  description = "List of private subnet IDs in the shared VPC"
  value       = module.vpc.private_subnets
}

output "shared_vpc_id_prod_database_subnet_ids" {
  description = "List of database subnet IDs in the shared VPC"
  value       = module.vpc.database_subnets
}
