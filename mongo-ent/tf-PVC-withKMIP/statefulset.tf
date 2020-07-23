resource "kubernetes_stateful_set" "mongodb-standalone-kmip" {
  metadata {
    #labels = {
    #  k8s-app                           = "mongodb"
    #  version                           = "v1.0"
    #}
    name = "mongodb-standalone-kmip"
  }

  spec {
    pod_management_policy  = "Parallel"
    replicas               = 1
    revision_history_limit = 5

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }

    selector {
      match_labels = {
        app = "database"
      }
    }

    service_name = "database"

    template {
      metadata {
        labels = {
          app      = "database"
          selector = "mongodb-standalone"
        }
        annotations = {
          "vault.hashicorp.com/agent-inject"                              = "true"
          "vault.hashicorp.com/role"                                      = var.sa_name
          "vault.hashicorp.com/namespace"                                 = "apttus"
          "vault.hashicorp.com/auth-path"                                 = "auth/k8s"
          "vault.hashicorp.com/agent-inject-secret-database-ca.pem"       = "kv/data/database/certs/ca"
          "vault.hashicorp.com/agent-inject-secret-database-client.pem"   = "kv/data/database/certs/client"
          "vault.hashicorp.com/agent-inject-secret-database-config.txt"   = "kv/data/database/config"
          "vault.hashicorp.com/agent-inject-template-database-ca.pem"     = <<-EOF
          {{- with secret "kv/data/database/certs/ca" -}}
            {{- range $k, $v := .Data.data -}}
                {{- $v -}}
            {{- end -}}
          {{- end -}}
          EOF
          "vault.hashicorp.com/agent-inject-template-database-client.pem" = <<-EOF
          {{- with secret "kv/data/database/certs/client" -}}
            {{- range $k, $v := .Data.data -}}
                {{- $v -}}
            {{- end -}}
          {{- end -}}
          EOF
          #"vault.hashicorp.com/agent-inject-template-database-config.txt" = "|\n{{- with secret "/database/config" -}}\n{{ .Data.username }}:{{ .Data.password }}@mongodb://mongodb-standalone-0.database:27017\n{{- end }}"
        }
      }
      spec {
        service_account_name            = var.sa_name
        automount_service_account_token = true

        container {
          name              = "mongodb-standalone"
          image             = "ppresto/mongo-ent:4.2"
          image_pull_policy = "IfNotPresent"
          env {
            name  = "MONGO_INITDB_ROOT_USERNAME"
            value = "admin"
          }
          env {
            name  = "MONGO_INITDB_ROOT_PASSWORD"
            value = "password"
          }

          command = [
            "mongod",
            "--auth",
            "--bind_ip_all",
            "--enableEncryption",
            "--kmipServerName",
            "vault-kmip",
            "--kmipPort",
            "5696",
            "--kmipServerCAFile",
            "/vault/secrets/database-ca.pem",
            "--kmipClientCertificateFile",
            "/vault/secrets/database-client.pem"
          ]
            # Use with configmap if Vault k/v isn't available.  
            # configmap: ../../vault-project-template/scripts/setup_kmip.sh
            
            #"--kmipServerCAFile",
            #"/etc/mongo/certs/vault-ca-kmip.pem",
            #"--kmipClientCertificateFile",
            #"/etc/mongo/certs/vault-cert-tenant-1.pem"
          volume_mount {
            name       = "mongodb-conf"
            mount_path = "/config"
            read_only  = true
          }
          volume_mount {
            name       = "mongodb-data"
            mount_path = "/data/db"
            #read_only  = false
          }

          resources {
            limits {
              cpu    = "200m"
              memory = "1000Mi"
            }

            requests {
              cpu    = "200m"
              memory = "1000Mi"
            }
          }
        }
        image_pull_secrets {
          name = var.docker_registry_secret_name
        }
        volume {
          name = "mongodb-conf"
          config_map {
            name = "mongodb-standalone"
            items {
              key  = "mongo.conf"
              path = "mongo.conf"
            }
          }
        }
        volume {
          name = "mongodb-data"
          persistent_volume_claim {
            claim_name = "pvc-mongodb-standalone"
          }
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }
  }
}