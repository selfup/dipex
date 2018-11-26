defmodule Cache do
  def init do
    :ets.new(:dipex_cache, [
      :named_table,
      :set,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])
  end

  def get_or_set(key, val) do
    case get(key) do
      {:not_found} ->
        if val != nil, do: set(key, val)

      {:found, val} ->
        val
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

  def set(key, data) do
    true = :ets.insert(:dipex_cache, {key, data})

    data
  end

  @doc """
  Specifically built for gpio status

  If gpio status has not been set (first boot)
    and it cannot be found in ETS
    set it to the given value (nil/"on"/"off")

  If a record is found
    and the given value is not the same as the stored value
    update stored value to new value

  However if the record is found
    and the querying value is nil
    return the response

  The idea here is that you can call this with nil
    to ensure you don't update the record
    and change the gpio status

  When you call it with "on" or "off"
    and the record is different than your query of "on" or "off"
    the record is updated and the new record is returned
  """
  def get_and_or_update(key, val) do
    case get(key) do
      {:not_found} ->
        set(key, val)

      {:found, res} ->
        case val != res && val != nil do
          true -> set(key, val)
          false -> res
        end
    end
  end
end
