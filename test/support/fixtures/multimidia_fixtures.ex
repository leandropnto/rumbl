defmodule Rumbl.MultimediaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Rumbl.Multimedia` context.
  """
  alias Rumbl.Accounts
  alias Rumbl.Multimedia.Category

  @doc """
  Generate a video.
  """
  def video_fixture(%Accounts.User{} = user, attrs \\ %{}) do
    %Category{id: category_id} = Rumbl.Multimedia.create_category!("Test")

    attrs =
      Enum.into(attrs, %{
        description: "some description",
        title: "some title",
        url: "some url",
        category_id: category_id
      })

    {:ok, video} = Rumbl.Multimedia.create_video(user, attrs)

    video
  end
end
