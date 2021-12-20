defmodule Alice.Helpers.Toys do
  @doc """
  Returns list of all interactive modules
  """
  def list do
    {:ok, toys} = :application.get_key(:alice, :modules)

    toys
    |> Enum.reduce([], fn toy, acc ->
      if String.match?(to_string(toy), ~r/\.Toys\./) do
        [toy | acc]
      else
        acc
      end
    end)
  end
end
