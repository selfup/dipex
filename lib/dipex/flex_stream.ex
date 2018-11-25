defmodule FlexStream do
  use GenServer, restart: :permanent, shutdown: 5_000
  
  require Supervisor
  require Logger
  require Gpio
  require Parser
  require IEx

  # must include CLRF for radio to actually send back all information
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
    :ets.new(:dipex_cache, [
      :named_table,
      :set,
      :public,
      read_concurrency: true,
      write_concurrency: true,
    ])

    Gpio.init()

    children = [{Task, fn -> dipex() end}]

    opts = [strategy: :one_for_one, name: Dipex.FlexStream.Supervisor]

    Supervisor.start_link(children, opts)

    {:ok, []}
  end
  
  @doc """
  Connects to flex radio
  sends msg to recieve all
  recursive read gets msgs
  msg gets parsed
  based on msg gpio is turned on or off
  """
  def dipex do
    {:ok, flex} = connect()

    :ok = all(flex)

    read(flex)
  end

  def connect do
    flex_ip() |> :gen_tcp.connect(@flex_port, @tcp_options)
  end

  def all(flex) do
    :gen_tcp.send(flex, @all)
  end

  def read(flex) do
    {:ok, msg} = :gen_tcp.recv(flex, 0)

    log_msg(msg)

    read(flex)
  end

  def log_msg(msg) do
    Logger.warn("\n\n" <> msg)

    Parser.parse(msg)
  end
end
