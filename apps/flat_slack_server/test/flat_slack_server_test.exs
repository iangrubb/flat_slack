defmodule FlatSlackServerTest do
  use ExUnit.Case
  doctest FlatSlackServer

  test "greets the world" do
    assert FlatSlackServer.hello() == :world
  end
end
