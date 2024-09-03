variable "create_role" {
    type = bool
    default = true
    description = "Whether to create a role"
}
variable "role_name" {
    type = string
    default = null
    description = "Namw of IAM role"
}
variable "role_name_prefix" {
    type = string
    default = null
    description = "IAM role name prefix"
}

variable "allow_self_assume_role" {
    type = bool
    default = false
    description = "Determines whether to allow the role to be [assume itself]"
}
variable "role_path" {
    type = string
    default = "/"
    description = "Path of IAM role"
}
variable "oidc_providers" {
    type = any
    default = {}
    description = "Map of OIDC providers where each provider map should contain the `provider_arn` and `namespace_service_accounts`"
}
variable "assume_role_condition_test" {
    type = string
    default = "StringEquals"
    description = "Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role"
}
variable "role_description" {
    description = "IAM Role description"
    type        = string
    default     = null
}
variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = null
}
variable "max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}
variable "force_detach_policies" {
  description = "Whether policies should be detached from this role when destroying"
  type        = bool
  default     = true
}
variable "tags" {
  description = "A map of tags to add the the IAM role"
  type        = map(any)
  default     = {}
}
variable "role_policy_arns" {
  description = "ARNs of any policies to attach to the IAM role"
  type        = map(string)
  default     = {}
}