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
end
