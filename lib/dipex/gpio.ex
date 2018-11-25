defmodule Gpio do
  require Logger

  def on do
    case System.get_env("FLEX_RPI") do
      nil ->
        Logger.error("FLEX_RPI=nil fake gpio on")

      "0" ->
        Logger.error("FLEX_RPI=0 fake gpio on")

      "1" ->
        Logger.error("FLEX_RPI=1 gpio write 0 1")
        IO.inspect(:os.cmd('gpio write 0 1'))
    end
  end

  def off do
    case System.get_env("FLEX_RPI") do
      nil ->
        Logger.error("FLEX_RPI=nil fake gpio off")

      "0" ->
        Logger.error("FLEX_RPI=0 fake gpio off")

      "1" ->
        Logger.error("FLEX_RPI=1 gpio write 0 0")
        IO.inspect(:os.cmd('gpio write 0 0'))
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
      nil ->
        Logger.error("FLEX_RPI=nil fake gpio unexportall")

      "0" ->
        Logger.error("FLEX_RPI=0 fake gpio unexportall")

      "1" ->
        Logger.error("FLEX_RPI=1 gpio unexportall")
        IO.inspect(:os.cmd('gpio unexportall'))
    end
  end

  def export() do
    case System.get_env("FLEX_RPI") do
      nil ->
        Logger.error("FLEX_RPI=nil fake gpio export")

      "0" ->
        Logger.error("FLEX_RPI=0 fake gpio export")

      "1" ->
        Logger.error("FLEX_RPI=1 gpio mode 0 out")
        IO.inspect(:os.cmd('gpio mode 0 out'))
    end
  end
end
