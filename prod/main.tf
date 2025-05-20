module "lookup_data"{
  source = "../modules/lookup"
  resource = "cloudaccounts"
  context_query_params = var.context_query_params
}

output "prod_data" {
  value = module.lookup_data.resource_metadata
}
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

