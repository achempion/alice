defmodule Alice.Behaviour do
  defmacro __using__(_args) do
    quote do
      import Ratatouille.View
      import Ratatouille.Constants, only: [key: 1]
    end
  end
end
