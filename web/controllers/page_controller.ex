defmodule Postr.PageController do
  use Postr.Web, :controller
  alias Postr.{Downloader, Image}

  def index(conn, %{"generate" => %{"image_url" => image_url, "source_code" => source_code}}) do
    with {:ok, fname} <- Downloader.download(image_url),
         {:ok, image} <- Image.load(fname)
    do
      svg = Image.merge(image, source_code)
      File.rm!(fname)
      conn
      |> put_resp_content_type("image/svg+xml")
      |> put_resp_header("content-disposition",
                         ~s(attachment; filename="postr.svg"))
      |> send_resp(200, svg)
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
