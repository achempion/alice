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

  def init(path) do
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

  def update(model, msg) do
    data = model[model[:focus]][:data]

    case msg do
      {:event, %{key: @arrow_right}} ->
        cursor_right(model, data)

      {:event, %{key: @arrow_left}} ->
        cursor_left(model, data)

      {:event, %{key: @arrow_up}} ->
        cursor_up(model, data)

      {:event, %{key: @arrow_down}} ->
        cursor_down(model, data)

      {:event, %{key: @ctrl_e}} ->
        cursor_end(model, data)

      {:event, %{key: @ctrl_a}} ->
        cursor_start(model, data)

      {:event, @alt_f} ->
        cursor_word_forward(model, data)

      {:event, @alt_b} ->
        cursor_word_backward(model, data)

      {:event, %{ch: char}} when char > 0 ->
        insert_char(model, data, <<char::utf8>>)

      {:event, %{key: key}} when key in @delete_keys ->
        delete_char(model, data)

      {:event, %{key: @spacebar}} ->
        insert_char(model, data, " ")

      {:event, %{key: @enter}} ->
        insert_char(model, data, "\n")
        |> put_in(
          [model[:focus], :data, :cursor_position],
          %{x: 0, y: data[:cursor_position][:y] + 1}
        )

      _ ->
        model
    end
  end

  def delete_char(model, data) do
    current_line = Enum.at(data[:content_lines], data[:cursor_position][:y])

    {left, right} = String.split_at(current_line, data[:cursor_position][:x])

    lines =
      if String.length(left) == 0 && data[:cursor_position][:y] > 0 do
        y = data[:cursor_position][:y] - 1

        List.update_at(data[:content_lines], y, fn line -> line <> right end)
        |> List.replace_at(y + 1, nil)
      else
        result = String.slice(left, 0..-2) <> right
        result = if(result |> String.length() == 0, do: nil, else: result)

        List.replace_at(
          data[:content_lines],
          data[:cursor_position][:y],
          result
        )
      end
      |> Enum.reject(&is_nil/1)

    update_lines(model, lines)
    |> cursor_left(data)
  end

  def delete_last_char(model, data, y) do
    line = Enum.at(data[:content_lines], y) |> String.slice(model, 0..-2)

    line = if(String.length(line) == 0, do: nil, else: line)

    lines =
      List.replace_at(
        data[:content_lines],
        y,
        line
      )
      |> Enum.reject(&is_nil/1)

    update_lines(model, lines)
    |> cursor_left(data)
  end

  def insert_char(model, data, char) do
    lines =
      List.update_at(data[:content_lines], data[:cursor_position][:y], fn line ->
        {left, right} = String.split_at(line, data[:cursor_position][:x])
        (left <> char <> right) |> String.split("\n")
      end)
      |> List.flatten()

    update_lines(model, lines)
    |> put_in(
      [model[:focus], :data, :cursor_position, :x],
      data[:cursor_position][:x] + 1
    )
  end

  def update_lines(model, lines) do
    put_in(
      model,
      [model[:focus], :data, :content_lines],
      lines
    )
    |> put_in(
      [model[:focus], :data, :content],
      lines |> Enum.join("\n")
    )
  end

  def cursor_left(model, data) do
    %{x: old_x, y: old_y} = data[:cursor_position]
    new_x = old_x - 1

    {x, y} =
      if new_x < 0 do
        new_y = old_y - 1
        new_y = if(new_y < 0, do: 0, else: new_y)
        y_length = Enum.at(data[:content_lines], new_y) |> String.length()

        {y_length, new_y}
      else
        {new_x, old_y}
      end

    put_in(
      model,
      [model[:focus], :data, :cursor_position],
      %{x: x, y: y}
    )
  end

  def cursor_right(model, data) do
    %{x: old_x, y: old_y} = data[:cursor_position]
    y_length = Enum.at(data[:content_lines], old_y) |> String.length()

    new_x = old_x + 1

    {x, y} =
      if new_x > y_length do
        new_y = old_y + 1
        lines = data[:content_lines] |> length
        if(new_y > lines, do: {old_x, old_y}, else: {0, new_y})
      else
        {new_x, old_y}
      end

    put_in(
      model,
      [model[:focus], :data, :cursor_position],
      %{x: x, y: y}
    )
  end

  def cursor_up(model, data) do
    old_x = data[:cursor_position][:x]
    y = data[:cursor_position][:y] - 1
    y = if(y < 0, do: 0, else: y)
    y_length = data[:content_lines] |> Enum.at(y) |> String.length()

    put_in(
      model,
      [model[:focus], :data, :cursor_position],
      %{
        x: if(old_x > y_length, do: y_length, else: old_x),
        y: y
      }
    )
  end

  def cursor_down(model, data) do
    old_x = data[:cursor_position][:x]
    lines_length = data[:content_lines] |> length
    y = data[:cursor_position][:y] + 1
    y = if(y > lines_length, do: lines_length, else: y)
    y_length = data[:content_lines] |> Enum.at(y) |> String.length()

    put_in(
      model,
      [model[:focus], :data, :cursor_position],
      %{
        x: if(old_x > y_length, do: y_length, else: old_x),
        y: y
      }
    )
  end

  def cursor_end(model, data) do
    y = data[:cursor_position][:y]
    y_length = Enum.at(data[:content_lines], y) |> String.length()
    put_in(model, [model[:focus], :data, :cursor_position, :x], y_length)
  end

  def cursor_start(model, data) do
    y = data[:cursor_position][:y]

    new_x =
      Enum.at(data[:content_lines], y)
      |> String.split("")
      |> Enum.slice(1..-1)
      |> Enum.find_index(fn x -> x != " " end)

    put_in(model, [model[:focus], :data, :cursor_position, :x], new_x)
  end

  def cursor_word_forward(model, data, index \\ 0, prev_char \\ nil) do
    %{x: x, y: y} = data[:cursor_position]
    current_char = Enum.at(data[:content_lines], y) |> String.at(x)
    chars = ".,:;/\\!@#$%^&*()_+-=?><{}[]~`\" " |> String.split("")
    chars = [nil | chars]

    if index > 30 || (Enum.member?(chars, current_char) && !Enum.member?(chars, prev_char)) do
      model
    else
      model = cursor_right(model, data)
      cursor_word_forward(model, model[model[:focus]][:data], index + 1, current_char)
    end
  end

  def cursor_word_backward(model, data, index \\ 0, prev_char \\ nil)

  def cursor_word_backward(model, %{cursor_position: %{x: 0, y: 0}}, _, _) do
    model
  end

  def cursor_word_backward(model, data, index, prev_char) do
    %{x: x, y: y} = data[:cursor_position]
    current_char = Enum.at(data[:content_lines], y) |> String.at(x)
    chars = ".,:;/\\!@#$%^&*()_+-=?><{}[]~`\" " |> String.split("")
    chars = [nil | chars]

    if index > 30 ||
         (Enum.member?(chars, current_char) && !Enum.member?(chars, prev_char) && index > 1) do
      cursor_right(model, data)
    else
      model = cursor_left(model, data)
      cursor_word_backward(model, model[model[:focus]][:data], index + 1, current_char)
    end
  end

  def render(model, data) do
    ExTermbox.Bindings.set_cursor(
      data[:cursor_position][:x],
      data[:cursor_position][:y]
    )

    label(content: data[:content])
  end
end
