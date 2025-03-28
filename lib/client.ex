defmodule Clutterfly.Client do
  defstruct base_url: "", api_token: "", app_name: "", req_opts: []

  @type t :: %__MODULE__{
    base_url: String.t(),
    api_token: String.t(),
    app_name: String.t(),
    req_opts: keyword()
  }
end
