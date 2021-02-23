defmodule Alice.Toys.FileFinder do
  use Alice.Toy

  state _ do
    %{
      files: File.ls!(),
      index: 0
    }
  end

  interaction :next, :state, [%{key: key(:arrow_down)}], state do
    Map.put(state, :index, state[:index] + 1)
  end

  interaction :prev, :state, [%{key: key(:arrow_up)}], state do
    Map.put(state, :index, state[:index] - 1)
  end

  interaction :open_file,
              :window,
              [
                %{key: key(:enter)}
              ],
              %{files: files, index: i} do
    {Alice.Toys.Editor, %{path: Enum.at(files, i)}}
  end

  interaction :close, :close, [%{ch: ?q}], _state do
    self()
  end

  default_interaction state, _event do
    state
  end

  render state, _context do
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
