defmodule FlatSlackClientTest do
  use ExUnit.Case
  doctest FlatSlackClient

  test "greets the world" do
    assert FlatSlackClient.hello() == :world
  end
end
