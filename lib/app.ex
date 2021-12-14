defmodule Alice.App do
  @moduledoc """
  Alice is an extendable elixir application with text editing
  abilities.
  """

  @behaviour Ratatouille.App

  import Ratatouille.View
  import Ratatouille.Constants, only: [key: 1]
  require Logger

  alias Alice.ToysSupervisor
  alias Alice.Toys.{Welcome, ToyHelp}

  @recompile %{key: key(:ctrl_r)}
  @close %{ch: ?q, mod: 1}
  @help %{ch: ??, mod: 1}
  @switch_focus %{ch: ?s, mod: 1}

  def quit_events do
    [
      {:key, key(:ctrl_c)}
    ]
  end

  def init(%{window: %{height: height}}) do
    ExTermbox.Constants.input_mode(:alt)
    |> ExTermbox.Bindings.select_input_mode()

    %{
      focus: :window1,
      window1: init_module(Welcome),
      pane: nil,
      window: %{
        height: height
      }
    }
  end

  def init_module(module, args \\ %{}) do
    {:ok, pid} = ToysSupervisor.start_child(module, args)
    pid
  end

  def update(model, {:resize, _event}) do
    model
  end

  def update(model, {:event, event}) do
    case event do
      @recompile ->
        IEx.Helpers.recompile()
        model

      @close ->
        close(model, model[model.focus])

      @switch_focus ->
        Map.put(model, :focus, if(model[:focus] == :pane, do: :window1, else: :pane))

      @help ->
        focus_pid = model[model[:focus]]

        Map.put(model, :window1, init_module(ToyHelp, focus_pid))
        |> Map.put(:focus, :window1)

      _ ->
        try do
          focus_pid = model[model[:focus]]

          case GenServer.call(focus_pid, {:update, event}) do
            {:window, {open_module, open_args}} ->
              Map.put(model, :window1, init_module(open_module, open_args))
              |> Map.put(:focus, :window1)

            {:pane, {open_module, open_args}} ->
              Map.put(model, :pane, init_module(open_module, open_args))
              |> Map.put(:focus, :pane)

            {:close, pid} ->
              close(model, pid)

            :ok ->
              model
          end
        rescue
          e ->
            Logger.error(Exception.format(:error, e, __STACKTRACE__))
            model
        end
    end
  end

  def close(model, pid) do
    {key, pid} = Enum.find(model, fn {_k, v} -> v == pid end)

    DynamicSupervisor.terminate_child(ToysSupervisor, pid)

    if key == :pane do
      model
      |> Map.put(:pane, nil)
      |> Map.put(:focus, :window1)
    else
      pid =
        case DynamicSupervisor.which_children(ToysSupervisor) |> List.first() do
          {:undefined, pid, :worker, _module} ->
            pid

          _ ->
            init_module(Welcome)
        end

      model
      |> Map.put(key, pid)
    end
  end

  def render(model) do
    context = %{window: model.window}
    selected = "*selected*"

    view do
      model[:window1] &&
        panel title: "Window1 #{if model.focus == :window1, do: selected}",
              height: model.window.height - 10 do
          GenServer.call(model[:window1], {:render, context})
        end

      model[:pane] &&
        panel title: "Pane #{if model.focus == :pane, do: selected}", height: 10 do
          GenServer.call(model[:pane], {:render, context})
        end
    end
  end
end
