defmodule DipexWeb.ApiController do
  use DipexWeb, :controller

  require Gpio

  def cmd(conn, %{"cmd" => cmd} = _params) do
    cmd_response =
      case cmd do
        "on" ->
          # turns pin off but relay goes on
          Gpio.off()

        "off" ->
          # turns pin on but relay goes off
          Gpio.on()

        "unexport" ->
          # unexports pin but they maintain state
          Gpio.unexport()

        "export" ->
          # exports pin to mode out
          Gpio.export()

        _ ->
          nil
      end

    json(conn, %{
      cmd: cmd,
      cmd_response: cmd_response
    })
  end
end
