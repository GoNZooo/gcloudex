defmodule GCloudex.CloudStorage.Client do
  alias HTTPoison, as: HTTP
  alias GCloudex.Auth, as: Auth

  @type params :: [{String.t(), String.t()}] | Keyword.t()

  def project do
    GCloudex.get_project_id()
  end

  ###################
  ### GET Service ###
  ###################

  @doc """
  Lists all the buckets in the specified project.
  """
  @spec list_buckets() :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def list_buckets do
    request_service()
  end

  #####################
  ### DELETE Bucket ###
  #####################

  @doc """
  Deletes and empty bucket.
  """
  @spec delete_bucket(bucket :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def delete_bucket(bucket) do
    request(:delete, bucket, [], "")
  end

  ##################
  ### GET Bucket ###
  ##################

  @doc """
  Lists all the objects in the specified 'bucket'.
  """
  @spec list_objects(bucket :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def list_objects(bucket) do
    request(:get, bucket, [], "")
  end

  @doc """
  Lists all the objects in the specified 'bucket' using the
  given 'query_params'. The query parameters must be passed as a list of tuples
  [{param_1, value_1}, {param_2, value_2}].
  """
  @spec list_objects(bucket :: String.t(), query_params :: params()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def list_objects(bucket, query_params) do
    request_query(:get, bucket, [], "", "?" <> build_query_params(query_params))
  end

  @doc """
  Lists the specified 'bucket' ACL.
  """
  @spec get_bucket_acl(bucket :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_bucket_acl(bucket) do
    request_query(:get, bucket, [], "", "?acl")
  end

  @doc """
  Lists the specified 'bucket' CORS configuration.
  """
  @spec get_bucket_cors(bucket :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_bucket_cors(bucket) do
    request_query(:get, bucket, [], "", "?cors")
  end

  @doc """
  Lists the specified 'bucket' lifecycle configuration.
  """
  @spec get_bucket_lifecycle(bucket :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_bucket_lifecycle(bucket) do
    request_query(:get, bucket, [], "", "?lifecycle")
  end

  @doc """
  Lists the specified 'bucket' location.
  """
  @spec get_bucket_region(bucket :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_bucket_region(bucket) do
    request_query(:get, bucket, [], "", "?location")
  end

  @doc """
  Lists the specified 'bucket' logging configuration.
  """
  @spec get_bucket_logging(bucket :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_bucket_logging(bucket) do
    request_query(:get, bucket, [], "", "?logging")
  end

  @doc """
  Lists the specified 'bucket' class.
  """
  @spec get_bucket_class(bucket :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_bucket_class(bucket) do
    request_query(:get, bucket, [], "", "?storageClass")
  end

  @doc """
  Lists the specified 'bucket' versioning configuration.
  """
  @spec get_bucket_versioning(bucket :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_bucket_versioning(bucket) do
    request_query(:get, bucket, [], "", "?versioning")
  end

  @doc """
  Lists the specified 'bucket' website configuration.
  """
  @spec get_bucket_website(bucket :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_bucket_website(bucket) do
    request_query(:get, bucket, [], "", "?website")
  end

  ###################
  ### HEAD Bucket ###
  ###################

  @doc """
  Indicates if the specified 'bucket' exists or whether the request has READ
  access to it.
  """
  @spec exists_bucket(bucket :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def exists_bucket(bucket) do
    request(:head, bucket, [], "")
  end

  ##################
  ### PUT Bucket ###
  ##################

  @doc """
  Creates a bucket with the specified 'bucket' name if available. This
  function will create the bucket in the default region 'US' and with
  the default class 'STANDARD'.
  """
  @spec create_bucket(bucket :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def create_bucket(bucket) do
    headers = [{"x-goog-project-id", project()}]

    request(:put, bucket, headers, "")
  end

  @doc """
  Creates a bucket with the specified 'bucket' name if available and in
  the specified 'region'. This function will create the bucket with the
  default class 'STANDARD'.
  """
  @spec create_bucket(bucket :: String.t(), region :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def create_bucket(bucket, region) do
    headers = [{"x-goog-project-id", project()}]

    body = """
    <CreateBucketConfiguration>
      <LocationConstraint>#{region}</LocationConstraint>
    </CreateBucketConfiguration>
    """

    request(:put, bucket, headers, body)
  end

  @doc """
  Creates a bucket with the specified 'bucket' name if available and in
  the specified 'region' and with the specified 'class'.
  """
  @spec create_bucket(bucket :: String.t(), region :: String.t(), class :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def create_bucket(bucket, region, class) do
    headers = [{"x-goog-project-id", project()}]

    body = """
    <CreateBucketConfiguration>
      <LocationConstraint>#{region}</LocationConstraint>
      <StorageClass>#{class}</StorageClass>
    </CreateBucketConfiguration>
    """

    request(:put, bucket, headers, body)
  end

  @doc """
  Sets or modifies the existing ACL in the specified 'bucket'
  with the given 'acl_config' in XML format.
  """
  @spec set_bucket_acl(bucket :: String.t(), acl_config :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def set_bucket_acl(bucket, acl_config) do
    request_query(:put, bucket, [], acl_config, "?acl")
  end

  @doc """
  Sets or modifies the existing CORS configuration in the specified 'bucket'
  with the given 'cors_config' in XML format.
  """
  @spec set_bucket_cors(bucket :: String.t(), cors_config :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def set_bucket_cors(bucket, cors_config) do
    request_query(:put, bucket, [], cors_config, "?cors")
  end

  @doc """
  Sets or modifies the existing lifecyle configuration in the specified
  'bucket' with the given 'lifecycle_config' in XML format.
  """
  @spec set_bucket_lifecycle(bucket :: String.t(), lifecycle_config :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def set_bucket_lifecycle(bucket, lifecycle_config) do
    request_query(:put, bucket, [], lifecycle_config, "?lifecycle")
  end

  @doc """
  Sets or modifies the existing logging configuration in the specified
  'bucket' with the given 'logging_config' in XML format.
  """
  @spec set_bucket_logging(bucket :: String.t(), logging_config :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def set_bucket_logging(bucket, logging_config) do
    request_query(:put, bucket, [], logging_config, "?logging")
  end

  @doc """
  Sets or modifies the existing versioning configuration in the specified
  'bucket' with the given 'versioning_config' in XML format.
  """
  @spec set_bucket_versioning(bucket :: String.t(), versioning_config :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def set_bucket_versioning(bucket, versioning_config) do
    request_query(:put, bucket, [], versioning_config, "?versioning")
  end

  @doc """
  Sets or modifies the existing website configuration in the specified
  'bucket' with the given 'website_config' in XML format.
  """
  @spec set_bucket_website(bucket :: String.t(), website_config :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def set_bucket_website(bucket, website_config) do
    request_query(:put, bucket, [], website_config, "?websiteConfig")
  end

  #####################
  ### DELETE Object ###
  #####################

  @doc """
  Deletes the 'object' in the specified 'bucket'.
  """
  @spec delete_object(bucket :: String.t(), object :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def delete_object(bucket, object) do
    request_query(:delete, bucket, [], "", object)
  end

  @doc """
  Deletes the 'object' in the specified 'bucket' using the
  given 'query_params'. The query parameters must be passed as a list of tuples
  [{param_1, value_1}, {param_2, value_2}].
  """
  @spec delete_object(
          bucket :: String.t(),
          object :: String.t(),
          query_params :: params()
        ) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def delete_object(bucket, object, query_params) do
    request_query(
      :delete,
      bucket,
      [],
      "",
      concat_uri_fragments(object, build_query_params(query_params))
    )
  end

  ##################
  ### GET Object ###
  ##################

  @doc """
  Downloads the 'object' from the specified 'bucket'. The requester must have
  READ permission.
  """
  @spec get_object(bucket :: String.t(), object :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_object(bucket, object) do
    request_query(:get, bucket, [], "", concat_uri_fragments(object, ""))
  end

  @doc """
  Downloads the 'object' from the specified 'bucket' using the given
  'query_params'. The query parameters must be passed as a list of tuples
  [{param_1, value_1}, {param_2, value_2}]. The requester must have READ
  permission.
  """
  @spec get_object(
          bucket :: String.t(),
          object :: String.t(),
          query_params :: params()
        ) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_object(bucket, object, query_params) do
    request_query(
      :get,
      bucket,
      [],
      "",
      concat_uri_fragments(object, build_query_params(query_params))
    )
  end

  @doc """
  Lists the 'object' ACL from the specified 'bucket'. The requester must have
  FULL_CONTROL permission.
  """
  @spec get_object_acl(bucket :: String.t(), object :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_object_acl(bucket, object) do
    request_query(
      :get,
      bucket,
      [],
      "",
      concat_uri_fragments(object, build_query_params([{"acl", ""}]))
    )
  end

  ###################
  ### HEAD Object ###
  ###################

  @doc """
  Lists metadata for the given 'object' from the specified 'bucket'.
  """
  @spec get_object_metadata(bucket :: String.t(), object :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_object_metadata(bucket, object) do
    request_query(:head, bucket, [], "", concat_uri_fragments(object, ""))
  end

  @doc """
  Lists metadata for the given 'object' from the specified 'bucket' using the
  given 'query_params'. The query parameters must be passed as a list of tuples
  [{param_1, value_1}, {param_2, value_2}].
  """
  @spec get_object_metadata(bucket :: String.t(), object :: String.t(), params()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_object_metadata(bucket, object, query_params) do
    request_query(
      :head,
      bucket,
      [],
      "",
      concat_uri_fragments(object, build_query_params(query_params))
    )
  end

  ##################
  ### PUT Object ###
  ##################

  @doc """
  Uploads the file in the given 'filepath' to the specified 'bucket'.
  If a 'bucket_path' is specified then the filename must be included at
  the end:

    put_object "somebucket",
               "/home/user/Documents/this_file",
               "new_folder/some_other_folder/this_file",
               "application/octet-stream"

    => # This will upload the file to the directory in 'bucket_path' and
         will create the directories if they do not exist.
  """
  @spec put_object(
          bucket :: String.t(),
          filepath :: String.t(),
          bucket_path :: String.t(),
          content_type :: String.t()
        ) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def put_object(bucket, filepath, bucket_path, content_type) do
    body =
      {:multipart,
       [
         # This request does not follow the official docs from Google
         # https://cloud.google.com/storage/docs/json_api/v1/how-tos/multipart-upload
         # Few of the problems with it:
         # 1. The Content-Type is "multipart/form-data" instead of "multipart/related"
         # 2. The "name" is not passed inside a JSON object as the docs state
         # 3. Each multipart segment has "Content-Disposition" and "Content-Length" headers
         # which are not matching the docs
         # I am tired of figthing Hackney and I wish we had a better http lib based on libcurl or something else.
         {"name", "", [{"Content-Type", "application/json"}]},
         {:file, filepath, {"", []}, [{"Content-Type", content_type}]}
       ]}

    params = build_query_params([{"uploadType", "multipart"}, {"name", bucket_path}])

    multipart_request_query(:post, bucket, [], body, concat_uri_fragments("", params))
  end

  @doc """
  Copies the specified 'source_object' into the given 'new_bucket' as
  'new_object'.
  """
  @spec copy_object(
          new_bucket :: String.t(),
          new_object :: String.t(),
          source_object :: String.t()
        ) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def copy_object(new_bucket, new_object, source_object) do
    headers = [{"x-goog-copy-source", source_object}]
    request_query(:put, new_bucket, headers, new_object)
  end

  @doc """
  Sets or modifies the 'object' from the specified 'bucket' with the provided
  'acl_config' in XML format.
  """
  @spec set_object_acl(bucket :: String.t(), object :: String.t(), acl_config :: String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def set_object_acl(bucket, object, acl_config) do
    request_query(
      :put,
      bucket,
      [],
      acl_config,
      concat_uri_fragments(object, build_query_params([{"acl", ""}]))
    )
  end

  @doc """
  Sets or modifies the 'object' from the specified 'bucket' with the provided
  'acl_config' in XML format and using the given 'query_params'. The query
  parameters must be passed as a list of tuples
  [{param_1, value_1}, {param_2, value_2}].
  """
  @spec set_object_acl(bucket :: String.t(), object :: String.t(), acl_config :: String.t(), [
          {String.t(), String.t()}
        ]) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def set_object_acl(bucket, object, acl_config, query_params) do
    request_query(
      :put,
      bucket,
      [],
      acl_config,
      concat_uri_fragments(object, build_query_params([{"acl", ""}] ++ query_params))
    )
  end

  ########################
  ### HELPER FUNCTIONS ###
  ########################

  defp build_query_params(params) do
    Enum.into(params, %{}) |> URI.encode_query()
  end

  defp concat_uri_fragments(object, params) do
    (URI.encode_www_form(object) |> String.replace("+", "%20")) <> "?" <> params
  end

  @endpoint "https://www.googleapis.com/storage/v1/b/"
  @upload_endpoint "https://www.googleapis.com/upload/storage/v1/b/"
  def project_id, do: GCloudex.get_project_id()

  @doc """
  Sends an HTTP request according to the Service resource in the Google Cloud
  Storage documentation.
  """
  @spec request_service :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def request_service do
    HTTP.request(
      :get,
      @endpoint,
      "",
      [
        {"x-goog-project-id", project_id()},
        {"Authorization", "Bearer #{Auth.get_token_storage(:full_control)}"}
      ],
      []
    )
  end

  @doc """
  Sends an HTTP request without any query parameters.
  """
  @spec request(atom(), String.t(), list(tuple), String.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def request(verb, bucket, headers \\ [], body \\ "") do
    request_query(verb, bucket, headers, body, "", @endpoint)
  end

  @doc """
  Sends a multipart HTTP request with the specified query parameters.
  """
  # atom, String.t(), {:multipart, [tuple()]}, String.t()
  @spec multipart_request_query(
          verb :: atom(),
          bucket :: String.t(),
          headers :: [tuple()],
          body :: String.t() | {:multipart, [tuple()]},
          query_params :: String.t()
        ) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def multipart_request_query(verb, bucket, headers \\ [], body \\ "", parameters) do
    request_query(verb, bucket, headers, body, parameters, @upload_endpoint)
  end

  @doc """
  Sends an HTTP request with the specified query parameters.
  """
  @spec request_query(
          verb :: atom(),
          bucket :: String.t(),
          headers :: [tuple()],
          body :: String.t() | {:multipart, [tuple()]},
          parameters :: String.t(),
          endpoint :: String.t()
        ) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def request_query(
        verb,
        bucket,
        headers \\ [],
        body \\ "",
        parameters,
        endpoint \\ @endpoint
      ) do
    HTTP.request(
      verb,
      endpoint <> bucket <> "/o/" <> parameters,
      body,
      headers ++ [{"Authorization", "Bearer #{Auth.get_token_storage(:full_control)}"}],
      []
    )
  end

  defoverridable request_service: 0,
                 request: 3,
                 request: 4,
                 request_query: 6
end
