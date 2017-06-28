defmodule CodeCorps.GitHub.Events.InstallationTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.Factories
  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubEvent,
    GitHub.Events.Installation
  }

  describe "handle/2" do
    test "is not implemented" do
      payload = load_fixture("installation_created")
      %{"sender" => %{"id" => user_id}} = payload
      insert(:user, github_id: user_id)
      assert Installation.handle(%GithubEvent{action: "created"}, payload) == :not_fully_implemented
    end
  end
end
