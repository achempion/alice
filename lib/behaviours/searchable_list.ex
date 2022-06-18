defmodule Alice.Behaviours.SearchableList do
  use Alice.Behaviour

  @spec state([String.t()]) :: map
  def state(list) do
    %{
      index: 0,
      list: list
    }
  end

  interaction :next, :state, [%{key: key(:arrow_down)}], state, key do
    local = state[key]
    Map.put(state, key, Map.put(local, :index, local[:index] + 1))
  end

  interaction :previous, :state, [%{key: key(:arrow_up)}], state, key do
    local = state[key]
    Map.put(state, key, Map.put(local, :index, local[:index] - 1))
  end

  def render(%{current_panel: %{height: height}}, state, key) do
    local = state[key]

    offset = local[:index] + 5 - height

    viewport(offset_y: if(offset < 0, do: 0, else: offset)) do
      [
        label(content: local[:list] |> Enum.at(local[:index]) || "none"),
        for {item, index} <- Enum.with_index(local[:list]) do
          if index == local[:index] do
            label(content: item, attributes: [:bold])
          else
            label(content: item)
          end
        end
      ]
    end
  end
end
