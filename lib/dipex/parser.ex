defmodule Parser do
  require Logger
  require Cache

  def parse(msg) do
    msg
    |> split_msg
    |> find_slices
    |> slices_into_maps
    |> set_tx_in_cache
  end

  def split_msg(msg) do
    String.split(msg, "\n")
  end

  def find_slices(msgs) do
    Enum.filter(msgs, fn msg ->
      msg
      |> String.slice(0..15)
      |> String.contains?("|slice")
    end)
  end

  def slices_into_maps(slices) do
    Enum.map(slices, &slice_to_map(&1))
  end

  def set_tx_in_cache(mapped_slices) do
    Enum.map(mapped_slices, fn slice ->
      tx = Map.get(slice, "tx")

      case tx do
        "1" -> Cache.set("tx", tx)
        "0" -> Cache.set("tx", tx)
        _nil -> nil
      end

      slice
    end)
  end

  defp slice_to_map(slice) do
    slice
    |> String.split(" ")
    |> kv_tuples_from_slice
    |> Enum.into(%{})
  end

  defp kv_tuples_from_slice(slice_list) do
    Enum.map(slice_list, fn val ->
      kv = String.split(val, "=")

      key = Enum.at(kv, 0)
      val = Enum.at(kv, 1)

      {key, val}
    end)
  end
end
