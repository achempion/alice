defmodule Alice.Toys.Launcher do
  @moduledoc """
  A module launch toys
  """
  use Alice.Toy

  alias Alice.Helpers.Toys

  state _ do
    list = Toys.list() |> Enum.map(fn toy -> %{label: to_string(toy)} end)
    %{
      index: 0,
      list: list
    }
  end

  default_interaction state, _event do
    state
  end

  render state, _context do
    viewport(offset_y: 0) do
      for {item, index} <- Enum.with_index(state[:list]) do
        if index == state[:index] do
          label(content: item[:label], attributes: [:bold])
        else
          label(content: item[:label])
        end
      end
    end
  end
end
