defmodule Alice.Editor do
  import Ratatouille.Constants, only: [key: 1]
  import Ratatouille.View

  @arrow_left key(:arrow_left)
  @arrow_right key(:arrow_right)
  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)
  @spacebar key(:space)
  @enter key(:enter)
  @delete_keys [
    key(:delete),
    key(:backspace),
    key(:backspace2)
  ]
  @ctrl_a key(:ctrl_a)
  @ctrl_e key(:ctrl_e)
  @alt_f %{ch: ?f, mod: 1}
  @alt_b %{ch: ?b, mod: 1}

  def init(%{path: path}) do
    ExTermbox.Constants.input_mode(:alt)
    |> ExTermbox.Bindings.select_input_mode()

    content = File.read!(path)

    %{
      path: path,
      content: content,
      content_lines: String.split(content, "\n"),
      cursor_position: %{
        x: 0,
        y: 0
      }
    }
  end

  def update(model, msg, state) do
    case msg do
      {:event, %{key: @arrow_right}} ->
        {:update_state, cursor_right(state)}

      {:event, %{key: @arrow_left}} ->
        {:update_state, cursor_left(state)}

      {:event, %{key: @arrow_up}} ->
        {:update_state, cursor_up(state)}

      {:event, %{key: @arrow_down}} ->
        {:update_state, cursor_down(state)}

      {:event, %{key: @ctrl_e}} ->
        {:update_state, cursor_end(state)}

      {:event, %{key: @ctrl_a}} ->
        {:update_state, cursor_start(state)}

      {:event, @alt_f} ->
        {:update_state, cursor_word_forward(state)}

      {:event, @alt_b} ->
        {:update_state, cursor_word_backward(state)}

      {:event, %{ch: char}} when char > 0 ->
        {:update_state, insert_char(state, <<char::utf8>>)}

      {:event, %{key: key}} when key in @delete_keys ->
        {:update_state, delete_char(state)}

      {:event, %{key: @spacebar}} ->
        {:update_state, insert_char(state, " ")}

      {:event, %{key: @enter}} ->
        {
          :update_state,
          insert_char(state, "\n")
          |> put_in([:cursor_position], %{x: 0, y: state[:cursor_position][:y] + 1})
        }

      _ ->
        :ok
    end
  end

  def delete_char(state) do
    current_line = Enum.at(state[:content_lines], state[:cursor_position][:y])

    {left, right} = String.split_at(current_line, state[:cursor_position][:x])

    lines =
      if String.length(left) == 0 && state[:cursor_position][:y] > 0 do
        y = state[:cursor_position][:y] - 1

        List.update_at(state[:content_lines], y, fn line -> line <> right end)
        |> List.replace_at(y + 1, nil)
      else
        result = String.slice(left, 0..-2) <> right
        result = if(result |> String.length() == 0, do: nil, else: result)

        List.replace_at(
          state[:content_lines],
          state[:cursor_position][:y],
          result
        )
      end
      |> Enum.reject(&is_nil/1)

    update_lines(state, lines)
    |> cursor_left()
  end

  def delete_last_char(state, y) do
    line = Enum.at(state[:content_lines], y) |> String.slice(0..-2)

    line = if(String.length(line) == 0, do: nil, else: line)

    lines =
      List.replace_at(
        state[:content_lines],
        y,
        line
      )
      |> Enum.reject(&is_nil/1)

    update_lines(state, lines)
    |> cursor_left()
  end

  def insert_char(state, char) do
    lines =
      List.update_at(state[:content_lines], state[:cursor_position][:y], fn line ->
        {left, right} = String.split_at(line, state[:cursor_position][:x])
        (left <> char <> right) |> String.split("\n")
      end)
      |> List.flatten()

    update_lines(state, lines)
    |> put_in([:cursor_position, :x], state[:cursor_position][:x] + 1)
  end

  def update_lines(state, lines) do
    put_in(state, [:content_lines], lines)
    |> put_in([:content], lines |> Enum.join("\n"))
  end

  def cursor_left(state) do
    %{x: old_x, y: old_y} = state[:cursor_position]
    new_x = old_x - 1

    {x, y} =
      if new_x < 0 do
        new_y = old_y - 1
        new_y = if(new_y < 0, do: 0, else: new_y)
        y_length = Enum.at(state[:content_lines], new_y) |> String.length()

        {y_length, new_y}
      else
        {new_x, old_y}
      end

    put_in(state, [:cursor_position], %{x: x, y: y})
  end

  def cursor_right(state) do
    %{x: old_x, y: old_y} = state[:cursor_position]
    y_length = Enum.at(state[:content_lines], old_y) |> String.length()

    new_x = old_x + 1

    {x, y} =
      if new_x > y_length do
        new_y = old_y + 1
        lines = state[:content_lines] |> length
        if(new_y > lines, do: {old_x, old_y}, else: {0, new_y})
      else
        {new_x, old_y}
      end

    put_in(state, [:cursor_position], %{x: x, y: y})
  end

  def cursor_up(state) do
    old_x = state[:cursor_position][:x]
    y = state[:cursor_position][:y] - 1
    y = if(y < 0, do: 0, else: y)
    y_length = state[:content_lines] |> Enum.at(y) |> String.length()

    put_in(state, [:cursor_position], %{x: if(old_x > y_length, do: y_length, else: old_x), y: y})
  end

  def cursor_down(state) do
    old_x = state[:cursor_position][:x]
    lines_length = state[:content_lines] |> length
    y = state[:cursor_position][:y] + 1
    y = if(y > lines_length - 1, do: lines_length - 1, else: y)
    y_length = state[:content_lines] |> Enum.at(y) |> String.length()

    put_in(state, [:cursor_position], %{x: if(old_x > y_length, do: y_length, else: old_x), y: y})
  end

  def cursor_end(state) do
    y = state[:cursor_position][:y]
    y_length = Enum.at(state[:content_lines], y) |> String.length()

    put_in(state, [:cursor_position, :x], y_length)
  end

  def cursor_start(state) do
    y = state[:cursor_position][:y]

    new_x =
      Enum.at(state[:content_lines], y)
      |> String.split("")
      |> Enum.slice(1..-1)
      |> Enum.find_index(fn x -> x != " " end)

    put_in(state, [:cursor_position, :x], new_x)
  end

  def cursor_word_forward(state, index \\ 0, prev_char \\ nil) do
    %{x: x, y: y} = state[:cursor_position]
    current_char = Enum.at(state[:content_lines], y) |> String.at(x)
    chars = ".,:;/\\!@#$%^&*()_+-=?><{}[]~`\" " |> String.split("")
    chars = [nil | chars]

    if index > 30 || (Enum.member?(chars, current_char) && !Enum.member?(chars, prev_char)) do
      state
    else
      cursor_right(state)
      |> cursor_word_forward(index + 1, current_char)
    end
  end

  def cursor_word_backward(state, index \\ 0, prev_char \\ nil)

  def cursor_word_backward(%{cursor_position: %{x: 0, y: 0}} = state, _, _) do
    state
  end

  def cursor_word_backward(state, index, prev_char) do
    %{x: x, y: y} = state[:cursor_position]
    current_char = Enum.at(state[:content_lines], y) |> String.at(x)
    chars = ".,:;/\\!@#$%^&*()_+-=?><{}[]~`\" " |> String.split("")
    chars = [nil | chars]

    if index > 30 ||
         (Enum.member?(chars, current_char) && !Enum.member?(chars, prev_char) && index > 1) do
      cursor_right(state)
    else
      cursor_left(state)
      |> cursor_word_backward(index + 1, current_char)
    end
  end

  def render(_model, state) do
    ExTermbox.Bindings.set_cursor(
      state[:cursor_position][:x],
      state[:cursor_position][:y]
    )

    label(content: state[:content])
  end
end
