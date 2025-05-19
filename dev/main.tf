module "lookup_data"{
  source = "../modules/lookup"
  resource = "cloudaccounts"
  extra_query_params = {
    account_id = "12345"
  }
}

output "evverything" {
  value = module.lookup_data.resource_metadata
}