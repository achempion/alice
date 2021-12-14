defmodule Alice.Toys.Welcome do
  use Alice.Toy

  state _ do
    %{
      text: """
      Welcome to the Alice editor!

      Press Alt-? for help.
      """
    }
  end

  interaction :insert_hi, :state, [%{ch: ?i}], state do
    Map.put(state, :text, state[:text] <> " hi")
  end

  interaction :open_file_finder, :pane, [%{ch: ?o}], _state do
    {Alice.Toys.FileFinder, %{}}
  end

  interaction :open_active_applications, :pane, [%{ch: ?a}], _state do
    {Alice.Toys.ActiveApplications, %{}}
  end

  interaction :start_observer, :state, [%{ch: ?s}], state do
    :observer.start()
    state
  end

  interaction :restart_editor, :state, [%{ch: ?r}], state do
    Supervisor.restart_child(Ratatouille.Runtime.Supervisor, Ratatouille.Window )
    state
  end

  interaction :close, :close, [%{ch: ?q}], _state do
    self()
  end

  default_interaction state, _event do
    state
  end

  render state, _context do
    label(content: state[:text])
  end
end
