locals {
  api = "https://6zlfiaa3sf.execute-api.us-east-1.amazonaws.com/dev/items"

  context_vars = {
    region = data.aws_region.current.name
    environment = basename(dirname(path.cwd))
  }
  resource_filters = {
    vpc = ["region", "environment"]
    subnet = ["region", "environment"]
  }

  selected_keys = lookup(local.resource_filters, var.resource, [])

  selected_context = {
    for k in local.selected_keys : k => local.context_vars[k]
          if local.context_vars[k] != null
  }

  ddtable = "cloudaccounts"

  query_params = merge (
    local.selected_context,
    var.context_query_params,
    var.extra_query_params,
    { ddtable = local.ddtable }
  )

  encoded_params = [
    for k, v in local.query_params : "${k}=${urlencode(v)}"
  ]

  query_string = join("&", local.encoded_params)

  api_url = "${local.api}?${local.query_string}"
}

data "http" "lookup" {
  url = local.api_url
}