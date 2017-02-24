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
    |> load_text_elements
  end

  defp load_text_elements(image = %Image{code: code, ratio: ratio,
                                         image: %{width: width,
                                         pixels: pixels}}) do
    pixels
    |> Enum.map(fn pixel ->
      IO.inspect pixel
    end)
  end

  defp normalize_code(code) do
    code
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
