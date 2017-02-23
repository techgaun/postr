defmodule Postr.PageController do
  use Postr.Web, :controller

  def index(conn, params) do
    render conn, "index.html"
  end
end
