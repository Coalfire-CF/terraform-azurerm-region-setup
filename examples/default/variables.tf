variable "location" {
  type        = string
  description = "Azure Government region for all resources, for example usgovvirginia."
}

variable "location_abbreviation" {
  type        = string
  description = "Four-letter code for the region, used in fallback storage account names."
}

variable "app_abbreviation" {
  type        = string
  description = "Short application code, used in fallback storage account names."
}

variable "resource_prefix" {
  type        = string
  description = "Name prefix for resources. Hyphens are removed for storage account names."
}

variable "diag_log_analytics_id" {
  type        = string
  description = "Resource ID of the Log Analytics workspace that receives storage diagnostics."
}

variable "global_tags" {
  type        = map(string)
  description = "Tags applied to every taggable resource."
  default     = {}
}

variable "regional_tags" {
  type        = map(string)
  description = "Region-level tags, merged after global_tags."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Extra tags, merged after global_tags and regional_tags."
  default     = {}
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the storage private endpoints. Null creates none."
  default     = null
}

variable "blob_private_dns_zone_id" {
  type        = string
  description = "ID of the privatelink.blob private DNS zone. Null skips the DNS zone group."
  default     = null
}

variable "file_private_dns_zone_id" {
  type        = string
  description = "ID of the privatelink.file private DNS zone. Null skips the DNS zone group."
  default     = null
}
