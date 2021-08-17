variable "user_initials" {
    type = string

    validation {
        condition = length(var.user_initials) < 4 && can(regex("\\w{3}", var.user_initials))
        error_message = "The user_initials value must be a 3-character string of [a-zA-Z0-9_]."
    }
}

variable "subscription_id" {
    type = string
}

variable "location" {
    type = string
}

variable "location_short" {
    type = string
}

variable "vm_size" {
    type = string
    default = "Standard_NV6_Promo"
}


locals {
    admin_username = "${var.user_initials}Admin"
    resource_prefix = "${var.user_initials}-${var.location_short}-azgaming"
    resource_group_name = "${var.user_initials}-${var.location_short}-azgaming"
}