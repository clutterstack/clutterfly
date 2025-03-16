defmodule ScratchpadModule do
  #
  # Apps Resource
  #

  @doc """
  List all apps with the ability to filter by organization slug.

  ## Parameters

    * `client` - FlyAPI client
    * `org_slug` - The org slug, or 'personal', to filter apps

  ## Examples

      iex> FlyAPI.list_apps(client, "personal")
      {:ok, %{body: %{"apps" => [...], "total_apps" => 5}}}
  """
  @spec list_apps(client(), org_slug :: String.t()) :: response()
  def list_apps(client \\ @defaults org_slug) do
    request(client, :get, "/apps", params: [org_slug: org_slug])
  end

  @doc """
  Retrieve details about a specific app by its name.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app

  ## Examples

      iex> FlyAPI.get_app(client, "my-app")
      {:ok, %{body: %{"id" => "...", "name" => "my-app", ...}}}
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
  Delete an app by its name.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app to delete

  ## Examples

      iex> FlyAPI.delete_app(client, "my-app")
      {:ok, %{status: 202}}
  """
  @spec delete_app(client(), app_name :: String.t()) :: response()
  def delete_app(client, app_name) do
    request(client, :delete, "/apps/#{app_name}")
  end


  #
  # Machines Resource
  #

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

      iex> FlyAPI.list_machines(client, "my-app")
      {:ok, %{body: [%{"id" => "...", "name" => "..."}]}}

      iex> FlyAPI.list_machines(client, "my-app", region: "dfw", state: "started")
      {:ok, %{body: [%{"id" => "...", "state" => "started"}]}}
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
      {:ok, %{body: %{"id" => "machine-id", "name" => "..."}}}
  """
  @spec get_machine(client(), app_name :: String.t(), machine_id :: String.t()) :: response()
  def get_machine(client, app_name, machine_id) do
    request(client, :get, "/apps/#{app_name}/machines/#{machine_id}")
  end

  @doc """
  Create a Machine within a specific app.

  ## Parameters

    * `client` - FlyAPI client
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
      {:ok, %{body: %{"id" => "new-machine-id", ...}}}
  """
  @spec create_machine(client(), app_name :: String.t(), params :: map()) :: response()
  def create_machine(client, app_name, params) do
    request(client, :post, "/apps/#{app_name}/machines", body: params)
  end

  @doc """
  Update a Machine's configuration.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine to update
    * `params` - Updated machine parameters

  ## Examples

      iex> params = %{
      ...>   config: %{
      ...>     env: %{"APP_ENV" => "staging"}
      ...>   }
      ...> }
      iex> FlyAPI.update_machine(client, "my-app", "machine-id", params)
      {:ok, %{body: %{"id" => "machine-id", ...}}}
  """
  @spec update_machine(client(), app_name :: String.t(), machine_id :: String.t(), params :: map()) :: response()
  def update_machine(client, app_name, machine_id, params) do
    request(client, :post, "/apps/#{app_name}/machines/#{machine_id}", body: params)
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

  @doc """
  List all events associated with a specific Machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine

  ## Examples

      iex> FlyAPI.list_machine_events(client, "my-app", "machine-id")
      {:ok, %{body: [%{"id" => "...", "type" => "start"}]}}
  """
  @spec list_machine_events(client(), app_name :: String.t(), machine_id :: String.t()) :: response()
  def list_machine_events(client, app_name, machine_id) do
    request(client, :get, "/apps/#{app_name}/machines/#{machine_id}/events")
  end

  @doc """
  Execute a command on a specific Machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine
    * `command_params` - Command execution parameters:
      * `command` - The command to run as an array of strings
      * `stdin` - Optional input to provide to the command
      * `timeout` - Optional timeout in seconds

  ## Examples

      iex> command_params = %{
      ...>   command: ["echo", "hello world"]
      ...> }
      iex> FlyAPI.exec_command(client, "my-app", "machine-id", command_params)
      {:ok, %{body: %{"stdout" => "hello world\n", "exit_code" => 0}}}
  """
  @spec exec_command(client(), app_name :: String.t(), machine_id :: String.t(), command_params :: map()) :: response()
  def exec_command(client, app_name, machine_id, command_params) do
    request(client, :post, "/apps/#{app_name}/machines/#{machine_id}/exec", body: command_params)
  end

  @doc """
  Retrieve the current lease of a specific Machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine

  ## Examples

      iex> FlyAPI.get_machine_lease(client, "my-app", "machine-id")
      {:ok, %{body: %{"nonce" => "...", "owner" => "..."}}}
  """
  @spec get_machine_lease(client(), app_name :: String.t(), machine_id :: String.t()) :: response()
  def get_machine_lease(client, app_name, machine_id) do
    request(client, :get, "/apps/#{app_name}/machines/#{machine_id}/lease")
  end

  @doc """
  Create a lease for a specific Machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine
    * `params` - Lease parameters:
      * `ttl` - Time to live in seconds
      * `description` - Description of the lease
    * `nonce` - Optional existing lease nonce to refresh

  ## Examples

      iex> params = %{ttl: 3600, description: "Development lease"}
      iex> FlyAPI.create_machine_lease(client, "my-app", "machine-id", params)
      {:ok, %{body: %{"nonce" => "...", "expires_at" => ...}}}
  """
  @spec create_machine_lease(client(), app_name :: String.t(), machine_id :: String.t(), params :: map(), nonce :: String.t() | nil) :: response()
  def create_machine_lease(client, app_name, machine_id, params, nonce \\ nil) do
    headers = if nonce, do: [{"fly-machine-lease-nonce", nonce}], else: []

    Req.request(
      method: :post,
      url: "#{client.base_url}/apps/#{app_name}/machines/#{machine_id}/lease",
      auth: {:bearer, client.api_token},
      headers: headers,
      json: params
    )
    |> handle_response()
  end

  @doc """
  Release the lease of a specific Machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine
    * `nonce` - The lease nonce to release

  ## Examples

      iex> FlyAPI.release_machine_lease(client, "my-app", "machine-id", "lease-nonce")
      {:ok, %{status: 200}}
  """
  @spec release_machine_lease(client(), app_name :: String.t(), machine_id :: String.t(), nonce :: String.t()) :: response()
  def release_machine_lease(client, app_name, machine_id, nonce) do
    Req.request(
      method: :delete,
      url: "#{client.base_url}/apps/#{app_name}/machines/#{machine_id}/lease",
      auth: {:bearer, client.api_token},
      headers: [{"fly-machine-lease-nonce", nonce}]
    )
    |> handle_response()
  end

  @doc """
  Retrieve metadata for a specific Machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine

  ## Examples

      iex> FlyAPI.get_machine_metadata(client, "my-app", "machine-id")
      {:ok, %{body: %{"key1" => "value1", "key2" => "value2"}}}
  """
  @spec get_machine_metadata(client(), app_name :: String.t(), machine_id :: String.t()) :: response()
  def get_machine_metadata(client, app_name, machine_id) do
    request(client, :get, "/apps/#{app_name}/machines/#{machine_id}/metadata")
  end

  @doc """
  Update metadata for a specific machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine
    * `key` - The metadata key
    * `value` - The metadata value

  ## Examples

      iex> FlyAPI.update_machine_metadata(client, "my-app", "machine-id", "environment", "production")
      {:ok, %{status: 204}}
  """
  @spec update_machine_metadata(client(), app_name :: String.t(), machine_id :: String.t(), key :: String.t(), value :: String.t()) :: response()
  def update_machine_metadata(client, app_name, machine_id, key, value) do
    request(client, :post, "/apps/#{app_name}/machines/#{machine_id}/metadata/#{key}", body: value)
  end

  @doc """
  Delete metadata for a specific Machine by key.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine
    * `key` - The metadata key to delete

  ## Examples

      iex> FlyAPI.delete_machine_metadata(client, "my-app", "machine-id", "environment")
      {:ok, %{status: 204}}
  """
  @spec delete_machine_metadata(client(), app_name :: String.t(), machine_id :: String.t(), key :: String.t()) :: response()
  def delete_machine_metadata(client, app_name, machine_id, key) do
    request(client, :delete, "/apps/#{app_name}/machines/#{machine_id}/metadata/#{key}")
  end

  @doc """
  List all processes running on a specific Machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine
    * `opts` - Optional parameters:
      * `sort_by` - Field to sort by
      * `order` - Sort order

  ## Examples

      iex> FlyAPI.list_machine_processes(client, "my-app", "machine-id")
      {:ok, %{body: [%{"pid" => 1, "command" => "/bin/bash"}]}}

      iex> FlyAPI.list_machine_processes(client, "my-app", "machine-id", sort_by: "cpu", order: "desc")
      {:ok, %{body: [%{"pid" => 123, "cpu" => 95}]}}
  """
  @spec list_machine_processes(client(), app_name :: String.t(), machine_id :: String.t(), opts :: keyword()) :: response()
  def list_machine_processes(client, app_name, machine_id, opts \\ []) do
    request(client, :get, "/apps/#{app_name}/machines/#{machine_id}/ps", params: opts)
  end

  @doc """
  Restart a specific Machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine
    * `opts` - Optional parameters:
      * `timeout` - Restart timeout as a Go duration string or number of seconds
      * `signal` - Unix signal name

  ## Examples

      iex> FlyAPI.restart_machine(client, "my-app", "machine-id")
      {:ok, %{status: 200}}

      iex> FlyAPI.restart_machine(client, "my-app", "machine-id", timeout: "10s", signal: "SIGTERM")
      {:ok, %{status: 200}}
  """
  @spec restart_machine(client(), app_name :: String.t(), machine_id :: String.t(), opts :: keyword()) :: response()
  def restart_machine(client, app_name, machine_id, opts \\ []) do
    request(client, :post, "/apps/#{app_name}/machines/#{machine_id}/restart", params: opts)
  end

  @doc """
  Send a signal to a specific Machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine
    * `signal` - The signal to send (e.g., "SIGTERM", "SIGKILL")

  ## Examples

      iex> FlyAPI.signal_machine(client, "my-app", "machine-id", "SIGTERM")
      {:ok, %{status: 200}}
  """
  @spec signal_machine(client(), app_name :: String.t(), machine_id :: String.t(), signal :: String.t()) :: response()
  def signal_machine(client, app_name, machine_id, signal) do
    request(client, :post, "/apps/#{app_name}/machines/#{machine_id}/signal", body: %{signal: signal})
  end

  @doc """
  Start a specific Machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine

  ## Examples

      iex> FlyAPI.start_machine(client, "my-app", "machine-id")
      {:ok, %{status: 200}}
  """
  @spec start_machine(client(), app_name :: String.t(), machine_id :: String.t()) :: response()
  def start_machine(client, app_name, machine_id) do
    request(client, :post, "/apps/#{app_name}/machines/#{machine_id}/start")
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
  Suspend a specific Machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine

  ## Examples

      iex> FlyAPI.suspend_machine(client, "my-app", "machine-id")
      {:ok, %{status: 200}}
  """
  @spec suspend_machine(client(), app_name :: String.t(), machine_id :: String.t()) :: response()
  def suspend_machine(client, app_name, machine_id) do
    request(client, :post, "/apps/#{app_name}/machines/#{machine_id}/suspend")
  end

  @doc """
  Uncordon a Machine (enable its services).

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine

  ## Examples

      iex> FlyAPI.uncordon_machine(client, "my-app", "machine-id")
      {:ok, %{status: 200}}
  """
  @spec uncordon_machine(client(), app_name :: String.t(), machine_id :: String.t()) :: response()
  def uncordon_machine(client, app_name, machine_id) do
    request(client, :post, "/apps/#{app_name}/machines/#{machine_id}/uncordon")
  end

  @doc """
  List all versions of the configuration for a specific Machine.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine

  ## Examples

      iex> FlyAPI.list_machine_versions(client, "my-app", "machine-id")
      {:ok, %{body: [%{"version" => "v1", "user_config" => %{...}}]}}
  """
  @spec list_machine_versions(client(), app_name :: String.t(), machine_id :: String.t()) :: response()
  def list_machine_versions(client, app_name, machine_id) do
    request(client, :get, "/apps/#{app_name}/machines/#{machine_id}/versions")
  end

  @doc """
  Wait for a Machine to reach a specific state.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `machine_id` - The ID of the machine
    * `opts` - Optional parameters:
      * `instance_id` - 26-character Machine version ID
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

  #
  # Secrets Resource
  #

  @doc """
  List all secrets for an app.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app

  ## Examples

      iex> FlyAPI.list_secrets(client, "my-app")
      {:ok, %{body: [%{"label" => "DATABASE_URL", "type" => "encrypted"}]}}
  """
  @spec list_secrets(client(), app_name :: String.t()) :: response()
  def list_secrets(client, app_name) do
    request(client, :get, "/apps/#{app_name}/secrets")
  end

  @doc """
  Create a secret for an app.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `secret_label` - The secret label
    * `secret_type` - The secret type
    * `value` - The secret value (as a byte array or base64 encoded string)

  ## Examples

      iex> FlyAPI.create_secret(client, "my-app", "API_KEY", "encrypted", "my-secret-value")
      {:ok, %{status: 201}}
  """
  @spec create_secret(client(), app_name :: String.t(), secret_label :: String.t(), secret_type :: String.t(), value :: binary() | String.t()) :: response()
  def create_secret(client, app_name, secret_label, secret_type, value) do
    # Convert string to byte array if needed
    bytes = if is_binary(value), do: :binary.bin_to_list(value), else: value

    request(client, :post, "/apps/#{app_name}/secrets/#{secret_label}/type/#{secret_type}",
      body: %{value: bytes}
    )
  end

  @doc """
  Generate a secret for an app.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `secret_label` - The secret label
    * `secret_type` - The secret type

  ## Examples

      iex> FlyAPI.generate_secret(client, "my-app", "SESSION_KEY", "encrypted")
      {:ok, %{status: 201}}
  """
  @spec generate_secret(client(), app_name :: String.t(), secret_label :: String.t(), secret_type :: String.t()) :: response()
  def generate_secret(client, app_name, secret_label, secret_type) do
    request(client, :post, "/apps/#{app_name}/secrets/#{secret_label}/type/#{secret_type}/generate")
  end

  @doc """
  Delete a secret from an app.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `secret_label` - The secret label to delete

  ## Examples

      iex> FlyAPI.delete_secret(client, "my-app", "API_KEY")
      {:ok, %{status: 200}}
  """
  @spec delete_secret(client(), app_name :: String.t(), secret_label :: String.t()) :: response()
  def delete_secret(client, app_name, secret_label) do
    request(client, :delete, "/apps/#{app_name}/secrets/#{secret_label}")
  end

  #
  # Volumes Resource
  #

  @doc """
  List all volumes associated with a specific app.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `summary` - Optional boolean to return only summary info (default: false)

  ## Examples

      iex> FlyAPI.list_volumes(client, "my-app")
      {:ok, %{body: [%{"id" => "vol_123", "name" => "data", "size_gb" => 10}]}}

      iex> FlyAPI.list_volumes(client, "my-app", summary: true)
      {:ok, %{body: [%{"id" => "vol_123", "name" => "data"}]}}
  """
  @spec list_volumes(client(), app_name :: String.t(), opts :: keyword()) :: response()
  def list_volumes(client, app_name, opts \\ []) do
    request(client, :get, "/apps/#{app_name}/volumes", params: opts)
  end

  @doc """
  Create a volume for a specific app.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `params` - Volume parameters:
      * `name` - The name of the volume
      * `size_gb` - The size in GB
      * `region` - The region to create the volume in
      * `encrypted` - Whether the volume should be encrypted
      * And other parameters per the API spec

  ## Examples

      iex> params = %{
      ...>   name: "data",
      ...>   size_gb: 10,
      ...>   region: "dfw",
      ...>   encrypted: true
      ...> }
      iex> FlyAPI.create_volume(client, "my-app", params)
      {:ok, %{body: %{"id" => "vol_123", "name" => "data", "size_gb" => 10}}}
  """
  @spec create_volume(client(), app_name :: String.t(), params :: map()) :: response()
  def create_volume(client, app_name, params) do
    request(client, :post, "/apps/#{app_name}/volumes", body: params)
  end

  @doc """
  Retrieve details about a specific volume by its ID.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `volume_id` - The ID of the volume

  ## Examples

      iex> FlyAPI.get_volume(client, "my-app", "vol_123")
      {:ok, %{body: %{"id" => "vol_123", "name" => "data", "size_gb" => 10}}}
  """
  @spec get_volume(client(), app_name :: String.t(), volume_id :: String.t()) :: response()
  def get_volume(client, app_name, volume_id) do
    request(client, :get, "/apps/#{app_name}/volumes/#{volume_id}")
  end

  @doc """
  Update a volume's configuration.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `volume_id` - The ID of the volume
    * `params` - Update parameters:
      * `auto_backup_enabled` - Enable automatic backups
      * `snapshot_retention` - Number of snapshots to retain

  ## Examples

      iex> params = %{auto_backup_enabled: true, snapshot_retention: 7}
      iex> FlyAPI.update_volume(client, "my-app", "vol_123", params)
      {:ok, %{body: %{"id" => "vol_123", "auto_backup_enabled" => true}}}
  """
  @spec update_volume(client(), app_name :: String.t(), volume_id :: String.t(), params :: map()) :: response()
  def update_volume(client, app_name, volume_id, params) do
    request(client, :put, "/apps/#{app_name}/volumes/#{volume_id}", body: params)
  end

  @doc """
  Delete a specific volume within an app.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `volume_id` - The ID of the volume to delete

  ## Examples

      iex> FlyAPI.delete_volume(client, "my-app", "vol_123")
      {:ok, %{status: 200, body: %{}}}
  """
  @spec delete_volume(client(), app_name :: String.t(), volume_id :: String.t()) :: response()
  def delete_volume(client, app_name, volume_id) do
    request(client, :delete, "/apps/#{app_name}/volumes/#{volume_id}")
  end

  @doc """
  Extend a volume's size within an app.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `volume_id` - The ID of the volume
    * `size_gb` - The new size in GB

  ## Examples

      iex> FlyAPI.extend_volume(client, "my-app", "vol_123", 20)
      {:ok, %{body: %{"volume" => %{"id" => "vol_123", "size_gb" => 20}, "needs_restart" => true}}}
  """
  @spec extend_volume(client(), app_name :: String.t(), volume_id :: String.t(), size_gb :: integer()) :: response()
  def extend_volume(client, app_name, volume_id, size_gb) do
    request(client, :put, "/apps/#{app_name}/volumes/#{volume_id}/extend", body: %{size_gb: size_gb})
  end

  @doc """
  List all snapshots for a specific volume.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `volume_id` - The ID of the volume

  ## Examples

      iex> FlyAPI.list_volume_snapshots(client, "my-app", "vol_123")
      {:ok, %{body: [%{"id" => "snap_123", "created_at" => "2023-01-01T12:00:00Z"}]}}
  """
  @spec list_volume_snapshots(client(), app_name :: String.t(), volume_id :: String.t()) :: response()
  def list_volume_snapshots(client, app_name, volume_id) do
    request(client, :get, "/apps/#{app_name}/volumes/#{volume_id}/snapshots")
  end

  @doc """
  Create a snapshot for a specific volume.

  ## Parameters

    * `client` - FlyAPI client
    * `app_name` - The name of the app
    * `volume_id` - The ID of the volume

  ## Examples

      iex> FlyAPI.create_volume_snapshot(client, "my-app", "vol_123")
      {:ok, %{status: 200}}
  """
  @spec create_volume_snapshot(client(), app_name :: String.t(), volume_id :: String.t()) :: response()
  def create_volume_snapshot(client, app_name, volume_id) do
    request(client, :post, "/apps/#{app_name}/volumes/#{volume_id}/snapshots")
  end

  #
  # Tokens Resource
  #

  @doc """
  Request a Petsem token for accessing KMS.

  ## Parameters

    * `client` - FlyAPI client

  ## Examples

      iex> FlyAPI.request_kms_token(client)
      {:ok, %{body: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."}}
  """
  @spec request_kms_token(client()) :: response()
  def request_kms_token(client) do
    request(client, :post, "/tokens/kms")
  end

  @doc """
  Request an OIDC token.

  ## Parameters

    * `client` - FlyAPI client
    * `params` - Token parameters:
      * `aud` - The audience claim
      * `aws_principal_tags` - Whether to include AWS principal tags

  ## Examples

      iex> params = %{aud: "https://fly.io/org-slug"}
      iex> FlyAPI.request_oidc_token(client, params)
      {:ok, %{body: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."}}
  """
  @spec request_oidc_token(client(), params :: map()) :: response()
  def request_oidc_token(client, params) do
    request(client, :post, "/tokens/oidc", body: params)
  end
end
