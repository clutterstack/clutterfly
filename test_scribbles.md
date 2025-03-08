## not logged in: 

```
➜  where_machines git:(main) ✗ fly auth logout
$FLY_API_TOKEN is set in your environment; don't forget to remove it.%                        
➜  where_machines git:(main) ✗ iex -S mix                 
Erlang/OTP 27 [erts-15.2] [source] [64-bit] [smp:12:12] [ds:12:12:10] [async-threads:1] [jit]

[info] Migrations already up
Interactive Elixir (1.17.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> Clutterfly.Commands.run_min_config()
{:error,
 #FlyMachines.Response<
   status: 401,
   headers: %{
     "content-type" => ["application/json; charset=utf-8"],
     "date" => ["Fri, 07 Mar 2025 16:34:03 GMT"],
     "fly-request-id" => ["01JNRQ9VVKJ7HZFMJWJB3M3RYN-yyz"],
     "fly-span-id" => ["3329da9b3fdefd48"],
     "fly-trace-id" => ["cba45eb5e6b1ccb2ac9095c30c190a27"],
     "server" => ["Fly/6dbc66600 (2025-03-04)"],
     "transfer-encoding" => ["chunked"],
     "via" => ["1.1 fly.io"],
     "x-envoy-upstream-service-time" => ["0"]
   },
   body: %{"error" => "Authenticate: token validation error"},
   ...
 >}
 ```

 ## possibly valid request body (claude)

 ```
 %{
  config: %{
    image: "registry.fly.io/where:debian-nano",
    auto_destroy: true,
    guest: %{
      cpu_kind: "shared",
      cpus: 1,
      memory_mb: 256
    },
    # Optional fields below
    services: [
      %{
        ports: [
          %{
            port: 80,
            handlers: ["http"]
          }
        ],
        protocol: "tcp",
        internal_port: 8080
      }
    ],
    # Ensure machine stops properly on shutdown
    stop_config: %{
      signal: "SIGINT",
      timeout: %{
        time_duration: 30
      }
    }
  },
  # Optional fields
  name: "my-machine",
  region: "yyz"  # Using the region from your fly.toml
}
```

## Try to create an app using a deploy token (403: unauthorized)

```
client = Clutterfly.FlyAPI.new
iex(25)> Clutterfly.FlyAPI.create_app(client, %{app_name: "where-2", org_slug: "personal"})
[(clutterfly 0.1.0) lib/fly_api.ex:72: Clutterfly.FlyAPI.request/4]
opts #=> [body: %{org_slug: "personal", app_name: "where-2"}]

<!-- Req.request returned this: {:ok,
 %Req.Response{
   status: 403,
   headers: %{
     "content-type" => ["application/json; charset=utf-8"],
     "date" => ["Sat, 08 Mar 2025 04:37:37 GMT"],
     "fly-request-id" => ["01JNT0PRE4J80RBKMBXAY1WGFQ-yyz"],
     "fly-span-id" => ["24ec2652f82f440a"],
     "fly-trace-id" => ["bd12694e16e088163cf18eec8167fa74"],
     "server" => ["Fly/dcbfc673f (2025-03-07)"],
     "transfer-encoding" => ["chunked"],
     "via" => ["1.1 fly.io"],
     "x-envoy-upstream-service-time" => ["73"]
   },
   body: %{"error" => "unauthorized"},
   trailers: %{},
   private: %{}
 }} -->

{:error, "403: unauthorized"}
```
