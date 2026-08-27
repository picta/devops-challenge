# Core Infra
cluster_name       = "voting-cluster"
namespace          = "voting-app"

# DB
postgres_user      = "postgres"
postgres_password  = "postgres"
postgres_db        = "postgres"

# ConfigMaps
postgres_host      = "postgres"
api_port           = "5000"
option_a           = "Cats"
option_b           = "Dogs"

votes_api_host     = "votes-api"
ui_port            = "4000"

# Images
postgres_image     = "postgres:15-alpine"
votes_api_image    = "picta/votes-api:latest"
votes_ui_image     = "picta/votes-ui:latest"

# Replicas
postgres_replicas  = 1
votes_api_replicas = 1
votes_ui_replicas  = 1

# Ports
postgres_port      = 5432
ui_node_port       = 30080
ui_host_port       = 80
api_node_port      = 30001
api_host_port      = 5001
ui_service_port    = 80
