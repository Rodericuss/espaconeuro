defmodule EspacoNeuro.Upload do
  @moduledoc """
  Handles S3 presigned URL generation for direct browser uploads.
  """

  def presign_upload(entry, socket) do
    bucket = bucket()
    key = "professionals/#{Ecto.UUID.generate()}-#{entry.client_name}"
    content_type = entry.client_type

    {:ok, url} =
      ExAws.S3.presigned_url(
        ExAws.Config.new(:s3),
        :put,
        bucket,
        key,
        opts: [
          expires_in: 3600,
          content_type: content_type
        ]
      )

    public_url = "https://#{bucket}.s3.amazonaws.com/#{key}"

    meta = %{
      uploader: "S3",
      key: key,
      url: url,
      public_url: public_url
    }

    {:ok, meta, socket}
  end

  def bucket do
    Application.get_env(:espaco_neuro, :s3_bucket) || "espaco-neuro-uploads"
  end
end
