defmodule Alice.Toys.Eval do
  use Alice.Toy

  state _ do
    %{
      command: "%{a: 42}",
      result: "result"
    }
  end

  interaction :run_command, :command, [%{key: key(:enter)}], state do
    result =
      try do
        {result, _binding} = Code.eval_string(state[:command])
        result
      rescue
        exception ->
          exception
      end

    Map.put(state, :result, result |> inspect())
  end

  interaction :delete_char, :state, [%{key: key(:backspace)}, %{key: key(:backspace2)}], state do
    index = String.length(state[:command]) - 2
    command = if index < 0, do: "", else: String.slice(state[:command], 0..index)

    Map.put(state, :command, command)
  end

  default_interaction state, event do
    case event do
      %{ch: 0, key: 32} ->
        Map.put(state, :command, state[:command] <> " ")

      %{ch: char} ->
        Map.put(state, :command, state[:command] <> <<char::utf8>>)

      _ ->
        state
    end
  end

  render state, _context do
    viewport(offset_y: 0) do
      label(content: "Command:")
      label(content: state[:command])
      label(content: "Result:")
      label(content: state[:result])
    end
  end
end
