defmodule CodeCorps.GitHub.Installation do
  @moduledoc """
  Used to perform installation actions on the GitHub API
  Also defines a GitHub.Installation struct
  """

  alias CodeCorps.{
    GitHub.APIError,
    GithubAppInstallation,
    User
  }

  alias CodeCorps.GitHub

  @doc """
  Lists repositories accessible to the user for an installation

  https://developer.github.com/v3/apps/installations/#list-repositories-accessible-to-the-user-for-an-installation
  """
  @spec repositories(User.t, GithubAppInstallation.t) :: {:ok, list} | {:error, APIError.t}
  def repositories(%User{github_auth_token: github_auth_token}, %GithubAppInstallation{github_id: installation_id}) do
    endpoint = "user/installations/#{installation_id}/repositories"
    case GitHub.Request.retrieve(endpoint, [access_token: github_auth_token]) do
      {:error, %CodeCorps.GitHub.APIError{} = error} -> {:error, error}
      {:ok, %{"total_count" => _, "repositories" => repositories}} -> {:ok, repositories}
    end
  end
end
