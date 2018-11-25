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

  def find_slices(slices) do
    Enum.filter(slices, fn e -> e =~ "|slice" end)
  end

  def slices_into_maps(slices) do
    Enum.map(slices, fn slice_str -> slice_to_map(slice_str) end)
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
    |> build_kv_tuples_from_slice_list
    |> Enum.into(%{})
  end

  defp build_kv_tuples_from_slice_list(slice_list) do
    Enum.map(slice_list, fn val ->
      kv = String.split(val, "=")

      key = Enum.at(kv, 0)
      val = Enum.at(kv, 1)

      {key, val}
    end)
  end
end
