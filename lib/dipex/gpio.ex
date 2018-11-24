defmodule Gpio do
  use GenServer

  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def on(server, pin) do
    GenServer.call(server, {:on})
  end

  def off(server) do
    GenServer.call(server, {:off})
  end

  ## Server Callbacks

  def init(:ok) do
    unexport()
    export()

    {:ok, []}
  end

  def handle_call({:on}, _from, _state) do
    :os.cmd('gpio write 0 1') |> Logger.warn
    {:reply, [], []}
  end

  def handle_call({:off}, _from, _state) do
    :os.cmd('gpio write 0 0') |> Logger.warn
    {:reply, [], []}
  end

  def terminate(_reason, _state) do
    unexport()
  end

  ## Private Methods

  defp unexport() do
    :os.cmd('gpio unexportall') |> Logger.warn
  end

  defp export() do
    :os.cmd('gpio mode 0 1') |> Logger.warn
  end
end
