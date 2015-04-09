require_relative 'constants'
require 'rest_client'

# VcoWorkflows
module VcoWorkflows
  # VcoSession is a simple wrapper for RestClient::Resource, and supports
  # GET and POST operations against the vCO API.
  class VcoSession
    # Accessor for rest-client object, primarily for testing purposes
    attr_reader :rest_resource

    # Initialize the session
    #
    # @param [String] uri URI for the vCenter Orchestrator API endpoint
    # @param [String] user User name for vCO
    # @param [String] password Password for vCO
    # @param [Boolean] verify_ssl Whether or not to verify SSL certificates
    def initialize(uri, user: nil, password: nil, verify_ssl: true)
      api_url = "#{uri.gsub(%r{\/$}, '')}/vco/api"
      RestClient.proxy = ENV['http_proxy'] # Set a proxy if present
      @rest_resource = RestClient::Resource.new(api_url,
                                                user: user,
                                                password: password,
                                                verify_ssl: verify_ssl)
    end

    # Perform a REST GET operation against the specified endpoint
    #
    # @param [String] endpoint REST endpoint to use
    # @param [Hash] headers Optional headers to use in request
    # @return [String] JSON response body
    def get(endpoint, headers = {})
      headers = { accept: :json }.merge(headers)
      begin
        @rest_resource[endpoint].get headers
      rescue RestClient::SSLCertificateNotVerified => ssl_verify_error
        ssl_verify_fail(ssl_verify_error)
      end
    end

    # Perform a REST POST operation against the specified endpoint with the
    # given data body
    #
    # @param [String] endpoint REST endpoint to use
    # @param [String] body JSON data body to post
    # @param [Hash] headers Optional headers to use in request
    # @return [String] JSON response body
    def post(endpoint, body, headers = {})
      headers = { accept: :json, content_type: :json }.merge(headers)
      begin
        @rest_resource[endpoint].post body, headers
      rescue RestClient::SSLCertificateNotVerified => ssl_verify_error
        ssl_verify_fail(ssl_verify_error)
      end
    end

    # Fail gracefully with a useful error message if SSL Verification fails
    #
    # @param [RestClient::SSLCertificatNotVerified] error
    def ssl_verify_fail(ssl_verify_error = nil)
      msg = ERR[:ssl_verify]
      msg += "\nGiven URL: #{@rest_resource.url}\n"
      msg += "Error info: #{ssl_verify_error.message}\n"
      warn(msg)
      exit(1)
    end
  end
end
