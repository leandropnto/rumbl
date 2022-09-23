defmodule RumblWeb.VideoController do
  use RumblWeb, :controller

  alias Rumbl.Multimidia
  alias Rumbl.Multimidia.Video
  alias Rumbl.Accounts.User

  plug :load_categories when action in [:new, :create, :edit, :update]

  def index(conn, _params, current_user) do
    videos = Multimidia.list_videos(%User{} = current_user)
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params, _current_user) do
    changeset = Multimidia.change_video(%Video{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}, current_user) do
    case Multimidia.create_video(current_user, video_params) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: Routes.video_path(conn, :show, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, current_user) do
    video = Multimidia.get_video!(current_user, id)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}, current_user) do
    video = Multimidia.get_video!(current_user, id)
    changeset = Multimidia.change_video(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}, current_user) do
    video = Multimidia.get_video!(current_user, id)

    case Multimidia.update_video(video, video_params) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: Routes.video_path(conn, :show, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    video = Multimidia.get_video!(current_user, id)
    {:ok, _video} = Multimidia.delete_video(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: Routes.video_path(conn, :index))
  end

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  defp load_categories(conn, _) do
    assign(conn, :categories, Multimidia.list_alphabetical_categories())
  end
end
