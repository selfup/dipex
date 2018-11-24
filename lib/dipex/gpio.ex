defmodule Gpio do
  require Logger

  def on do
    :os.cmd('gpio write 0 1') |> Logger.warn
  end

  def off do
    :os.cmd('gpio write 0 0') |> Logger.warn
  end

  ## Server Callbacks

  def init() do
    unexport()
    export()

    {:ok, []}
  end

  def terminate(_reason, _state) do
    unexport()
  end

  ## Private Methods

  def unexport() do
    :os.cmd('gpio unexportall') |> Logger.warn
  end

  def export() do
    :os.cmd('gpio mode 0 out') |> Logger.warn
  end
end
