defmodule CodeCorps.GitHub.Webhook.Handler do
  @moduledoc """
  Receives and handles GitHub event payloads.
  """

  alias CodeCorps.{
    GithubEvent,
    GitHub.Events.Installation,
    GitHub.Events.InstallationRepositories,
    GitHub.Events.IssueComment,
    GitHub.Events.Issues,
    GitHub.Webhook.EventSupport,
    Repo
  }

  @doc """
  Handles a GitHub event based on its type.
  """
  def handle(type, id, payload) do
    with %{} = params <- build_params(type, id, payload),
         {:ok, %GithubEvent{} = event} <- params |> create_event()
    do
      event |> process_payload(payload)
    end
  end

  defp build_params(type, id, %{"action" => action, "sender" => sender}) do
    %{
      action: action,
      github_delivery_id: id,
      type: type,
      status: type |> get_status(),
      source: sender |> get_source()
    }
  end

  defp get_status(type) do
    case EventSupport.status(type) do
      :unsupported -> "unhandled"
      :supported -> "unprocessed"
    end
  end

  defp create_event(params) do
    %GithubEvent{} |> GithubEvent.changeset(params) |> Repo.insert
  end

  defp get_source(_), do: "not implemented"

  def process_payload(%GithubEvent{type: "installation"} = event, payload), do: Installation.handle(event, payload)
  def process_payload(%GithubEvent{type: "installation_repositories"} = event, payload), do: InstallationRepositories.handle(event, payload)
  def process_payload(%GithubEvent{type: "issue_comment"} = event, payload), do: IssueComment.handle(event, payload)
  def process_payload(%GithubEvent{type: "issues"} = event, payload), do: Issues.handle(event, payload)
end
