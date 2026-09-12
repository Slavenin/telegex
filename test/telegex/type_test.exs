defmodule Telegex.TypeTest do
  use ExUnit.Case

  test "attachment fields in struct type" do
    assert Telegex.Type.InputMediaPhoto.__attachments__() == [:media]
    assert Telegex.Type.InputMediaVideo.__attachments__() == [:media, :thumbnail, :cover]
    assert Telegex.Type.InputMediaAnimation.__attachments__() == [:media, :thumbnail]
    assert Telegex.Type.InputMediaAudio.__attachments__() == [:media, :thumbnail]
    assert Telegex.Type.InputMediaDocument.__attachments__() == [:media, :thumbnail]
  end

  test "attachment fields propagate through nested rich message types" do
    assert Keyword.has_key?(Telegex.Type.InputRichMessageMedia.__references__(), :media)
    assert Telegex.Type.InputRichBlockPhoto.__attachments__() == [:photo]
    assert Telegex.Type.InputRichMessage.__attachments__() == [:blocks, :media]
  end
end
