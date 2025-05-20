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

# output "parsed" {
#   value = module.lookup_data.parsed_body
# }

output "context_query_params_debug" {
  value = module.lookup_data.context_query_params_debug
}

output "test" {
  value = module.lookup_data.test
}