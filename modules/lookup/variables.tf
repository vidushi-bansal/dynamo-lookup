variable "resource" {}

variable "extra_query_params" {
  type = map(string)
  default = {}
}

variable "context_query_params" {
  description = "All context variables from Spacelift to send as query params"
  type        = map(string)
  default     = {}
}


