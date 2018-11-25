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

  def get_or_set(key, ant) do
    case get(key) do
      {:not_found} ->
        set(key, ant)

      {:found, antenna} ->
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

  def set(key, data) do
    true = :ets.insert(:dipex_cache, {key, data})

    data
  end
end
