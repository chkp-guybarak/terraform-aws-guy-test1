output "vpc_id" {
  value = module.standalone-master.vpc_id
}
output "internal_rtb_id" {
  value = module.standalone-master.internal_rtb_id
}
output "vpc_public_subnets_ids_list" {
  value = module.standalone-master.vpc_public_subnets_ids_list
}
output "vpc_private_subnets_ids_list" {
  value = module.standalone-master.vpc_private_subnets_ids_list
}
output "standalone_instance_id" {
  value = module.standalone-master.standalone_instance_id
}
output "standalone_instance_name" {
  value = module.standalone-master.standalone_instance_name
}
output "standalone_public_ip" {
  value = module.standalone-master.standalone_public_ip
}
output "standalone_ssh" {
  value = module.standalone-master.standalone_ssh
}
output "standalone_url" {
  value = module.standalone-master.standalone_ssh
}