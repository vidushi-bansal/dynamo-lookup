locals {
  parsed_body = jsondecode(data.http.lookup.response_body)

  result_count = length(local.parsed_body)

  selected = local.result_count == 1 ? local.parsed_body[0] : tomap({})

}

resource "null_resource" "validate" {
  count = local.result_count != 1 ? 1 : 0
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "Echo: Error. Got ${local.result_count} result(s)."
  }
}

output "resource_metadata" {
  value = local.selected
}

output "item_count" {
  value = local.result_count
}

output "parsed_body" {
  value = local.parsed_body
}

output "context_query_params_debug" {
  value = var.context_query_params
}