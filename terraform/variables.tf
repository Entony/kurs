variable "folder_id" {}
variable "service_account_id" {}
variable "vm_user" {}
variable "ssh_key" {}

variable "db_password" {
  type        = string
  description = "Пароль для пользователя Zabbix в PostgreSQL"
}

variable "git_repo_url" {
  type    = string
  default = "https://github.com/entony/website.git"
}
