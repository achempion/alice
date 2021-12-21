defmodule Alice.Behaviours.SearchableList do
  use Alice.Behaviour

  def state(list) do
    %{
      index: 0,
      list: list
    }
  end

  def render(state, key) do
    local = state[key]

    viewport(offset_y: 0) do
      for {item, index} <- Enum.with_index(local[:list]) do
        if index == local[:index] do
          label(content: item, attributes: [:bold])
        else
          label(content: item)
        end
      end
    end
  end
end
