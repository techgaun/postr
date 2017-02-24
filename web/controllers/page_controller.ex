defmodule Postr.PageController do
  use Postr.Web, :controller
  alias Postr.{Downloader, Image}

  def index(conn, %{"generate" => %{"image_url" => image_url, "source_code" => source_code}}) do
    with {:ok, fname} <- Downloader.download(image_url),
         {:ok, image} <- Image.load(fname)
    do
      Image.merge(image, source_code)
      File.rm!(fname)
      conn
      |> put_flash(:info, "Nice one")
      |> render("index.html")
    else
      _ ->
        conn
        |> put_flash(:error, "Could not download or load image :(")
        |> render("index.html")
    end
  end
  def index(conn, _params) do
    render conn, "index.html"
  end
end
