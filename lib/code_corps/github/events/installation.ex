defmodule CodeCorps.GitHub.Events.Installation do
  @moduledoc """
  In charge of dealing with "Installation" GitHub Webhook events
  """

  alias CodeCorps.{
    GithubAppInstallation,
    GithubEvent,
    Repo,
    User
  }

  import Ecto.Query, only: [where: 3]

  @doc """
  Handles an "Installation" GitHub Webhook event

  The general idea is
  - marked the passed in event as "processing"
  - do the work
  - marked the passed in event as "processed" or "errored"
  """
  def handle(%GithubEvent{action: "created"}, %{"installation" => %{"id" => installation_id}, "sender" => %{"id" => user_id}}) do
    # check if a user with the GitHub account in the `sender` exists
    case user_exists?(user_id) do
      %User{} = user -> IO.inspect(user) # match installation
      nil -> IO.inspect("no user") # create installation
    end

    # if no such user exists, then create an installation with
    # `unmatched_user`

    # if a user exists, but no matching GithubAppInstallation, then
    # create one with `initiated_on_github`

    # if the user and GitHubAppInstallation match, then update the
    # installation to processing and fetch all the repos from the API
    # to display on the project integrations page
  end

  def handle(%GithubEvent{}, _payload), do: :not_fully_implemented

  defp user_exists?(github_id) do
    User
    |> where([u], u.github_id == ^github_id)
    |> Repo.one
  end
end
