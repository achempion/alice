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
    next = local[:index] + 1

    if next < length(local[:list]) do
      Map.put(state, key, Map.put(local, :index, next))
    else
      state
    end
  end

  interaction :previous, :state, [%{key: key(:arrow_up)}], state, key do
    local = state[key]
    previous = local[:index] - 1

    if previous < 0, do: state, else: Map.put(state, key, Map.put(local, :index, previous))
  end

  def render(%{current_panel: %{height: height}}, state, key) do
    local = state[key]

    offset = local[:index] + 1 - 6

    [
      label(content: local[:list] |> Enum.at(local[:index]) || "none"),
      viewport(offset_y: if(offset < 0, do: 0, else: offset)) do
        [
          for {item, index} <- Enum.with_index(local[:list]) do
            if index == local[:index] do
              label(content: item, attributes: [:bold])
            else
              label(content: item)
            end
          end
        ]
      end
    ]
  end
end
