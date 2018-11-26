defmodule Engine do
  require Logger
  require Gpio
  require Cache

  @ant "ANT2"
  @fake_rf 9_999_999_999.999999999

  def make_decision(slices) do
    Enum.each(slices, fn slice ->
      antenna = Map.get(slice, "txant")
      frequency = Map.get(slice, "RF_frequency")

      Logger.warn("slice txant=#{antenna} RF_frequency=#{frequency}")

      if antenna != nil, do: Cache.get_or_set("antenna", antenna)

      case Cache.get_or_set("antenna", antenna) == @ant do
        true -> gpio_decision(frequency)
        _ -> nil
      end
    end)
  end

  @doc """
  When on ANT2 and transmit is true
    below 3.5 the relay needs to be on
    above 3.5 the relay needs to be off
  """
  def gpio_decision(frequency) do
    if frequency != nil do
      float = String.to_float(frequency || "#{@fake_rf}")
      tx = Cache.get_or_set("tx", nil)

      if tx == "1" do
        relay_off(float)
        relay_on(float)
      end
    end
  end

  @doc """
  Set power to HIGH on BCM PIN 17
    turns off relay for ANT2
    dipole mode on
  """
  def relay_off(float) do
    if float >= 3.5 do
      gpio_read = Cache.get_and_or_update("gpio", nil)

      if gpio_read != "on" do
        Gpio.on()
        Cache.get_and_or_update("gpio", "on")
        Logger.debug("GPIO UPDATE TO ON")
      end

      Logger.warn("RELAY OFF")
    end
  end

  @doc """
  Set power to LOW on BCM PIN 17
    turns on relay for ANT2
    tophat mode on
  """
  def relay_on(float) do
    if float < 3.5 do
      if float != @fake_rf do
        gpio_read = Cache.get_and_or_update("gpio", nil)

        if gpio_read != "off" do
          Gpio.off()
          Cache.get_and_or_update("gpio", "off")
          Logger.debug("GPIO UPDATE TO OFF")
        end

        Logger.warn("RELAY ON")
      end
    end
  end
end
