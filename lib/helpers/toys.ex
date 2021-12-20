defmodule Alice.Helpers.Toys do
  @doc """
  Returns list of all interactive modules
  """
  def list do
    {:ok, toys} = :application.get_key(:alice, :modules)

    toys
    |> Enum.reduce([], fn toy, acc ->
      toy_name = to_string(toy)

      if String.match?(toy_name, ~r/\.Toys\./) do
        [{toy, toy_name} | acc]
      else
        acc
      end
    end)
  end
end
