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

  def get_and_or_update(key, val) do
    case get(key) do
      {:not_found} ->
        set(key, val)

      {:found, res} ->
        # if a new GPIO state is needed update it
        if val != res && val != nil do
          set(key, val)
        else
          res
        end
    end
  end
end
