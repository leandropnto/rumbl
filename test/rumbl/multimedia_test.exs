defmodule Rumbl.MultimediaTest do
  use Rumbl.DataCase

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.Category
  alias Rumbl.Multimedia.Video

  describe "Categories" do
    test "list_alphabetical_categories/0" do
      for name <- ~w(Drama Action Comedy) do
        Multimedia.create_category!(name)
      end

      alpha_names =
        for %Category{name: name} <- Multimedia.list_alphabetical_categories() do
          name
        end

      assert alpha_names == ~w(Action Comedy Drama)
    end
  end

  describe "videos" do
    import Rumbl.MultimediaFixtures
    import Rumbl.AccountsFixture

    @valid_attrs %{
      description: "some description",
      title: "some title",
      url: "some url"
    }

    @invalid_attrs %{description: nil, title: nil, url: nil}

    test "list_videos/0 returns all videos" do
      user = user_fixture()
      %Video{id: id1} = video_fixture(user)
      assert [%Video{id: ^id1}] = Multimedia.list_videos()

      %Video{id: id2} = video_fixture(user)
      assert [%Video{id: ^id1}, %Video{id: ^id2}] = Multimedia.list_videos()
    end

    test "get_video!/1 returns the video with given id" do
      owner = user_fixture()
      %Video{id: id} = video_fixture(owner)
      assert %Video{id: ^id} = Multimedia.get_video!(owner, id)
    end

    test "create_video/2 with valid data creates a video" do
      owner = user_fixture()

      category = Multimedia.create_category!("test")

      attrs = Enum.into(@valid_attrs, %{category_id: category.id})

      assert {:ok, %Video{} = video} = Multimedia.create_video(owner, attrs)
      assert video.description == "some description"
      assert video.title == "some title"
      assert video.url == "some url"
    end

    test "create_video/2 with invalid data returns error changeset" do
      owner = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Multimedia.create_video(owner, @invalid_attrs)
    end

    test "update_video/2 with valid data updates the video" do
      owner = user_fixture()
      video = video_fixture(owner)

      update_attrs = %{
        description: "some updated description",
        title: "some updated title",
        url: "some updated url"
      }

      assert {:ok, %Video{} = video} = Multimedia.update_video(video, update_attrs)
      assert video.description == "some updated description"
      assert video.title == "some updated title"
      assert video.url == "some updated url"
    end

    test "update_video/2 with invalid data returns error changeset" do
      user = user_fixture()
      %Video{id: id} = video = video_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Multimedia.update_video(video, @invalid_attrs)
      assert %Video{id: ^id} = Multimedia.get_video!(user, id)
    end

    test "delete_video/1 deletes the video" do
      owner = user_fixture()
      video = video_fixture(owner)

      assert {:ok, %Video{}} = Multimedia.delete_video(video)
      assert_raise Ecto.NoResultsError, fn -> Multimedia.get_video!(owner, video.id) end
    end

    test "change_video/1 returns a video changeset" do
      user = user_fixture()
      video = video_fixture(user)
      assert %Ecto.Changeset{} = Multimedia.change_video(video)
    end
  end
end
