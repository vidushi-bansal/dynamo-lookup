module "lookup_data"{
  source = "../modules/lookup"
  resource = "cloudaccounts"
}

output "prod_data" {
  value = module.lookup_data.resource_metadata
}