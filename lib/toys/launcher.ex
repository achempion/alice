defmodule Alice.Toys.Launcher do
  @moduledoc """
  A module launch toys
  """
  use Alice.Toy

  alias Alice.Helpers.Toys
  alias Alice.Behaviours.SearchableList

  state _ do
    list = Toys.list() |> Enum.map(&to_string/1)

    %{SearchableList => SearchableList.state(list)}
  end

  default_interaction state, event do
    SearchableList.interaction(state, SearchableList, event)
  end

  render state, _context do
    SearchableList.render(state, SearchableList)
  end
end
