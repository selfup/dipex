defmodule Engine do
  require Logger
  require Gpio
  require Cache

  @ant "ANT2"
  @fake_rf 9999999999.999999999

  def make_decision(slices) do
    Enum.each(slices, fn slice ->
      antenna = Map.get(slice, "txant")
      frequency = Map.get(slice, "RF_frequency")

      Logger.warn("slice txant=#{antenna} RF_frequency=#{frequency}")

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
    if frequency != nil do
      float = String.to_float(frequency || "#{@fake_rf}")
      tx = Cache.get_or_set("tx", nil)

      if tx == "1" do
        relay_off(float, tx)
        relay_on(float, tx)
      end
    end
  end

  def relay_off(float, tx) do
    if float >= 3.5 do
      # set power to HIGH on BCM PIN 17
      # turns off relay for ANT2 -> dipole mode on
      gpio_read = Cache.get_and_or_update("gpio", nil)

      if gpio_read != "on" do
        Gpio.on()
        Cache.get_and_or_update("gpio", "on")
        Logger.debug("GPIO UPDATE TO ON")
      end

      Logger.warn("RELAY OFF")
    end
  end

  def relay_on(float, tx) do
    # nested if for performance
    # lot of ifs with this parser
    if float < 3.5 do
      if float != @fake_rf do
        # set power to LOW on BCM PIN 17
        # turns on relay for ANT2 -> tophat mode on
        gpio_read = Cache.get_and_or_update("gpio", nil)

        if gpio_read != "off" do
          Gpio.off()
          Cache.get_and_or_update("gpio", "off")
          Logger.warn("GPIO UPDATE TO OFF")
        end

        Logger.warn("RELAY ON")
      end
    end
  end
end
