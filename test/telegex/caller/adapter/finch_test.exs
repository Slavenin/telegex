defmodule Telegex.Caller.Adapter.FinchTest do
  use ExUnit.Case

  import Telegex.Caller.Adapter.Finch

  test "attach_param/4" do
    input_media = %Telegex.Type.InputMediaDocument{
      type: "document",
      media: "mix.exs",
      thumbnail: "mix.lock"
    }

    params = [media: [input_media]]

    {_multipart, params} = attach_param(:media, [input_media], Multipart.new(), params)

    assert params == [
             media: [
               %Telegex.Type.InputMediaDocument{
                 type: "document",
                 media: "attach://mix.exs",
                 thumbnail: "attach://mix.lock"
               }
             ]
           ]
  end

  test "attach_param/4 rewrites a photo nested in a rich message" do
    rich_message = %Telegex.Type.InputRichMessage{
      blocks: [
        %Telegex.Type.InputRichBlockPhoto{
          type: "photo",
          photo: %Telegex.Type.InputMediaPhoto{type: "photo", media: "mix.exs"}
        }
      ]
    }

    {_multipart, params} =
      attach_param(:rich_message, rich_message, Multipart.new(), rich_message: rich_message)

    assert [
             rich_message: %Telegex.Type.InputRichMessage{
               blocks: [
                 %Telegex.Type.InputRichBlockPhoto{
                   photo: %Telegex.Type.InputMediaPhoto{media: "attach://mix.exs"}
                 }
               ]
             }
           ] = params
  end

  test "HTTPoison adapter builds multipart requests for local files" do
    {body, headers} =
      Telegex.Caller.Adapter.HTTPoison.build_request(
        [chat_id: 1, photo: "mix.exs"],
        attachment_fields: [:photo]
      )

    assert {"Content-Type", content_type} = List.keyfind(headers, "Content-Type", 0)
    assert String.starts_with?(content_type, "multipart/form-data")
    assert body =~ ~s(name="photo")
    assert body =~ "attach://mix.exs"
    assert body =~ ~s(name="mix.exs"; filename="mix.exs")
  end

  test "HTTPoison adapter builds multipart requests for files nested in rich messages" do
    rich_message = %Telegex.Type.InputRichMessage{
      blocks: [
        %Telegex.Type.InputRichBlockPhoto{
          type: "photo",
          photo: %Telegex.Type.InputMediaPhoto{type: "photo", media: "mix.exs"}
        }
      ]
    }

    {body, headers} =
      Telegex.Caller.Adapter.HTTPoison.build_request(
        [chat_id: 1, rich_message: rich_message],
        attachment_fields: [:rich_message]
      )

    assert {"Content-Type", content_type} = List.keyfind(headers, "Content-Type", 0)
    assert String.starts_with?(content_type, "multipart/form-data")
    assert body =~ ~s(name="rich_message")
    assert body =~ "attach://mix.exs"
    assert body =~ ~s(name="mix.exs"; filename="mix.exs")
  end
end
