defmodule RumblWeb.VideoView do
  use RumblWeb, :view

  def embed_video(assigns) do
    url = assigns.url

    cond do
      String.starts_with?(url, "https://www.youtube.com") ->
        base_url = "https://www.youtube.com/embed/"
        new_url = String.split(url, ~r/v=/, trim: true) |> List.last()

        ~H"""
        <iframe
          width="560"
          height="315"
          src={"#{base_url}#{new_url}"}
          title="YouTube video player"
          frameborder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowfullscreen
        >
        </iframe>
        """

      true ->
        ~H"""
        <video></video>
        """
    end
  end

  def category_select_options(categories) do
    categories
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end
end
