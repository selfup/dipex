defmodule FlexStream do
  use GenServer, restart: :permanent, shutdown: 5_000

  require Supervisor
  require Logger
  require Gpio
  require Parser
  require Engine

  # must include CLRF
  # for radio to actually send back all information
  # otherwise it just sends back connection metadata
  @all "c1|sub slice all\r\n"
  @flex_port 4992
  @tcp_options [:binary, active: false, packet: 0]

  defp flex_ip do
    env_flex_ip = System.get_env("FLEX_IP")

    case env_flex_ip do
      nil -> '10.192'
      ip -> String.to_charlist(ip)
    end
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    Cache.init()
    Gpio.init()

    init_stream()

    {:ok, []}
  end

  @doc """
  Connects to flex radio
  sends msg to recieve all
  recursive read gets msgs
  msg gets parsed
  based on msg gpio is turned on or off
  """
  def init_stream do
    {:ok, socket} = connect()

    :ok = all(socket)

    Cache.set("flex_socket", socket)

    children = [{Task, fn -> read(socket) end}]
    opts = [strategy: :one_for_one, name: Dipex.FlexStream.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def connect do
    flex_ip() |> :gen_tcp.connect(@flex_port, @tcp_options)
  end

  def all(flex) do
    :gen_tcp.send(flex, @all)
  end

  def read(flex) do
    {:ok, msg} = :gen_tcp.recv(flex, 0)

    parse_msg(msg)

    read(flex)
  end

  def parse_msg(msg) do
    if !System.get_env("FLEX_RPI"), do: Logger.warn(msg)

    msg
    |> Parser.parse()
    |> Engine.make_decision()
  end
end
