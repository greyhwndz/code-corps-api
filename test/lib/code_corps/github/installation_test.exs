defmodule CodeCorps.GitHub.InstallationTest do
  @moduledoc false

  use CodeCorps.GitHubCase

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubAppInstallation, User, GitHub.Installation
  }

  @user %User{github_auth_token: "foo"}
  @installation %GithubAppInstallation{github_id: "bar"}
  @user_repositories load_fixture("user_repositories")

  @tag bypass: %{"/user/installations/bar/repositories" => {200, @user_repositories}}
  describe "repositories/2" do
    test "makes a request to get the user's repositories for an installation" do
      assert Installation.repositories(@user, @installation) == {:ok, @user_repositories |> Map.get("repositories")}
    end
  end
end
