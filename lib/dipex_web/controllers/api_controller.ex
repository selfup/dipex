defmodule DipexWeb.ApiController do
  use DipexWeb, :controller

  require Gpio

  def cmd(conn, %{"cmd" => cmd} = _params) do
    case cmd do
      "on" ->
        Gpio.on()
      "off" ->
        Gpio.off()
      "unexport" ->
        Gpio.unexport()
      "export" -> 
        Gpio.export()
      _ ->
        nil
    end

    json(conn, %{
      cmd: cmd,
    })
  end
end
