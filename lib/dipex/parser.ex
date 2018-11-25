defmodule Parser do
  require Logger
  require Gpio

  @ant "ANT2"

  def parse(msg) do
    msg
    |> split_msg
    |> find_slices
    |> log_slices
    |> kv_slices
    |> transmit_true_slices
    |> relay_decision
  end

  # ANT2 turn on relay if frequency >= 3.5
  # ANT2 turn off relay if frequency is < 3.5
  def relay_decision(slices) do
    Enum.each(slices, fn slice ->
      antenna = Map.get(slice, "txant")
      frequency = Map.get(slice, "RF_frequency")

      IO.inspect {antenna, frequency}

      # write antenna to ETS if you ever find it
      if antenna != nil do
        get_or_set("antenna", antenna)
      end

      # then check ETS for current antenna
      case get_or_set("antenna", antenna) == @ant do
        true ->
          check_frequency_and_fire_off_gpio_cmd(frequency)
        _ ->
          nil
      end
    end)
  end

  def check_frequency_and_fire_off_gpio_cmd(frequency) do
    float = String.to_float(frequency)

    if float >= 3.5 do
      # turns on relay for ANT2
      Gpio.off()

      IO.puts "Relay ON"
    else
      # turns off relay for ANT2
      Gpio.on()

      IO.puts "Relay OFF"
    end
  end

  def transmit_true_slices(kv_slices) do
    Enum.filter(kv_slices, fn slice -> Map.get(slice, "tx") != nil end)
  end

  def kv_slices(slices) do
    Enum.map(slices, fn slice_str -> slice_to_map(slice_str) end)
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

  def split_msg(msg) do
    String.split(msg, "\n")
  end

  def find_slices(slices) do
    Enum.filter(slices, fn e -> e =~ "|slice" end)
  end

   defp get_or_set(key, ant) do
    case get(key) do
      {:not_found} ->
        set(key, ant)

      {:found, antenna} ->
        IO.inspect antenna
        antenna
    end
  end

  def get(key) do
    case :ets.lookup(:dipex_cache, key) do
      [] ->
        {:not_found}

      [{_key, data}] ->
        {:found, data}
    end
  end

  defp set(key, data) do
    true = :ets.insert(:dipex_cache, {key, data})

    data
  end

  defp log_slices(slice) do
    IO.puts "----"
    IO.inspect slice
  end
end
