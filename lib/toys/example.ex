defmodule Alice.Toys.Example do
  use Alice.Toy

  state _ do
    %{
      text: """
      Simple toy
      """
    }
  end

  interaction :insert_hi, :state, [%{ch: ?i}], state do
    Map.put(state, :text, state[:text] <> " hi")
  end

  default_interaction state, _event do
    state
  end

  render state, _context do
    label(content: state[:text])
  end
end
