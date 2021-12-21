defmodule Alice.Behaviour do
  defmacro __using__(_args) do
    quote do
      import Ratatouille.View
    end
  end
end
