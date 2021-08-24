variable sa_name {
  description = "Service Account Name"
  default     = "mongodb"
}
variable sc_name {
  description = "Storage Class Name"
  default     = "sc-mongodb-standalone"
}

variable docker_registry_file {
  description = "Docker Authentication Configuration File"
  default     = "/Users/patrickpresto/.docker/config.json"
}
variable docker_registry_secret_name {
  description = "Docker Authentication Configuration File"
  default     = "regcred"
}