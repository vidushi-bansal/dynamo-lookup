module "lookup_data"{
  source = "../modules/lookup"
  resource = "cloudaccounts"
}

output "everything" {
  value = module.lookup_data.resource_metadata
}