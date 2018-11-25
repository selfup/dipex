defmodule Parser do
  require Logger
  require Gpio
  require Cache

  @ant "ANT2"

  def parse(msg) do
    msg
    |> split_msg
    |> find_slices
    |> kv_slices
    |> transmit_true_slices
    |> relay_decision
  end

  def split_msg(msg) do
    String.split(msg, "\n")
  end

  def find_slices(slices) do
    Enum.filter(slices, fn e -> e =~ "|slice" end)
  end

  def kv_slices(slices) do
    Enum.map(slices, fn slice_str -> slice_to_map(slice_str) end)
  end

  def transmit_true_slices(kv_slices) do
    Enum.map(kv_slices, fn slice ->
      tx = Map.get(slice, "tx")

      case tx do
        "1" -> Cache.set("tx", tx)
        "0" -> Cache.set("tx", tx)
        _nil -> nil
      end

      slice
    end)
  end

  def relay_decision(slices) do
    Enum.each(slices, fn slice ->
      antenna = Map.get(slice, "txant")
      frequency = Map.get(slice, "RF_frequency")

      Logger.info("#{inspect({antenna, frequency})}")

      if antenna != nil do
        Cache.get_or_set("antenna", antenna)
      end

      case Cache.get_or_set("antenna", antenna) == @ant do
        true ->
          check_frequency_and_fire_off_gpio_cmd(frequency)

        _ ->
          nil
      end
    end)
  end

  @doc """
    just need to know when on ANT2 and transmit is true
    that below 3.5 the relay needs to be off
    and above 3.5 the relay needs to be on
  """
  def check_frequency_and_fire_off_gpio_cmd(frequency) do
    float = String.to_float(frequency || "0.0")

    tx = Cache.get_or_set("tx", nil)

    if float >= 3.5 && tx == "1" do
      # turns on relay for ANT2
      Gpio.off()

      Logger.warn("Relay ON")
    end

    if float < 3.5 && float > 0.0 && tx == "1" do
      # turns off relay for ANT2
      Gpio.on()

      Logger.warn("Relay OFF")
    end
  end

  def slice_to_map(slice) do
    slice
    |> String.split(" ")
    |> build_kv_tuples_from_slice_list
    |> Enum.into(%{})
  end

  def build_kv_tuples_from_slice_list(slice_list) do
    Enum.map(slice_list, fn val ->
      kv = String.split(val, "=")

      key = Enum.at(kv, 0)
      val = Enum.at(kv, 1)

      {key, val}
    end)
  end
end
