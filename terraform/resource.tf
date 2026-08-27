# Kind Cluster
resource "kind_cluster" "voting_cluster" {
  name           = var.cluster_name
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # Map host port 80 to votes-ui
      extra_port_mappings {
        container_port = var.ui_node_port
        host_port      = var.ui_host_port
        protocol       = "TCP"
      }

      # Map host port 5001 to votes-api
      extra_port_mappings {
        container_port = var.api_node_port
        host_port      = var.api_host_port
        protocol       = "TCP"
      }
    }
  }
}

# Dynamic attributes from kind_cluster
provider "kubernetes" {
  host                   = kind_cluster.voting_cluster.endpoint
  client_certificate     = kind_cluster.voting_cluster.client_certificate
  client_key             = kind_cluster.voting_cluster.client_key
  cluster_ca_certificate = kind_cluster.voting_cluster.cluster_ca_certificate
}

# Namespace
resource "kubernetes_namespace" "app_ns" {
  depends_on = [kind_cluster.voting_cluster]

  metadata {
    name = var.namespace
  }
}

# DB Secrets
resource "kubernetes_secret" "db_secret" {
  metadata {
    name      = "db-secret"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  data = {
    POSTGRES_USER     = var.postgres_user
    POSTGRES_PASSWORD = var.postgres_password
    POSTGRES_DB       = var.postgres_db
  }
}

# API ConfigMap
resource "kubernetes_config_map" "api_config" {
  metadata {
    name      = "votes-api-config"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  data = {
    POSTGRES_HOST = var.postgres_host
    PORT          = var.api_port
    OPTION_A      = var.option_a
    OPTION_B      = var.option_b
  }
}

# UI ConfigMap
resource "kubernetes_config_map" "ui_config" {
  metadata {
    name      = "votes-ui-config"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  data = {
    VOTES_API_HOST = var.votes_api_host
    VOTES_API_PORT = var.api_port
    PORT           = var.ui_port
  }
}

# PostgreSQL Deployment
resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    replicas = var.postgres_replicas
    selector { match_labels = { app = "postgres" } }
    template {
      metadata { labels = { app = "postgres" } }
      spec {
        container {
          name  = "postgres"
          image = var.postgres_image

          env_from {
            secret_ref {
              name = kubernetes_secret.db_secret.metadata[0].name
            }
          }

          port {
            container_port = var.postgres_port
          }
        }
      }
    }
  }
}

# PostgreSQL Service
resource "kubernetes_service" "postgres_service" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    selector = { app = "postgres" }
    port {
      port        = var.postgres_port
      target_port = var.postgres_port
    }
  }
}

# Votes API Deployment
resource "kubernetes_deployment" "votes_api" {
  metadata {
    name      = "votes-api"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    replicas = var.votes_api_replicas
    selector { match_labels = { app = "votes-api" } }
    template {
      metadata { labels = { app = "votes-api" } }
      spec {
        container {
          name  = "votes-api"
          image = var.votes_api_image

          env_from {
            config_map_ref {
              name = kubernetes_config_map.api_config.metadata[0].name
            }
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.db_secret.metadata[0].name
            }
          }

          port {
            container_port = tonumber(var.api_port)
          }
        }
      }
    }
  }
}

# Votes API Service
resource "kubernetes_service" "votes_api_service" {
  metadata {
    name      = "votes-api"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    type     = "NodePort"
    selector = { app = "votes-api" }
    port {
      port        = tonumber(var.api_port)
      target_port = tonumber(var.api_port)
      node_port   = var.api_node_port
    }
  }
}

# Votes UI Deployment
resource "kubernetes_deployment" "votes_ui" {
  metadata {
    name      = "votes-ui"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    replicas = var.votes_ui_replicas
    selector { match_labels = { app = "votes-ui" } }
    template {
      metadata { labels = { app = "votes-ui" } }
      spec {
        container {
          name  = "votes-ui"
          image = var.votes_ui_image

          env_from {
            config_map_ref {
              name = kubernetes_config_map.ui_config.metadata[0].name
            }
          }

          port {
            container_port = tonumber(var.ui_port)
          }
        }
      }
    }
  }
}

# Votes UI Service
resource "kubernetes_service" "votes_ui_service" {
  metadata {
    name      = "votes-ui"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    type     = "NodePort"
    selector = { app = "votes-ui" }
    port {
      port        = var.ui_service_port
      target_port = tonumber(var.ui_port)
      node_port   = var.ui_node_port
    }
  }
}
