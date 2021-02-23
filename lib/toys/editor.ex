defmodule Alice.Toys.Editor do
  use Alice.Toy

  state %{path: path} do
    content = File.read!(path)

    %{
      path: path,
      content: content,
      content_lines: String.split(content, "\n"),
      cursor_position: %{x: 0, y: 0}
    }
  end

  interaction :move_right, :state, [%{key: key(:arrow_right)}], state do
    put_in(state, [:cursor_position, :x], state.cursor_position.x + 1)
  end

  interaction :move_left, :state, [%{key: key(:arrow_left)}], state do
    put_in(state, [:cursor_position, :x], state.cursor_position.x - 1)
  end

  interaction :move_up, :state, [%{key: key(:arrow_up)}], state do
    put_in(state, [:cursor_position, :y], state.cursor_position.y - 1)
  end

  interaction :move_down, :state, [%{key: key(:arrow_down)}], state do
    put_in(state, [:cursor_position, :y], state.cursor_position.y + 1)
  end

  interaction :close, :close, [%{key: key(:ctrl_w)}], state do
    self()
  end

  default_interaction state, _event do
    state
  end

  render state, context do
    viewport(offset_y: state.cursor_position.y) do
      state[:content_lines]
      |> Enum.with_index()
      |> Enum.map(fn {line, i} ->
        label do
          if state.cursor_position.y == i do
            {s_before, s_after} = String.split_at(line, state.cursor_position.x)

            {s_cursor, s_tail} =
              if s_after == "" do
                {" ", ""}
              else
                String.split_at(s_after, 1)
              end

            [
              text(content: s_before),
              text(content: s_cursor, color: :black, background: :white),
              text(content: s_tail)
            ]
          else
            text(content: line)
          end
        end
      end)
    end
  end
end
