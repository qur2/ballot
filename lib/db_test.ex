defmodule DbTest do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres

  def url do
    "ecto://qur2:donut@localhost/scoreboard"
  end
end

#  Topic ?
defmodule Election do
  use Ecto.Model

  queryable "election" do
    field :title     # Defaults to type :string
    has_many :candidate, Candidate
    has_many :vote, Vote
  end

  def schulze(ranks) do
    [line, mat] = ranks
  end
end

# 
defmodule Vote do
  use Ecto.Model

  queryable "vote"  do
    field :title     # Defaults to type :string
    field :index, :integer
    field :ranks, { :array, :integer }
    field :weight,    :float, default: 0.0
    belongs_to :election, Election
  end
end

# Pretender, Option ?
defmodule Candidate do
  use Ecto.Model

  queryable "candidate" do
    field :title
    field :index, :integer
    belongs_to :election, Election
  end
end

# defmodule FindElection do
#   import Ecto.Query

#   def find_by_id(id) do
#     query = from e in Election,
#       where: e.id == ^id,
#       limit: 1
#     Repo.get query, id
#   end
# end
