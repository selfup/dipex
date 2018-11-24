defmodule Gpio do
  require Logger

  @flex_rpi System.get_env("FLEX_RPI")

  def on do
    case @flex_rpi do
      nil -> Logger.warn "nil on"
      _ -> :os.cmd('gpio write 0 1') |> Logger.warn
    end
  end

  def off do
    case @flex_rpi do
      nil -> Logger.warn "nil off"
      _ -> :os.cmd('gpio write 0 0') |> Logger.warn
    end
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
    case @flex_rpi do
      nil -> Logger.warn "nil unexportall"
      _ -> :os.cmd('gpio unexportall') |> Logger.warn
    end
  end

  def export() do
    case @flex_rpi do
      nil -> Logger.warn "nil export"
      _ -> :os.cmd('gpio mode 0 out') |> Logger.warn
    end
  end
end
