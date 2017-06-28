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

  alias Ecto.Changeset

  @doc """
  Handles an "Installation" GitHub Webhook event

  The general idea is
  - marked the passed in event as "processing"
  - do the work
  - marked the passed in event as "processed" or "errored"
  """
  def handle(%GithubEvent{action: "created"} = event, payload) do
    event
    |> start_event_processing()
    |> do_handle(payload)
    |> stop_event_processing(event)
  end

  defp start_event_processing(%GithubEvent{} = event) do
    event |> Changeset.change(%{status: "processing"}) |> Repo.update()
  end

  defp do_handle({:ok, %GithubEvent{}}, %{"installation" => installation_attrs, "sender" => sender_attrs}) do
    case {sender_attrs |> find_user, installation_attrs |> find_installation} do
      {nil, nil} -> create_unmatched_user_installation(installation_attrs)
      {%User{} = user, nil} -> create_installation_initiated_on_github(user, installation_attrs)
      {%User{} = user, %GithubAppInstallation{} = github_app_installation} -> update_installation(user, github_app_installation)
    end
  end

  defp stop_event_processing({:ok, %GithubAppInstallation{}}, %GithubEvent{} = event) do
    event |> Changeset.change(%{status: "processed"}) |> Repo.update
  end

  defp stop_event_processing(_, %GithubEvent{} = event) do
    event |> Changeset.change(%{status: "errored"}) |> Repo.update
  end

  defp find_user(%{"id" => github_id}), do: User |> Repo.get_by(github_id: github_id)

  defp find_installation(%{"id" => github_id}), do: GithubAppInstallation |> Repo.get_by(github_id: github_id)

  defp create_unmatched_user_installation(%{"id" => github_id}) do
    %GithubAppInstallation{}
    |> Changeset.change(%{state: "unmatched_user", github_id: github_id})
    |> Repo.insert()
  end

  defp create_installation_initiated_on_github(%User{} = user, %{"id" => github_id}) do
    %GithubAppInstallation{}
    |> Changeset.change(%{state: "initiated_on_github", github_id: github_id})
    |> Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  defp update_installation(%User{} = user, %GithubAppInstallation{} = github_app_installation) do
    github_app_installation
    |> start_app_processing()
    |> process_repos()
    |> stop_app_processing()
  end

  defp start_app_processing(%GithubAppInstallation{} = github_app_installation) do
    github_app_installation
    |> Changeset.change(%{state: "processing"})
    |> Repo.update()
  end

  defp process_repos({:ok, %GithubAppInstallation{} = github_app_installation}) do
    # TODO: Implement this part
    {:ok, github_app_installation}
  end

  defp stop_app_processing({:ok, %GithubAppInstallation{} = github_app_installation}) do
    github_app_installation
    |> Changeset.change(%{state: "processed"})
    |> Repo.update()
  end
end
