defmodule Alice.Toys.Launcher do
  @moduledoc """
  A module launch toys
  """
  use Alice.Toy

  alias Alice.ToysHelper
  alias Alice.Behaviours.SearchableList

  state _ do
    list = ToysHelper.list() |> Enum.map(&to_string/1)

    %{SearchableList => SearchableList.state(list)}
  end

  default_interaction state, event do
    {:state, updated_state} = SearchableList.interaction(state, SearchableList, event)
    updated_state
  end

  render state, context do
    SearchableList.render(context, state, SearchableList)
  end
end
