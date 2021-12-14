defmodule Alice.Toys.ActiveApplications do
  use Alice.Toy

  state _ do
    %{
      list: [],
      index: 0
    }
  end

  interaction :refresh, :state, [%{ch: ?g}], state do
    active_applications =
      DynamicSupervisor.which_children(Alice.ToysSupervisor)
      |> Enum.map(fn {_undefined, _pid, _worker, [module]} ->
        %{label: module |> to_string()}
      end)

    Map.put(state, :list, active_applications)
  end

  interaction :next, :state, [%{key: key(:arrow_down)}], state do
    Map.put(state, :index, state[:index] + 1)
  end

  interaction :prev, :state, [%{key: key(:arrow_up)}], state do
    Map.put(state, :index, state[:index] - 1)
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
