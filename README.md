# Clutterfly

Incomplete client for the Fly Machines API. **Use this project at your own risk!** It may be unreliable and you can use it to spin up resources that cost money on a cloud. 

Makes API calls using dependency https://github.com/ckreiling/fly_machines (which uses `req`)

Validates request bodies against the Machines API OpenAPI spec using Ecto schemas in `lib/fly_schemas`. These were generated using https://github.com/clutterstack/openapi-json-to-ecto (which is half baked, so the validations are probably pretty janky).

## Usage

You can [set global configuration options for FlyMachines](https://github.com/ckreiling/fly_machines?tab=readme-ov-file#usage) in your app's `config.exs` like so:

```
config :fly_machines, default: [
  base_url: "https://api.machines.dev/v1",
  auth: {:bearer, System.fetch_env!("FLY_API_TOKEN")}
]
```
This gets a Fly.io auth token from the `FLY_API_TOKEN` environment variable on the host running the Elixir application that uses FlyMachines or Clutterfly.


If you're only managing Machines on one Fly app, you can set `FLY_API_TOKEN` to a Fly.io app deployment token. If you're on a Machine with flyctl installed and logged in, an easy way to set this is to run `export FLY_API_TOKEN=$(fly tokens deploy -a <appname>)` before starting.


### Make requests from an IEx shell

Run `iex -S mix` to compile and drop to an IEx shell where you can run commands like 

```
Clutterfly.Commands.run_min_config(yourapp)
```

to start a tiny machine.

## Todo: add tests

Who knows if half these schemas are nonsense?

## Todo: update schemas
Decide how: is it more work or less reliable to regenerate them by improving and rerunning `openapi-json-to-ecto` vs. diffing `spec.json`

## Todo: Retries and Req options
[FlyMachines accepts Req options as an arg, and Req handles retries](https://github.com/ckreiling/fly_machines?tab=readme-ov-file#request-retries)

Replaced FlyMachines with an internal FlyAPI module. 

## Todo: check if FlyAPI docs have all the parameters right
Claude generated docs for the API functions. Actually, this is structured data so should use a  program to get the docs -- or to generate the API functions for this module with specs and stuff.

## Todo: render example or model bodies
Follow all the embeds in a schema and display the structure.

## Dev scribbles

### Todo?
* Commands specifically for running from IEx (With wrapped errors and confirmation, pretty output)
* Validate path and query parameters. FlyMachines handles this OK(`wait` and `apps_list` both have query parameters) (Nimble Options?)


### Snippets
For parsing the response somewhere else
`{:error, %{:status => status, :body => %{"error" => errmsg}}} -> {:error, status}`