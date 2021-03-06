defmodule Alice.MixShell do
  @behaviour Mix.Shell

  def print_app, do: :ok
  def info(_message), do: :ok
  def error(_message), do: :ok
  defdelegate prompt(message), to: Mix.Shell.IO
  defdelegate yes?(message), to: Mix.Shell.IO
  defdelegate yes?(message, options), to: Mix.Shell.IO

  def cmd(command, opts \\ []) do
    Mix.Shell.cmd(command, opts, fn data -> data end)
  end
end
