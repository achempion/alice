defmodule Alice.Welcome do
  # import Ratatouille.Constants, only: [key: 1]
  import Ratatouille.View

  def init do
    %{}
  end

  def update(model, msg) do
    case msg do
      _ ->
        model
    end
  end

  def render(_model, _data) do
    label(content: "Welcome to the Alice Editor!")
  end
end
