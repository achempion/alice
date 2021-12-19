defmodule Alice.Welcome do
  import Ratatouille.View

  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  @impl true
  def init(args) do
    {:ok, %{bindings: args[:bindings]}}
  end

  @impl true
  def handle_call({:update, event, _model}, _from, state) do
    interaction = 1

    case event do
      :show_help ->
        {:reply, :ok, state}
      _ ->
        {:reply, :ok, state}
    end
  end

  @impl true
  def handle_call(:render, _from, state) do
    {:reply, label(content: "Welcome to the Alice Editor!"), state}
  end

  def interactions do
    %{
      show_help: %{
        bindings: [
          %{ch: ?h}
        ]
      }
    }
  end
end
