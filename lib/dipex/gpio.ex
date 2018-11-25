defmodule Gpio do
  require Logger

  def on do
    case System.get_env("FLEX_RPI") do
      nil -> Logger.error "nil on"
      "0" -> Logger.error "0 on"
      "1" ->
        Logger.error("gpio write 0 1")
        IO.inspect :os.cmd('gpio write 0 1')
    end
  end

  def off do
    case System.get_env("FLEX_RPI") do
      nil -> Logger.error "nil off"
      "0" -> Logger.error "0 off"
      "1" ->
        Logger.error("gpio write 0 0")
        IO.inspect :os.cmd('gpio write 0 0')
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
    case System.get_env("FLEX_RPI") do
      nil -> Logger.error "nil unexportall"
      "0" -> Logger.error "0 unexportall"
      "1" ->
        Logger.error("gpio unexportall")
        IO.inspect :os.cmd('gpio unexportall')
    end
  end

  def export() do
    case System.get_env("FLEX_RPI") do
      nil -> Logger.error "nil export"
      "0" -> Logger.error "0 export"
      "1" ->
        Logger.error("gpio mode 0 out")
        IO.inspect :os.cmd('gpio mode 0 out')
    end
  end
end
