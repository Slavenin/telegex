defmodule Telegex.Caller.Adapter.HTTPoison do
  @moduledoc "HTTPoison based caller adapter."

  use Telegex.Caller.Adapter

  @type httposion_resp :: HTTPoison.Response.t()
  @type httposion_err :: %{reason: atom}

  @impl true
  def call(method, params, opts) do
    url = build_url(method)
    {body, headers} = build_request(params, opts)

    url |> request(body, headers) |> parse_response()
  end

  @doc false
  def build_request(params, opts) do
    attachment_fields = Keyword.get(opts, :attachment_fields, [])

    case Telegex.Caller.Adapter.Finch.build_multipart(params, attachment_fields) do
      :none ->
        {params |> Enum.into(%{}) |> Jason.encode!(), [@json_header]}

      {headers, body_stream} ->
        body = body_stream |> Enum.to_list() |> IO.iodata_to_binary()
        {body, headers}
    end
  end

  defp request(url, body, headers) do
    apply(HTTPoison, :post, [url, body, headers, options()])
  end

  @spec parse_response({:ok, httposion_resp} | {:error, httposion_err}) ::
          {:ok, any} | {:error, error}
  defp parse_response({:ok, %{body: body} = _response}) do
    %{ok: ok, result: result, error_code: error_code, description: description} =
      struct_response(body)

    if ok do
      {:ok, result}
    else
      {:error, %Error{error_code: error_code, description: description}}
    end
  end

  defp parse_response({:error, %{reason: reason} = _error}) do
    {:error, %RequestError{reason: reason}}
  end
end
