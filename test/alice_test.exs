defmodule AliceTest do
  use ExUnit.Case
  doctest Alice

  test "greets the world" do
    assert Alice.hello() == :world
  end
end
