# Core Infra
variable "cluster_name" {
  type        = string
  default     = "voting-cluster"
}

variable "namespace" {
  type        = string
  default     = "voting-app"
}

# DB 
variable "postgres_user" {
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "postgres_password" {
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "postgres_db" {
  type        = string
  default     = "postgres"
}

# ConfigMaps
variable "postgres_host" {
  type        = string
  default     = "postgres"
}

variable "api_port" {
  type        = string
  default     = "5000"
}

variable "option_a" {
  type        = string
  default     = "Cats"
}

variable "option_b" {
  type        = string
  default     = "Dogs"
}

variable "votes_api_host" {
  type        = string
  default     = "votes-api"
}

variable "ui_port" {
  type        = string
  default     = "4000"
}

# Images
variable "postgres_image" {
  type        = string
  default     = "postgres:15-alpine"
}

variable "votes_api_image" {
  type        = string
  default     = "picta/votes-api:latest"
}

variable "votes_ui_image" {
  type        = string
  default     = "picta/votes-ui:latest"
}

# Replicas
variable "postgres_replicas" {
  type        = number
  default     = 1
}

variable "votes_api_replicas" {
  type        = number
  default     = 1
}

variable "votes_ui_replicas" {
  type        = number
  default     = 1
}

# Ports
variable "postgres_port" {
  description = "Port for PostgreSQL service"
  type        = number
  default     = 5432
}

variable "ui_node_port" {
  description = "NodePort for Votes UI service"
  type        = number
  default     = 30080
}

variable "ui_host_port" {
  description = "Host port mapped to UI NodePort in cluster"
  type        = number
  default     = 80
}

variable "api_node_port" {
  description = "NodePort for Votes API service"
  type        = number
  default     = 30001
}

variable "api_host_port" {
  description = "Host port mapped to API NodePort in cluster"
  type        = number
  default     = 5001
}

variable "ui_service_port" {
  description = "Exposed port for the UI service"
  type        = number
  default     = 80
}
