defmodule Rumbl.Accounts do
  @moduledoc """
  The accounts context.
  """

  alias Rumbl.Accounts.User
  alias Rumbl.Repo

  def list_users do
    Repo.all(User)
  end

  def get_user(id) do
    # Enum.find(list_users(), fn map -> map.id == id end)
    Repo.get(User, id)
  end

  def get_user!(id) do
    # Enum.find(list_users(), fn map -> map.id == id end)
    Repo.get!(User, id)
  end

  def get_user_by(params) do
    #   Enum.find(list_users(), fn map ->
    #     Enum.all?(params, fn {key, val} -> Map.get(map, key) == val end)
    #   end)
    Repo.get_by(User, params)
  end

  def change_user(%User{} = user \\ %User{}) do
    User.changeset(user, %{})
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @docs"""
    Função para alterar os dados do usuário
  """
  def change_registration(%User{} = user, params) do
    with %Ecto.Changeset{valid?: true} = changeset <- User.registration_changeset(user, params) do
      Repo.update(changeset)
    else
      %Ecto.Changeset{valid?: false} = invalid ->
        invalid
    end
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_by_user_and_pass(username, given_pass) do
    user = get_user_by(username: username)

    cond do
      user && Pbkdf2.verify_pass(given_pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        # isso server para prevenir ataque de tempo
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end
end
