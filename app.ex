defmodule Alice.App do
  @behaviour Ratatouille.App

  import Ratatouille.View
  import Ratatouille.Constants, only: [key: 1]

  def quit_events do
    [
      {:key, key(:ctrl_c)}
    ]
  end

  @ctrl_r key(:ctrl_r)
  @ctrl_o key(:ctrl_o)
  @_o key(:ctrl_o)

  def init(_context) do
    %{
      focus: :window_1,
      window_1: %{
        module: Alice.Welcome,
        data: Alice.Welcome.init()
      }
    }
  end

  def update(model, msg) do
    case msg do
      {:event, %{key: @ctrl_o}} ->
        model
        |> Map.put(:pane, %{
          module: Alice.FileFinder,
          data: Alice.FileFinder.init()
        })

      {:event, %{key: @ctrl_r}} ->
        IEx.Helpers.recompile()

        model

      _ ->
        key =
          if model[:pane] do
            :pane
          else
            model[:focus]
          end

        model[key][:module].update(model, msg)
    end
  end

  def render(model) do
    view do
      model[:window_1][:module].render(model, model[:window_1][:data])

      if model[:pane] do
        panel title: model[:pane][:module] |> inspect do
          model[:pane][:module].render(model, model[:pane][:data])
        end
      end
    end
  end
end
