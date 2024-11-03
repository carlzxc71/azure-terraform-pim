variable "subscription_id" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "swedencentral"
}

variable "location_short" {
  type    = string
  default = "se"
}
