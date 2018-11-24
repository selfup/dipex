defmodule FlexStream do
  use GenServer, restart: :permanent, shutdown: 10_000
  
  require Logger
  require Gpio

  @all "c1|sub slice all\r\n"
  @flex_ip '10.192'
  @flex_port 4992
  @tcp_options [:binary, active: false, packet: 0]

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    Gpio.init()

    dipex()

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
    :gen_tcp.connect(@flex_ip, @flex_port, @tcp_options)
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
    Logger.warn("\n\n" <> msg <> "\n"<> to_string(DateTime.utc_now) <> "\n")
  end
end
