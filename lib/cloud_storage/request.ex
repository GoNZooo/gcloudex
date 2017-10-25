defmodule GCloudex.CloudStorage.Request do
  alias HTTPoison, as: HTTP
  alias HTTPoison.HTTPResponse
  alias GCloudex.Auth, as: Auth

  @moduledoc """
  Offers HTTP requests to be used in by the Google Cloud Storage wrapper.
  """

  defmacro __using__(_opts) do
    quote do

      @endpoint "https://www.googleapis.com/storage/v1/b/"
      @upload_endpoint "https://www.googleapis.com/upload/storage/v1/b/"
      def project_id, do: GCloudex.get_project_id

      @doc"""
      Sends an HTTP request according to the Service resource in the Google Cloud
      Storage documentation.
      """
      @spec request_service :: HTTPResponse.t
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

      @doc"""
      Sends an HTTP request without any query parameters.
      """
      @spec request(atom, binary, list(tuple), binary) :: HTTPResponse.t
      def request(verb, bucket, headers \\ [], body \\ "") do
        request_query(verb, bucket, headers, body, "", @endpoint)
      end

      @doc"""
      Sends a multipart HTTP request with the specified query parameters.
      """
      @spec multipart_request_query(atom, binary, list(tuple), binary, binary) :: HTTPResponse.t
      def multipart_request_query(verb, bucket, headers \\ [], body \\ "", parameters) do
        request_query(verb, bucket, headers, body, parameters, @upload_endpoint)
      end

      @doc"""
      Sends an HTTP request with the specified query parameters.
      """
      @spec request_query(atom, binary, list(tuple), binary, binary, binary) :: HTTPResponse.t
      def request_query(verb, bucket, headers \\ [], body \\ "", parameters, endpoint \\ @endpoint) do
        HTTP.request(
          verb,
          endpoint <> bucket <> "/o/" <> parameters,
          body,
          headers ++ [{"Authorization",
                       "Bearer #{Auth.get_token_storage(:full_control)}"}],
          []
        )
      end

      defoverridable [
        request_service: 0,
        request: 3,
        request: 4,
        request_query: 6
      ]
    end
  end
end
