defmodule Alice.ScreenHelper do
  @doc """
  Clear screen by replacing each cell and then clearing everything
  """
  def clear() do
    {:ok, width} = ExTermbox.Bindings.width()
    {:ok, height} = ExTermbox.Bindings.height()

    # update every sreen cell
    for x <- 0..width, y <- 0..height do
      :ok =
        ExTermbox.Bindings.put_cell(%ExTermbox.Cell{
          position: %ExTermbox.Position{x: x, y: y},
          ch: ?🐈
        })
    end
    # flush the changes
    ExTermbox.Bindings.present()

    # clear the screen
    ExTermbox.Bindings.clear()
    ExTermbox.Bindings.present()
  end
end
