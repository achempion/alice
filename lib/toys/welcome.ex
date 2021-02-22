defmodule Alice.Toys.Welcome do
  use Alice.Toy

  state _ do
    %{
      text: "Welcome to the alice editor!"
    }
  end

  interaction :insert_hi, :state, [%{ch: ?i}], state do
    Map.put(state, :text, state[:text] <> " hi")
  end

  interaction :open_file_finder, :pane, [%{ch: ?o}], _state do
    {Alice.Toys.FileFinder, %{}}
  end

  interaction :close, :close, [%{ch: ?q}], _state do
    self()
  end

  default_interaction state, _event do
    # @pane_file_finder ->
    #   init_module(Alice.FileFinder) |> open_pane(model)

    #   @pane_opened_modules ->
    #     init_module(Alice.OpenedModules, %{list: model[:modules] |> Map.to_list()})
    #     |> open_pane(model)

    #   @recompile ->
    #     IEx.Helpers.recompile()
    #     model

    state
  end

  render state do
    label(content: state[:text])
  end
end
