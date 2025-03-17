defmodule Clutterfly.FlyAPI do

  alias Clutterfly.Validate
  require Logger

  @moduledoc """
  Client for interacting with the Fly.io Machines API.

  The initial version of this was generated entirely in a chat with
  Claude Sonnet 3.7 on March 7 2025, based on today's Fly Machines
  spec.json OpenAPI spec file. !

  This module provides a comprehensive interface to the Fly.io Machines API,
  allowing you to manage apps, machines, volumes, and other resources.

  ## Usage

  ```elixir
  # Create a client
  client = FlyAPI.new("your_api_token")

  # List apps
  {:ok, %{body: apps}} = FlyAPI.list_apps(client, "your_org_slug")

  # Get a specific machine
  {:ok, %{body: machine}} = FlyAPI.get_machine(client, "your_app_name", "machine_id")

  # Destroy a machine
  {:ok, _} = FlyAPI.destroy_machine(client, "your_app_name", "machine_id", true)
  ```
  """

  @base_url "https://api.machines.dev/v1"

  # Settings not specific to the request
  @type client :: %{
    base_url: String.t(),
    api_token: String.t(),
    app_name: String.t(),
    req_opts: keyword()
  }

  @type response :: {:ok, map()} | {:error, term()}

  @doc """
  Creates a new API client struct to provide Req options not specific to an endpoint.

  ## Parameters

    * `api_token` - The Fly.io API token to use. Defaults to the `:api_token` Clutterfly config value. Use the smallest-scoped token that'll do what you need.
    * `base_url` - Base URL for the API. Defaults to "https://api.machines.dev/v1".
    * `opts` - A keyword list of other Req options to use when making a request

  ## Examples

      iex> client = FlyAPI.new("your_api_token")
      %{base_url: "https://api.machines.dev/v1", api_token: "your_api_token"}

  """
  @spec new(opts :: keyword()) :: client()
  def new(opts \\ []) do
    %{
      base_url: Keyword.get(opts, :base_url, @base_url),
      api_token: Keyword.get(opts, :api_token, System.fetch_env!("FLY_API_TOKEN")),
      app_name: Keyword.get(opts, :app_name, nil),
      req_opts: Keyword.drop(opts, [:base_url, :api_token, :app_name])
    }
  end

  @doc """
  Helper for making authenticated requests with consistent error handling.

  You can pass options to Req, like retry:

  FlyAPI.destroy_machine(client, "app", "machine_id", retry: [delay: 500, max_retries: 3])
  """
  @spec request(client(), method :: atom(), path :: String.t(), opts :: keyword()) :: response()
  def request(client, method, path, opts \\ []) do
    req_opts = [
      method: method,
      url: "#{client.base_url}#{path}",
      auth: {:bearer, client.api_token},
      # receive_timeout: Keyword.get(opts, :timeout, 30_000),
      json: Keyword.get(opts, :body),
      params: Keyword.get(opts, :params, [])
    ]

    # Add any Req options specified in the client struct
    req_opts = Keyword.merge(req_opts, client.req_opts)

    Req.request(req_opts)
    # |> IO.inspect(label: "Req.request returned this")
    |> handle_response()
  end

  # Making these public so jello can compile
  def handle_response({:ok, %{status: status}} = response) when status in 200..299 do
    response
  end

  # TODO: test what timeouts look like and adjust.
  # Can add Req retry options to the client struct.
  def handle_response({_, %{status: 408}} = response) do
    Logger.info("408: timeout")
    response
  end

  def handle_response({:ok, %Req.Response{status: status, body: %{"error" => message}}}) do
    {:error, %{status: status, message: message}}
  end

  def handle_response({:error, _} = error) do
    error
  end

  #
  # Apps Resource
  #

  @doc """
  List all apps with the ability to filter by organization slug.

  ## Parameters

    * `client` - FlyAPI client struct
    * `org_slug` - The org slug, or 'personal', to filter apps

  ## Examples

      iex> client = Clutterfly.FlyAPI.new
      iex> Clutterfly.FlyAPI.list_apps(client, "personal")
  """
  @spec list_apps(client(), org_slug :: String.t()) :: response()
  def list_apps(client, org_slug) do
    request(client, :get, "/apps", params: [org_slug: org_slug])
  end

  @doc """
  Retrieve details about a specific app by its name.

  ## Parameters

    * `client` - FlyAPI client struct
    * `app_name` - The name of the app

  ## Examples

      iex> FlyAPI.get_app(client, "my-app")
  """
  @spec get_app(client(), app_name :: String.t()) :: response()
  def get_app(client, app_name) do
    request(client, :get, "/apps/#{app_name}")
  end


  @doc """
  Create an app with the specified details.

  ## Parameters

    * `client` - FlyAPI client
    * `params` - App parameters, may include:
      * `app_name` - The name of the app
      * `org_slug` - The organization slug
      * `network` - The network name
      * `enable_subdomains` - Whether to enable subdomains

  ## Examples

      iex> params = %{app_name: "my-new-app", org_slug: "personal"}
      iex> FlyAPI.create_app(client, params)
      {:ok, %{status: 201}}
  """
  @spec create_app(client(), params :: map()) :: response()
  def create_app(client, params) do
    request(client, :post, "/apps", body: params)
  end


  @doc """
  List all Machines associated with a specific app.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `opts` - Optional parameters:
      * `include_deleted` - Include deleted machines
      * `region` - Filter by region
      * `state` - Comma separated list of states to filter (created, started, stopped, suspended)
      * `summary` - Only return summary info about machines

  ## Examples

      iex> Clutterfly.FlyAPI.list_machines(client, "my-app")

      iex> Clutterfly.FlyAPI.list_machines(client, "my-app", region: "dfw", state: "started")

      iex> Clutterfly.FlyAPI.list_machines(client, "my-app", region: "yyz", state: "stopped", summary: true)
  """
  @spec list_machines(client(), app_name :: String.t(), opts :: keyword()) :: response()
  def list_machines(client, app_name, opts \\ []) do
    request(client, :get, "/apps/#{app_name}/machines", params: opts)
  end

  @doc """
  Get details of a specific Machine within an app by the Machine ID.

  ## Parameters

    * `client` - FlyAPI client struct
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine

  ## Examples

      iex> FlyAPI.get_machine(client, "my-app", "machine-id")
  """
  @spec get_machine(client(), app_name :: String.t(), machine_id :: String.t()) :: response()
  def get_machine(client, app_name, machine_id) do
    request(client, :get, "/apps/#{app_name}/machines/#{machine_id}")
  end

  @doc """
  Create a Machine within a specific app.

  ## Parameters

    * `client` - FlyAPI client struct
    * `app_name` - The name of the app
    * `params` - Machine parameters, may include:
      * `name` - Unique name for this Machine (optional)
      * `config` - An object defining the Machine configuration
      * `region` - The target region (optional)
      * and other parameters as per the API spec

  ## Examples

      iex> params = %{
      ...>   config: %{
      ...>     image: "flyio/fastify-functions",
      ...>     env: %{"APP_ENV" => "production"}
      ...>   },
      ...>   region: "dfw"
      ...> }
      iex> FlyAPI.create_machine(client, "my-app", params)
  """
  @spec create_machine(client(), app_name :: String.t(), params :: map()) :: response()
  def create_machine(client, app_name, params) do
    with {:ok, req_body} <- Validate.validate_body(params, Clutterfly.FlySchemas.CreateMachineRequest) do
      request(client, :post, "/apps/#{app_name}/machines", body: req_body)
    end
  end

  @doc """
  Delete a specific Machine within an app.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine to delete
    * `force` - Whether to force kill the machine if it's running (default: false)

  ## Examples

      iex> FlyAPI.destroy_machine(client, "my-app", "machine-id")
      {:ok, %{status: 200}}

      iex> FlyAPI.destroy_machine(client, "my-app", "machine-id", true)
      {:ok, %{status: 200}}
  """
  @spec destroy_machine(client(), app_name :: String.t(), machine_id :: String.t(), force :: boolean()) :: response()
  def destroy_machine(client, app_name, machine_id, force \\ false) do
    params = if force, do: [force: true], else: []
    request(client, :delete, "/apps/#{app_name}/machines/#{machine_id}", params: params)
  end

  @doc """
  Stop a specific Machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine
    * `params` - Optional parameters:
      * `signal` - Signal to send (default: "SIGTERM")
      * `timeout` - Timeout before force kill

  ## Examples

      iex> FlyAPI.stop_machine(client, "my-app", "machine-id")
      {:ok, %{status: 200}}

      iex> FlyAPI.stop_machine(client, "my-app", "machine-id", %{signal: "SIGINT", timeout: "30s"})
      {:ok, %{status: 200}}
  """
  @spec stop_machine(client(), app_name :: String.t(), machine_id :: String.t(), params :: map()) :: response()
  def stop_machine(client, app_name, machine_id, params \\ %{}) do
    request(client, :post, "/apps/#{app_name}/machines/#{machine_id}/stop", body: params)
  end

  @doc """
  Wait for a Machine to reach a specific state.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine
    * `opts` - Optional parameters:
      * `instance_id` - 26-character Machine version ID.  Required when waiting for Machine to be in stopped state.
      * `timeout` - Wait timeout in seconds (default: 60)
      * `state` - Desired state (default: "started")

  ## Examples

      iex> FlyAPI.wait_for_machine(client, "my-app", "machine-id")
      {:ok, %{status: 200}}

      iex> FlyAPI.wait_for_machine(client, "my-app", "machine-id", state: "stopped", timeout: 120)
      {:ok, %{status: 200}}
  """
  @spec wait_for_machine(client(), app_name :: String.t(), machine_id :: String.t(), opts :: keyword()) :: response()
  def wait_for_machine(client, app_name, machine_id, opts \\ []) do
    request(client, :get, "/apps/#{app_name}/machines/#{machine_id}/wait", params: opts)
  end

  @doc """
  Cordon a Machine (disable its services).

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine to cordon

  ## Examples

      iex> FlyAPI.cordon_machine(client, "my-app", "machine-id")
      {:ok, %{status: 200}}
  """
  @spec cordon_machine(client(), app_name :: String.t(), machine_id :: String.t()) :: response()
  def cordon_machine(client, app_name, machine_id) do
    request(client, :post, "/apps/#{app_name}/machines/#{machine_id}/cordon")
  end


end
