# Kind Cluster
resource "kind_cluster" "voting_cluster" {
  name           = "voting-cluster"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # Map host port 80 to votes-ui (NodePort 30080)
      extra_port_mappings {
        container_port = 30080
        host_port      = 80
        protocol       = "TCP"
      }

      # Map host port 5001 to votes-api (NodePort 30001)
      extra_port_mappings {
        container_port = 30001
        host_port      = 5001
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
    name = "voting-app"
  }
}

# DB Secrets
resource "kubernetes_secret" "db_secret" {
  metadata {
    name      = "db-secret"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  data = {
    POSTGRES_USER     = "postgres"
    POSTGRES_PASSWORD = "postgres"
    POSTGRES_DB       = "postgres"
  }
}

# API ConfigMap
resource "kubernetes_config_map" "api_config" {
  metadata {
    name      = "votes-api-config"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  data = {
    POSTGRES_HOST = "postgres"
    PORT          = "5000"
    OPTION_A      = "Cats"
    OPTION_B      = "Dogs"
  }
}

# UI ConfigMap
resource "kubernetes_config_map" "ui_config" {
  metadata {
    name      = "votes-ui-config"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  data = {
    VOTES_API_HOST = "votes-api"
    VOTES_API_PORT = "5000"
    PORT           = "4000"
  }
}

# PostgreSQL Deployment
resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    replicas = 1
    selector { match_labels = { app = "postgres" } }
    template {
      metadata { labels = { app = "postgres" } }
      spec {
        container {
          name  = "postgres"
          image = "postgres:15-alpine"

          env_from {
            secret_ref {
              name = kubernetes_secret.db_secret.metadata[0].name
            }
          }

          port {
            container_port = 5432
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
      port        = 5432
      target_port = 5432
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
    replicas = 1
    selector { match_labels = { app = "votes-api" } }
    template {
      metadata { labels = { app = "votes-api" } }
      spec {
        container {
          name  = "votes-api"
          image = "picta/votes-api:latest"

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
            container_port = 5000
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
      port        = 5000
      target_port = 5000
      node_port   = 30001
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
    replicas = 1
    selector { match_labels = { app = "votes-ui" } }
    template {
      metadata { labels = { app = "votes-ui" } }
      spec {
        container {
          name  = "votes-ui"
          image = "picta/votes-ui:latest"

          env_from {
            config_map_ref {
              name = kubernetes_config_map.ui_config.metadata[0].name
            }
          }

          port {
            container_port = 4000
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
      port        = 80
      target_port = 4000
      node_port   = 30080
    }
  }
}
