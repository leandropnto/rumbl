# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Rumbl.Repo.insert!(%Rumbl.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Rumbl.Multimidia
alias Rumbl.Accounts.User
alias Rumbl.Accounts

for category <- ~w(Action Drama Romance Comedy Sci-fi) do
  Multimidia.create_category!(category)
end

user_attrs = %{
  "username" => "leandropnto",
  "name" => "Leandro Pinto"
}

{:ok, user} = Accounts.create_user(user_attrs)

Accounts.change_registration(user, %{"password" => "123456"})
