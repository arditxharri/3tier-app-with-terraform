variable "db_name" {
  description = "The name of the initial database"
  type        = string
}

variable "db_user" {
  description = "Username for the database"
  type        = string
}

variable "db_pass" {
  description = "Password for the database user"
  type        = string
  sensitive   = true
}
