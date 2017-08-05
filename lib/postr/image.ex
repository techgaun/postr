defmodule Postr.Image do
  @moduledoc """
  Module to load and play with the image and source code merging
  """
  alias __MODULE__

  defstruct code: nil,
            image: nil,
            ratio: 0.6,
            out_width: 3150,
            out_height: 4050,
            svg: nil,
            text_elements: nil

  @doc false
  def load(fname) do
    case Imagineer.load(fname) do
      {:ok, image} -> {:ok, image}
      _ -> :error
    end
  end

  @doc false
  def merge(image, code) do
    %Image{image: image, code: normalize_code(code)}
    |> load_text_elements()
    |> generate_svg()
  end

  defp generate_svg(image) do
    """
    <svg height="#{image.out_height}" width="#{image.out_width}" viewBox="0 0 #{image.ratio * image.image.width} #{image.image.height}"
    style="font-family: 'Source Code Pro'; font-size: 1; font-weight: 700;" xmlns="http://www.w3.org/2000/svg">#{Enum.join(image.text_elements, "\n")}</svg>
    """
  end

  defp load_text_elements(image = %Image{code: code, ratio: ratio,
                                         image: %{pixels: pixels}}) do
    {elems, _} =
      pixels
      |> Enum.with_index
      |> Enum.reduce({[], code}, fn {row, row_idx}, {elems, c} ->
        {row_elems, code} = transform_row(row, row_idx, ratio, code, choose_code(c, code))
        {[row_elems | elems], code}
      end)
    %{image | text_elements: Enum.reverse(elems)}
  end

  defp transform_row(row, row_idx, ratio, full_code, code) do
    {row_elems, code} =
      row
      |> Enum.with_index
      |> Enum.reduce({[], code}, fn {pt, x}, {row_elems, code} ->
        [chr | code] = choose_code(code, full_code)
        x = x * ratio
        {build_element(x, row_idx, to_hex(pt), chr, row_elems), code}
      end)
    {Enum.reverse(row_elems), code}
  end

  defp build_element(x, y, fill, chr, []) do
    [new_text_element(x, y, fill, chr)]
  end

  defp build_element(_, _, fill, chr, [[_, _, fill, _, x1, _, y1, _, text, _, _] | t]) do
    [new_text_element(x1, y1, fill, text <> chr) | t]
  end

  defp build_element(x, y, fill, chr, [[_, _, fill1, _, x1, _, y1, _, text, _, _] | t]) do
    [new_text_element(x, y, fill, chr) | [new_text_element(x1, y1, fill1, text) | t]]
  end

  defp build_element(x, y, fill, chr, [h | t]) do
    build_element(x, y, fill, chr, [String.split(h, ["'", ">", "<"]) | t])
  end

  defp new_text_element(x, y, fill, chr) do
    "<text fill='#{fill}' x='#{x}' y='#{y}'>#{escape(chr)}</text>"
  end

  defp normalize_code(code) do
    code
    |> String.replace(~r/\s+/, " ")
    |> String.replace(~r/'/, "")
    |> String.trim()
    |> String.codepoints()
  end

  defp choose_code([], full_code), do: full_code
  defp choose_code(code, _), do: code

  defp to_hex({r, g, b, 255}), do: to_hex([r, g, b])
  defp to_hex(pixel) when is_tuple(pixel), do: pixel |> Tuple.to_list() |> to_hex()

  defp to_hex(items) when is_list(items) do
    "#" <>
    Enum.map_join(items, &(encode(&1)))
  end

  defp encode(v), do: v |> :binary.encode_unsigned() |> Base.encode16()

  defp escape(string) do
    string
    |> String.replace(">", "&gt;")
    |> String.replace("<", "&lt;")
    |> replace_ampersand
  end
  defp replace_ampersand(string), do: Regex.replace(~r/&(?!lt;|gt;|quot;)/, string, "&amp;")
end
