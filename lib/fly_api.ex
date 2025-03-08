defmodule Clutterfly.FlyAPI do
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
    req_opts: List.t()
  }

  @type response :: {:ok, map()} | {:error, term()}

  @doc """
  Creates a new API client struct.

  ## Parameters

    * `api_token` - Your Fly API token
    * `base_url` - Optional base URL for the API (defaults to "https://api.machines.dev/v1")

  ## Examples

      iex> client = FlyAPI.new("your_api_token")
      %{base_url: "https://api.machines.dev/v1", api_token: "your_api_token"}

  """
  @spec new(api_token :: String.t(), base_url :: String.t(), req_opts :: keyword()) :: client()
  def new(api_token \\ Application.get_env(:clutterfly, :api_token), base_url \\ @base_url, opts \\ []) do
    %{
      base_url: base_url,
      api_token: api_token,
      req_opts: opts
    }
  end

  @doc """
  Helper for making authenticated requests with consistent error handling.

  You can pass options to Req, like retry:

  FlyAPI.destroy_machine(client, "app", "machine_id", retry: [delay: 500, max_retries: 3])
  """
  @spec request(client(), method :: atom(), path :: String.t(), opts :: keyword()) :: response()
  def request(client, method, path, opts \\ []) do
    opts |> dbg
    req_opts = [
      method: method,
      url: "#{client.base_url}#{path}",
      auth: {:bearer, client.api_token},
      receive_timeout: Keyword.get(opts, :timeout, 30_000),
      json: Keyword.get(opts, :body),
      params: Keyword.get(opts, :params, []),
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

  def handle_response({:ok, %Req.Response{status: status, body: %{"error" => message}}}) do
    {:error, "#{status}: #{message}"}
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

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine

  ## Examples

      iex> FlyAPI.get_machine(client, "my-app", "machine-id")
  """
  @spec get_machine(client(), app_name :: String.t(), machine_id :: String.t()) :: response()
  def get_machine(client, app_name, machine_id) do
    request(client, :get, "/apps/#{app_name}/machines/#{machine_id}")
  end
end
