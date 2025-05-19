module "lookup_data"{
  source = "../modules/lookup"
  resource = "cloudaccounts"
}

# output "prod_data" {
#   value = module.lookup_data.resource_metadata
# }
#
# output "count" {
#   value = module.lookup_data.item_count
# }
output "parsed" {
  value = module.lookup_data.parsed_body
}