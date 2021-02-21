defmodule Alice.Welcome do
  # import Ratatouille.Constants, only: [key: 1]
  import Ratatouille.View

  def init(_arg) do
    %{}
  end

  def update(_model, msg, _state) do
    case msg do
      _ ->
        :ok
    end
  end

  def render(_model, _data) do
    label(content: "Welcome to the Alice Editor!")
  end
end
