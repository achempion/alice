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
  alias Alice.Toys.Welcome

  def quit_events do
    [
      {:key, key(:ctrl_c)}
    ]
  end

  def init(_context) do
    %{
      focus: :window1,
      window1: init_module(Welcome),
      pane: nil
    }
  end

  def init_module(module, args \\ %{}) do
    {:ok, pid} = ToysSupervisor.start_child(module, args)
    pid
  end

  def update(model, {:event, event}) do
    case event do
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
              {key, pid} = Enum.find(model, fn {k, v} -> v == pid end)

              GenServer.stop(pid)

              if key == :pane do
                model
                |> Map.put(:pane, nil)
                |> Map.put(:focus, :window1)
              else
                model
                |> Map.put(key, init_module(Welcome))
              end

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

  def render(model) do
    view do
      model[:window1] && GenServer.call(model[:window1], :render)

      if model[:pane] do
        panel title: "Pane" do
          GenServer.call(model[:pane], :render)
        end
      end
    end
  end
end
