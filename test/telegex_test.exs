defmodule TelegexTest do
  use ExUnit.Case
  doctest Telegex

  test "keeps the legacy edit_message_text/2 overload" do
    assert function_exported?(Telegex, :edit_message_text, 2)
  end
end
