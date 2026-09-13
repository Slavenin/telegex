defmodule Telegex.Caller.Adapter.Capture do
  @behaviour Telegex.Caller

  @impl true
  def call(method, _params, opts) do
    Process.put(:captured_telegex_call, {method, opts})
    {:error, :captured}
  end
end

defmodule Telegex.MethodDefinerTest do
  use ExUnit.Case

  import Telegex.MethodDefiner

  test "include_attachment?/1" do
    assert include_attachment?(Telegex.Type.InputMediaAudio) == true

    type = %{
      __struct__: Telegex.TypeDefiner.UnionType,
      types: [
        %{__struct__: Telegex.TypeDefiner.ArrayType, elem_type: Telegex.Type.InputMediaAudio},
        %{
          __struct__: Telegex.TypeDefiner.ArrayType,
          elem_type: Telegex.Type.InputMediaDocument
        },
        %{__struct__: Telegex.TypeDefiner.ArrayType, elem_type: Telegex.Type.InputMediaPhoto},
        %{__struct__: Telegex.TypeDefiner.ArrayType, elem_type: Telegex.Type.InputMediaVideo}
      ]
    }

    assert include_attachment?(type) == true
    assert include_attachment?(Telegex.Type.InputRichMessage) == true
  end

  test "generated rich message method passes its nested attachment field to the adapter" do
    previous_adapter = Application.get_env(:telegex, :caller_adapter)

    on_exit(fn ->
      if previous_adapter do
        Application.put_env(:telegex, :caller_adapter, previous_adapter)
      else
        Application.delete_env(:telegex, :caller_adapter)
      end
    end)

    Application.put_env(:telegex, :caller_adapter, :Capture)

    rich_message = %Telegex.Type.InputRichMessage{
      blocks: [
        %Telegex.Type.InputRichBlockPhoto{
          type: "photo",
          photo: %Telegex.Type.InputMediaPhoto{type: "photo", media: "mix.exs"}
        }
      ]
    }

    assert {:error, :captured} = Telegex.send_rich_message(1, rich_message)
    assert {"sendRichMessage", opts} = Process.get(:captured_telegex_call)
    assert opts[:attachment_fields] == [:rich_message]
  end
end
