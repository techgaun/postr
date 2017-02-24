defmodule Postr.Downloader do
  @moduledoc """
  Download the image from given source URL
  """
  @header [{"User-Agent", "Postr"}]

  @doc false
  def download("http" <> _ = img_url) do
    img_url
    |> HTTPoison.get(@header, recv_timeout: 30_000, timeout: 30_000)
    |> case do
      {:ok, %HTTPoison.Response{body: body}} ->
        fname = filename()
        File.write!(fname, body)
        {:ok, fname}
      _ -> :error
    end
  end
  def download(_), do: :error

  defp filename do
    "#{System.tmp_dir()}/#{System.system_time()}.png"
  end
end
