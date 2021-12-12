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

  interaction :start_observer, :stat, [%{ch: ?s}], state do
    :observer.start()
    state
  end

  interaction :close, :close, [%{ch: ?q}], _state do
    self()
  end

  default_interaction state, _event do
    state
  end

  render state, _context do
    label(content: state[:text])
  end
end
