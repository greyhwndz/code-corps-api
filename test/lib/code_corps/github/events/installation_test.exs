defmodule CodeCorps.GitHub.Events.InstallationTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.Factories
  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubAppInstallation,
    GithubEvent,
    GitHub.Events.Installation,
    Repo
  }

  describe "handle/2" do
    test "creates installation for unmatched user if no user" do
      payload = load_fixture("installation_created")
      event = insert(:github_event, action: "created", type: "installation")

      assert Installation.handle(event, payload)

      github_app_installation = Repo.one(GithubAppInstallation)
      assert github_app_installation.github_id == (payload |> get_in(["installation", "id"]))
      assert github_app_installation.state == "unmatched_user"
      refute github_app_installation.user_id

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "processed"
    end

    test "creates installation initiated_on_github if user matched but installation unmatched" do
      %{"sender" => %{"id" => user_github_id}} = payload = load_fixture("installation_created")
      event = insert(:github_event, action: "created", type: "installation")

      user = insert(:user, github_id: user_github_id)

      assert Installation.handle(event, payload)

      github_app_installation = Repo.one(GithubAppInstallation)
      assert github_app_installation.github_id == (payload |> get_in(["installation", "id"]))
      assert github_app_installation.state == "initiated_on_github"
      assert github_app_installation.user_id == user.id

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "processed"
    end

    test "updates installation, creates repos, if both user and installation matched" do
      %{"sender" => %{"id" => user_github_id}, "installation" => %{"id" => installation_github_id}} = payload = load_fixture("installation_created")
      event = insert(:github_event, action: "created", type: "installation")

      user = insert(:user, github_id: user_github_id)
      github_app_installation = insert(:github_app_installation, github_id: installation_github_id, user: user)

      assert Installation.handle(event, payload)

      updated_github_app_installation = Repo.one(GithubAppInstallation)
      assert updated_github_app_installation.github_id == (payload |> get_in(["installation", "id"]))
      assert updated_github_app_installation.state == "processed"
      assert updated_github_app_installation.user_id == user.id
      assert updated_github_app_installation.github_id == installation_github_id
      assert updated_github_app_installation.id == github_app_installation.id

      updated_event = Repo.one(GithubEvent)
      assert updated_event.status == "processed"

      # TODO: Get repos from github, insert into DB
      assert false
    end
  end
end
