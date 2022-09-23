defmodule RumblWeb.SessionController do
  use RumblWeb, :controller

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"username" => username, "password" => pass}}) do
    case Rumbl.Accounts.authenticate_by_user_and_pass(username, pass) do
      {:ok, user} ->
        IO.inspect(user, label: 1)

        conn
        |> RumblWeb.Auth.login(user)
        |> put_flash(:info, "Bem vindo novamente!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Nome de usuário ou senha inválidos")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> RumblWeb.Auth.logout()
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
