variable "project_id" {
  description = "The ID of the project in whinch to provision resources."
  default = "qwiklabs-gcp-02-234c95754c7c"
}

variable "name" {
  description = "Name of the buckets to create."
  type = string
  default = "qwiklabs-gcp-02-234c95754c7c-bucket1"
}
