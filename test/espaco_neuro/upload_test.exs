defmodule EspacoNeuro.UploadTest do
  use ExUnit.Case, async: true

  alias EspacoNeuro.Upload

  test "uses the available Req adapter for S3 requests" do
    assert Application.fetch_env!(:ex_aws, :http_client) == ExAws.Request.Req
  end

  test "does not attempt to delete objects outside the configured bucket" do
    assert :ok = Upload.delete_object("https://example.com/photo.jpg")
  end
end
