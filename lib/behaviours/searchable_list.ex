defmodule Alice.Behaviours.SearchableList do
  use Alice.Behaviour

  @arrow_down %{key: key(:arrow_down)}

  def state(list) do
    %{
      index: 0,
      list: list
    }
  end

  def interaction(state, key, @arrow_down) do
    local = state[key]

    Map.put(state, key, Map.put(local, :index, local[:index] + 1))
  end

  def interaction(state, _key, _event) do
    state
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
