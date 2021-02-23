defmodule Alice.Toy do
  defmacro __using__(_args) do
    quote do
      import Ratatouille.View
      import Ratatouille.Constants, only: [key: 1]
      import unquote(__MODULE__)

      use GenServer

      @bindings %{}
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro state(args, do: block) do
    block = Macro.escape(block)
    args = Macro.escape(args)

    quote bind_quoted: [args: args, block: block] do
      def init(unquote(args)), do: {:ok, unquote(block)}
    end
  end

  defmacro interaction(name, type, bindings, state, do: block) do
    block = Macro.escape(block)
    state = Macro.escape(state)

    quote bind_quoted: [
            name: name,
            type: type,
            bindings: bindings,
            state: state,
            block: block
          ] do
      @bindings Enum.reduce(
                  bindings,
                  @bindings,
                  fn binding, acc ->
                    event =
                      %ExTermbox.Event{type: 1}
                      |> Map.merge(binding)

                    Map.put(acc, event, name)
                  end
                )

      def unquote(name)(unquote(state)) do
        {unquote(type), unquote(block)}
      end
    end
  end

  defmacro default_interaction(state, event, do: block) do
    block = Macro.escape(block)
    state = Macro.escape(state)
    event = Macro.escape(event)

    quote bind_quoted: [state: state, event: event, block: block] do
      def default_interaction(unquote(state), unquote(event)) do
        {:state, unquote(block)}
      end
    end
  end

  defmacro render(state, context, do: block) do
    block = Macro.escape(block)
    state = Macro.escape(state)
    context = Macro.escape(context)

    quote bind_quoted: [state: state, context: context, block: block] do
      def handle_call({:render, unquote(context)}, _from, unquote(state)) do
        {:reply, unquote(block), unquote(state)}
      end
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def start_link(default) do
        GenServer.start_link(__MODULE__, default)
      end

      def handle_call({:update, event}, _from, state) do
        interaction = @bindings[event]

        if interaction do
          apply(__MODULE__, @bindings[event], [state])
        else
          apply(__MODULE__, :default_interaction, [state, event])
        end
        |> case do
          {:state, new_state} ->
            {:reply, :ok, new_state}

          {:pane, pane} ->
            {:reply, {:pane, pane}, state}

          {:window, pane} ->
            {:reply, {:window, pane}, state}

          {:close, pid} ->
            {:reply, {:close, pid}, state}
        end
      end
    end
  end
end
