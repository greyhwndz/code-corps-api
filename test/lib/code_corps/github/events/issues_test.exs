defmodule CodeCorps.GitHub.Events.IssuesTest do
  @moduledoc false

  use ExUnit.Case, aysnc: true

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.{
    GithubEvent,
    GitHub.Events.Issues
  }

  describe "handle/2" do
    test "is not implemented" do
      payload = load_fixture("issues_opened")
      assert Issues.handle(%GithubEvent{}, payload) == :not_fully_implemented
    end
  end
end
