# General application configuration
import Config

config :clutterfly,
  api_token: System.fetch_env!("FLY_API_TOKEN")


# Config for https://github.com/ckreiling/fly_machines API client (based on Req)
config :fly_machines, default: [
  base_url: "https://api.machines.dev/v1",
  auth: {:bearer, System.fetch_env!("FLY_API_TOKEN")}
]
