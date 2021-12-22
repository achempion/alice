defmodule Alice.Behaviour do
  defmacro __using__(_args) do
    quote do
      import Ratatouille.View
      import Ratatouille.Constants, only: [key: 1]
      import unquote(__MODULE__)

      @bindings %{}
      @interactions []
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro interaction(name, type, bindings, state, key, do: block) do
    block = Macro.escape(block)
    state = Macro.escape(state)
    key = Macro.escape(key)

    quote bind_quoted: [
            name: name,
            type: type,
            bindings: bindings,
            state: state,
            key: key,
            block: block
          ] do
      @interactions [%{name: name, bindings: bindings, type: type} | @interactions]
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

      def unquote(name)(unquote(state), unquote(key)) do
        unquote(block)
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def interaction(state, key, event) do
        interaction = @bindings[event]

        if interaction do
          apply(__MODULE__, interaction, [state, key])
        else
          state
        end
      end
    end
  end
end
