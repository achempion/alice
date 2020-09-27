defmodule Alice.FileFinder do
  import Ratatouille.Constants, only: [key: 1]
  import Ratatouille.View

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)
  @enter key(:enter)

  def init do
    %{
      files: File.ls!(),
      index: 0
    }
  end

  def update(model, msg) do
    case msg do
      {:event, %{key: @arrow_down}} ->
        put_in(
          model,
          [:pane, :data, :index],
          next_index(model[:pane][:data])
        )

      {:event, %{key: @arrow_up}} ->
        put_in(
          model,
          [:pane, :data, :index],
          prev_index(model[:pane][:data])
        )

      {:event, %{key: @enter}} ->
        data = model[:pane][:data]
        path = Enum.at(data[:files], data[:index])
        put_in(
          model,
          [model[:focus]],
          %{
            module: Alice.Editor,
            data: Alice.Editor.init(path)
          }
        ) |> put_in([:pane], nil)

      _ ->
        model
    end
  end

  def next_index(data) do
    max_value = length(data[:files]) - 1
    next_value = data[:index] + 1

    if next_value > max_value do
      max_value
    else
      next_value
    end
  end

  def prev_index(data) do
    min_value = 0
    prev_value = data[:index] - 1

    if prev_value < min_value do
      min_value
    else
      prev_value
    end
  end

  def render(_model, data) do
    viewport(offset_y: 0) do
      for {file, idx} <- Enum.with_index(data[:files]) do
        if idx == data[:index] do
          label(content: file, attributes: [:bold])
        else
          label(content: file)
        end
      end
    end
  end
end
