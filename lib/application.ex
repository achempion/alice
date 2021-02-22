defmodule Alice.Application do
  use Application

  alias Alice.ToysSupervisor

  def start(_type, _args) do
    children = [
      {
        Ratatouille.Runtime.Supervisor,
        runtime: [
          app: Alice.App,
          quit_events: Alice.App.quit_events(),
          shutdown: :system
        ]
      },
      ToysSupervisor
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: Alice.Supervisor
    )
  end
end
