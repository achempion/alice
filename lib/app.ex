defmodule Alice.App do
  @moduledoc """

  Alice is an extendable elixir application with text editing
  abilities.

  An application has a datamodel which can be modified by events.
  After each modification we call the render function to the new user
  interface based on the new data representation.

  # Data model

      %{
        focus: :window_1,
        window_1: "UUID",
        pane: nil,
        modules: %{
          "UUID" => %{
            module: ModuleName,
            state: ModuleName.init()
          }
        }
      }

  """

  @behaviour Ratatouille.App

  import Ratatouille.View
  import Ratatouille.Constants, only: [key: 1]
  require Logger

  def quit_events do
    [
      {:key, key(:ctrl_c)}
    ]
  end

  @recompile %{key: key(:ctrl_r)}
  @pane_file_finder %{key: key(:ctrl_o)}
  @pane_opened_modules %{key: key(:ctrl_b)}

  def init(_context) do
    %{
      focus: :window_1,
      window_1: "Alice",
      pane: [],
      modules: %{
        "Alice" => %{
          module: Alice.Welcome,
          state: Alice.Welcome.init(%{})
        }
      }
    }
  end

  def init_module(module, args \\ %{}) do
    key = NaiveDateTime.utc_now() |> NaiveDateTime.to_string()
    {key, %{module: module, state: module.init(args)}}
  end

  def open_window({key, module}, model) do
    put_in(model, [:modules, key], module)
    |> put_in([:window_1], key)
    |> put_in([:focus], :window_1)
  end

  def open_pane({key, module}, model) do
    put_in(model, [:modules, key], module)
    |> put_in([:pane], [key | model[:pane]])
    |> put_in([:focus], :pane)
  end

  def update(model, msg) do
    case msg do
      {:event, @pane_file_finder} ->
        init_module(Alice.FileFinder) |> open_pane(model)

      {:event, @pane_opened_modules} ->
        init_module(Alice.OpenedModules, %{list: model[:modules] |> Map.to_list()})
        |> open_pane(model)

      {:event, @recompile} ->
        IEx.Helpers.recompile()
        model

      _ ->
        try do
          module_key =
            case model[:focus] do
              :pane ->
                model[:pane] |> hd

              key ->
                model[key]
            end

          module = model[:modules][module_key]

          case module[:module].update(model, msg, module[:state]) do
            {:open_window, {open_module, open_args}} ->
              init_module(open_module, open_args) |> open_window(model)

            {:open_pane} ->
              Logger.warn("not implemented")
              model

            {:update_state, state} ->
              put_in(model, [:modules, module_key, :state], state)

            {:update_model} ->
              Logger.warn("not implemented")
              model

            :close ->
              Logger.warn("not implemented")
              model

            :ok ->
              model
          end
        rescue
          e ->
            # Logger.error(e)
            Logger.error(Exception.format(:error, e, __STACKTRACE__))
            model
        end
    end
  end

  def render(model) do
    window_1 = model[:modules][model[:window_1]]
    pane_1 = if Enum.any?(model[:pane]), do: model[:modules][hd(model[:pane])], else: nil

    view do
      window_1[:module].render(model, window_1[:state])

      if pane_1 do
        panel title: pane_1[:module] |> to_string do
          pane_1[:module].render(model, pane_1[:state])
        end
      end
    end
  end
end
