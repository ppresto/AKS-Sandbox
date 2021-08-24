# Use Terraform Import to migrate existing vault namespace to IaC
This is an example of importing terraform resoures.  In the case a statefile is lost or existing resources need to be imported into terraform you can use this approach.
 
## Setup

### terraform import
In this example I used the `vault-project-template/ns-mongo` directory that holds all the terraform necessary to configure the vault namespace.  This namespace is configured with policies, kv, and kubernetes auth.  I removed the terraform.tfstate and rebuilt it using the following import commands.

```
terraform import module.kmip-policy.vault_policy.acl mongodb
terraform import module.policy.vault_policy.acl k8s
terraform import module.kv.vault_mount.kv kv
terraform import module.kv.vault_generic_secret.secret kv/database/config
terraform import module.k8s.vault_auth_backend.kubernetes k8s
terraform import module.k8s.vault_kubernetes_auth_backend_config.k8s_auth auth/k8s/config
terraform import module.k8s.vault_kubernetes_auth_backend_role.k8s_role auth/k8s/role/k8s
terraform import vault_kubernetes_auth_backend_role.mongodb auth/k8s/role/mongodb
```

### terraform plan
To make sure everything was imported properly I ran a terraform plan.  I see some resources need to be updated in place.  This is normal.


* null_resource should be avoided when ever possible.  In my case I need this for some KMIP functionality.  This will need to be reran so ensure you always build immutable solutions.
```
Terraform will perform the following actions:

  # null_resource.setup-kmip will be created
  + resource "null_resource" "setup-kmip" {
      + id       = (known after apply)
      + triggers = {
          + "config_contents" = "754a44aeb7b10355488f3e20ed5e40f8"
        }
    }
```


* k8s auth backend needs to be updated in place to ensure the proper JWT token reviewer configuration. 
```
  # module.k8s.vault_auth_backend.kubernetes will be updated in-place
  ~ resource "vault_auth_backend" "kubernetes" {
        accessor                  = "auth_kubernetes_e0b9f96c"
        default_lease_ttl_seconds = 0
        id                        = "k8s"
        local                     = false
        max_lease_ttl_seconds     = 0
        path                      = "k8s"
      + tune                      = (known after apply)
        type                      = "kubernetes"
    }

  # module.k8s.vault_kubernetes_auth_backend_config.k8s_auth will be updated in-place
  ~ resource "vault_kubernetes_auth_backend_config" "k8s_auth" {
        backend            = "k8s"
        id                 = "auth/k8s/config"
        kubernetes_ca_cert = <<~EOT
            -----BEGIN CERTIFICATE-----
            .......
            -----END CERTIFICATE-----
        EOT
        kubernetes_host    = "https://aks-1-041e33da.hcp.westus2.azmk8s.io:443"
        pem_keys           = []
      + token_reviewer_jwt = (sensitive value)
    }
```

* kv mount was required to be replaced in my case because I"m using kv-v2.  I found this a little suprising.  This happened very quickly, but could impact secrets for < 1sec.
```
  # module.kv.vault_mount.kv must be replaced
-/+ resource "vault_mount" "kv" {
      ~ accessor                  = "kv_813070f4" -> (known after apply)
      ~ default_lease_ttl_seconds = 0 -> (known after apply)
        description               = "kv secret engine managed by Terraform"
        external_entropy_access   = false
      ~ id                        = "kv" -> (known after apply)
      - local                     = false -> null
      ~ max_lease_ttl_seconds     = 0 -> (known after apply)
      - options                   = {
          - "version" = "2"
        } -> null
        path                      = "kv"
      ~ seal_wrap                 = false -> (known after apply)
      ~ type                      = "kv" -> "kv-v2" # forces replacement
    }

Plan: 2 to add, 2 to change, 1 to destroy.
```


