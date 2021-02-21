defmodule Alice.FileFinder do
  import Ratatouille.Constants, only: [key: 1]
  import Ratatouille.View

  @prev %{key: key(:arrow_up)}
  @next %{key: key(:arrow_down)}
  @close %{ch: ?q}
  @select %{key: key(:enter)}

  def init(_arg) do
    %{
      files: File.ls!(),
      index: 0
    }
  end

  def update(model, msg, state) do
    case msg do
      {:event, @next} ->
        {:update_state, put_in(state, [:index], next_index(state))}

      {:event, @prev} ->
        {:update_state, put_in(state, [:index], prev_index(state))}

      {:event, @select} ->
        path = Enum.at(state[:files], state[:index])
        {:open_window, {Alice.Editor, %{path: path}}}

      {:event, @close} ->
         :close

      _ ->
        :ok
    end
  end

  def next_index(state) do
    max_value = length(state[:files]) - 1
    next_value = state[:index] + 1

    if next_value > max_value do
      max_value
    else
      next_value
    end
  end

  def prev_index(state) do
    min_value = 0
    prev_value = state[:index] - 1

    if prev_value < min_value do
      min_value
    else
      prev_value
    end
  end

  def render(_model, state) do
    viewport(offset_y: 0) do
      for {file, idx} <- Enum.with_index(state[:files]) do
        if idx == state[:index] do
          label(content: file, attributes: [:bold])
        else
          label(content: file)
        end
      end
    end
  end
end
