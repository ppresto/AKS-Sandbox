variable prefix {}
variable ARM_CLIENT_ID {}
variable ARM_CLIENT_SECRET {}
variable ARM_SUBSCRIPTION_ID {} 
variable ARM_TENANT_ID {}
variable MY_RG {}

variable location {
    default = "West US 2"
}

variable ssh_user {
    default = "patrickpresto"
}
variable public_ssh_key_path {
    default = "~/.ssh/id_rsa.pub"
}
variable my_tags {
    type = map
    default = {
        env = "dev"
        owner = "ppresto"
    }
}