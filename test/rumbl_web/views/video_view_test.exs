defmodule RumblWeb.VideoViewTest do
  use RumblWeb.ConnCase, async: true
  import Phoenix.View
  import Rumbl.MultimediaFixtures
  import Rumbl.AccountsFixture

  test "renders index.html", %{conn: conn} do
    user = user_fixture()
    videos = [video_fixture(user), video_fixture(user), video_fixture(user)]

    content =
      render_to_string(RumblWeb.VideoView, "index.html",
        conn: conn,
        videos: videos,
        user: user
      )

    assert String.contains?(content, "Meus Vídeos")

    for video <- videos do
      assert String.contains?(content, video.title)
    end
  end

  test "renders new.html", %{conn: conn} do
    owner = user_fixture()

    changeset = Rumbl.Multimedia.change_video(%Rumbl.Multimedia.Video{})
    categories = [%Rumbl.Multimedia.Category{id: 123, name: "cats"}]

    content =
      render_to_string(RumblWeb.VideoView, "new.html",
        conn: conn,
        changeset: changeset,
        categories: categories
      )

    assert String.contains?(content, "New Video")
  end
end
