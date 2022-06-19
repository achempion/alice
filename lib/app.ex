defmodule Alice.App do
  @moduledoc """
  Main point of an editor to mange the layout

  It keeps layout data structure also handles state updates and opens
  new panes and buffers
  """

  @behaviour Ratatouille.App

  import Ratatouille.View
  import Ratatouille.Constants, only: [key: 1]
  require Logger

  alias Alice.ToysSupervisor
  alias Alice.Toys.{Editor, ToyHelp, Welcome}
  alias Alice.ScreenHelper

  @recompile %{key: key(:ctrl_r)}
  @close %{ch: ?q, mod: 1}
  @help %{ch: ??, mod: 1}
  @switch_focus %{ch: ?s, mod: 1}
  @debug_state %{ch: ?d, mod: 1}

  @doc """
  How to quit vim
  """
  def quit_events do
    [
      {:key, key(:ctrl_c)}
    ]
  end

  def init(%{window: %{height: height}}) do
    # Enable alt-<char> combinations as one event, if a default is
    # :esc mode it sends alt event as a separate message
    ExTermbox.Constants.input_mode(:alt)
    |> ExTermbox.Bindings.select_input_mode()

    # main layout data structure
    %{
      focus: :window1,
      window1: init_module(Welcome),
      pane: nil,
      window: %{
        height: height
      }
    }
  end

  @doc """
  Start an interactive module as a separate process and add it to
  dynamic supervisor
  """
  def init_module(module, args \\ %{}) do
    {:ok, pid} = ToysSupervisor.start_child(module, args)
    pid
  end

  # ingore resize event
  def update(model, {:resize, _event}) do
    model
  end

  @doc """
  Main function to hande all editor event (mostly key presses)
  """
  def update(model, {:event, event}) do
    # global events is on top
    case event do
      @recompile ->
        IEx.Helpers.recompile()

        # System.cmd("mix", ["compile"])
        # as the recompilation generates bunch of messages, we want to
        # clear the whole screen after that
        ScreenHelper.clear()

        model

      @close ->
        close(model, model[model.focus])

      @switch_focus ->
        Map.put(model, :focus, if(model[:focus] == :pane, do: :window1, else: :pane))

      @help ->
        focus_pid = model[model[:focus]]

        Map.put(model, :window1, init_module(ToyHelp, focus_pid))
        |> Map.put(:focus, :window1)

      @debug_state ->
        focus_pid = model[model[:focus]]

        content = :sys.get_state(focus_pid) |> inspect(pretty: true)

        Map.put(model, :window1, init_module(Editor, %{content: content}))
        |> Map.put(:focus, :window1)

      _ ->
        # handle rest of the events
        handle_event(model, event)
    end
  end

  @doc """
  Pass an event to an app in focus and optionally modify a current
  layout
  """
  def handle_event(model, event) do
    try do
      focus_pid = model[model[:focus]]

      # pass an even to an app in a focus
      case GenServer.call(focus_pid, {:update, event}) do
        {:window, {open_module, open_args}} ->
          # open a window
          Map.put(model, :window1, init_module(open_module, open_args))
          |> Map.put(:focus, :window1)

        {:pane, {open_module, open_args}} ->
          # open a pane
          Map.put(model, :pane, init_module(open_module, open_args))
          |> Map.put(:focus, :pane)

        {:close, pid} ->
          # close an app
          close(model, pid)

        :ok ->
          # nothing to update in a layout
          model
      end
    rescue
      e ->
        Logger.error(Exception.format(:error, e, __STACKTRACE__))
        model
    end
  end

  @doc """
  Terminate running process and find a replacement
  """
  def close(model, pid) do
    {buffer_type, pid} = Enum.find(model, fn {_k, v} -> v == pid end)

    DynamicSupervisor.terminate_child(ToysSupervisor, pid)

    if buffer_type == :pane do
      model
      |> Map.put(:pane, nil)
      |> Map.put(:focus, :window1)
    else
      # try to find a replacement to display in a :window
      pid =
        case DynamicSupervisor.which_children(ToysSupervisor) |> List.first() do
          {:undefined, pid, :worker, _module} ->
            pid

          _ ->
            # no replacement, start default screen
            init_module(Welcome)
        end

      model
      |> Map.put(buffer_type, pid)
    end
  end

  @doc """
  Main layout of the editor
  """
  def render(model) do
    context = %{window: model.window}
    selected = "*selected*"

    view do
      model[:window1] &&
        panel title: "Window1 #{if model.focus == :window1, do: selected}",
              height: model.window.height - 10 do
          GenServer.call(
            model[:window1],
            {
              :render,
              context |> Map.merge(%{current_panel: %{height: model.window.height - 10}})
            }
          )
        end

      model[:pane] &&
        panel title: "Pane #{if model.focus == :pane, do: selected}", height: 10 do
          GenServer.call(
            model[:pane],
            {
              :render,
              context |> Map.merge(%{current_panel: %{height: 10}})
            }
          )
        end
    end
  end
end
