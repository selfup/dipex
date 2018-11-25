defmodule Engine do
  require Logger
  require Gpio
  require Cache

  @ant "ANT2"

  def make_decision(slices) do
    Enum.each(slices, fn slice ->
      antenna = Map.get(slice, "txant")
      frequency = Map.get(slice, "RF_frequency")

      Logger.debug("slice txant=#{antenna} RF_frequency=#{frequency}")

      if antenna != nil, do: Cache.get_or_set("antenna", antenna)

      case Cache.get_or_set("antenna", antenna) == @ant do
        true ->
          check_frequency_and_fire_off_gpio_cmd(frequency)

        _ ->
          nil
      end
    end)
  end

  @doc """
  when on ANT2 and transmit is true
  below 3.5 the relay needs to be off
  above 3.5 the relay needs to be on
  """
  def check_frequency_and_fire_off_gpio_cmd(frequency) do
    float = String.to_float(frequency || "0.0")

    tx = Cache.get_or_set("tx", nil)

    Logger.info("tx=#{tx}")

    if float >= 3.5 && tx == "1" do
      # set power to HIGH on BCM PIN 17
      # turns off relay for ANT2 -> dipole mode on
      Gpio.on()

      Logger.warn("Relay OFF")
    end

    if float < 3.5 && float > 0.0 && tx == "1" do
      # set power to LOW on BCM PIN 17
      # turns on relay for ANT2 -> tophat mode on
      Gpio.off()

      Logger.warn("Relay ON")
    end
  end
end
