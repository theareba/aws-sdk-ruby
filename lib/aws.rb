module Aws

  # @api private
  GEM_ROOT = File.dirname(File.dirname(__FILE__))

  # @api private
  SRC = File.join(GEM_ROOT, 'lib', 'aws')

  @config = {}

  autoload :Credentials, "#{SRC}/credentials"
  autoload :CredentialProviderChain, "#{SRC}/credential_provider_chain"
  autoload :EmptyStructure, "#{SRC}/empty_structure"
  autoload :EndpointProvider, "#{SRC}/endpoint_provider"
  autoload :Errors, "#{SRC}/errors"
  autoload :InstanceProfileCredentials, "#{SRC}/instance_profile_credentials"
  autoload :PageableResponse, "#{SRC}/pageable_response"
  autoload :PagingProvider, "#{SRC}/paging_provider"
  autoload :RestBodyHandler, "#{SRC}/rest_body_handler"
  autoload :Resource, "#{SRC}/resource"
  autoload :Resources, "#{SRC}/resources"
  autoload :Service, "#{SRC}/service"
  autoload :SharedCredentials, "#{SRC}/shared_credentials"
  autoload :Structure, "#{SRC}/structure"
  autoload :TreeHash, "#{SRC}/tree_hash"
  autoload :Util, "#{SRC}/util"
  autoload :VERSION, "#{SRC}/version"

  # @api private
  module Api
    autoload :Customizer, "#{SRC}/api/customizer"
    autoload :DocExample, "#{SRC}/api/doc_example"
    autoload :Documentor, "#{SRC}/api/documentor"
    autoload :Manifest, "#{SRC}/api/manifest"
    autoload :ManifestBuilder, "#{SRC}/api/manifest_builder"
    autoload :ServiceCustomizations, "#{SRC}/api/service_customizations"
  end

  # @api private
  module Json
    autoload :Builder, "#{SRC}/json/builder"
    autoload :ErrorHandler, "#{SRC}/json/error_handler"
    autoload :Parser, "#{SRC}/json/parser"
    autoload :RestHandler, "#{SRC}/json/rest_handler"
    autoload :RpcBodyHandler, "#{SRC}/json/rpc_body_handler"
    autoload :RpcHeadersHandler, "#{SRC}/json/rpc_headers_handler"
    autoload :SimpleBodyHandler, "#{SRC}/json/simple_body_handler"
  end

module Plugins
    autoload :Credentials, "#{SRC}/plugins/credentials"
    autoload :DynamoDBExtendedRetries, "#{SRC}/plugins/dynamodb_extended_retries"
    autoload :EC2CopyEncryptedSnapshot, "#{SRC}/plugins/ec2_copy_encrypted_snapshot"
    autoload :GlacierAccountId, "#{SRC}/plugins/glacier_account_id"
    autoload :GlacierApiVersion, "#{SRC}/plugins/glacier_api_version"
    autoload :GlacierChecksums, "#{SRC}/plugins/glacier_checksums"
    autoload :GlobalConfiguration, "#{SRC}/plugins/global_configuration"
    autoload :RegionalEndpoint, "#{SRC}/plugins/regional_endpoint"
    autoload :ResponsePaging, "#{SRC}/plugins/response_paging"
    autoload :RetryErrors, "#{SRC}/plugins/retry_errors"
    autoload :S3BucketDns, "#{SRC}/plugins/s3_bucket_dns"
    autoload :S3CompleteMultipartUploadFix, "#{SRC}/plugins/s3_complete_multipart_upload_fix"
    autoload :S3GetBucketLocationFix, "#{SRC}/plugins/s3_get_bucket_location_fix"
    autoload :S3Md5s, "#{SRC}/plugins/s3_md5s"
    autoload :S3Redirects, "#{SRC}/plugins/s3_redirects"
    autoload :S3Signer, "#{SRC}/plugins/s3_signer"
    autoload :S3SseCpk, "#{SRC}/plugins/s3_sse_cpk"
    autoload :S3LocationConstraint, "#{SRC}/plugins/s3_location_constraint"
    autoload :SignatureV2, "#{SRC}/plugins/signature_v2"
    autoload :SignatureV3, "#{SRC}/plugins/signature_v3"
    autoload :SignatureV4, "#{SRC}/plugins/signature_v4"
    autoload :SQSQueueUrls, "#{SRC}/plugins/sqs_queue_urls"
    autoload :SWFReadTimeouts, "#{SRC}/plugins/swf_read_timeouts"
    autoload :UserAgent, "#{SRC}/plugins/user_agent"

    module Protocols
      autoload :JsonRpc, "#{SRC}/plugins/protocols/json_rpc"
      autoload :Query, "#{SRC}/plugins/protocols/query"
      autoload :RestJson, "#{SRC}/plugins/protocols/rest_json"
      autoload :RestXml, "#{SRC}/plugins/protocols/rest_xml"
    end

  end

  # @api private
  module Query
    autoload :Handler, "#{SRC}/query/handler"
    autoload :Param, "#{SRC}/query/param"
    autoload :ParamBuilder, "#{SRC}/query/param_builder"
    autoload :ParamList, "#{SRC}/query/param_list"
  end

  # @api private
  module Signers
    autoload :Base, "#{SRC}/signers/base"
    autoload :Handler, "#{SRC}/signers/handler"
    autoload :S3, "#{SRC}/signers/s3"
    autoload :V2, "#{SRC}/signers/v2"
    autoload :V3, "#{SRC}/signers/v3"
    autoload :V4, "#{SRC}/signers/v4"
  end

  # @api private
  module Xml
    autoload :Builder, "#{SRC}/xml/builder"
    autoload :ErrorHandler,  "#{SRC}/xml/error_handler"
    autoload :Parser, "#{SRC}/xml/parser"
    autoload :RestHandler, "#{SRC}/xml/rest_handler"
  end

  class << self

    # @return [Hash] Returns a hash of default configuration options shared
    #   by all constructed clients.
    attr_reader :config

    # @param [Hash] config
    def config=(config)
      if Hash === config
        @config = config
      else
        raise ArgumentError, 'configuration object must be a hash'
      end
    end

    # Adds a plugin to every AWS client class.  This registers the plugin
    # with each versioned client for each service.
    # @param [Plugin] plugin
    # @return [void]
    def add_plugin(plugin)
      service_classes.values.each do |svc_class|
        svc_class.add_plugin(plugin)
      end
    end

    # Removes a plugin to from AWS client class.  This removes the plugin
    # from each versioned client for each service.
    # @param [Plugin] plugin
    # @return [void]
    def remove_plugin(plugin)
      service_classes.values.each do |svc_class|
        svc_class.remove_plugin(plugin)
      end
    end

    # @return [Array<Class>]
    # @api private
    def service_classes
      @service_classes ||= {}
    end

    # Registers a new service interface.  This method accepts a constant
    # (class name) for the new service class and map of API
    # versions.
    #
    #     # register a new service & API version
    #     Aws.add_service('S3', {
    #       '2006-03-01' => {
    #          'api' => '/path/to/api.json',
    #          'paginators' => '/path/to/paginators.json',
    #        }
    #     }
    #
    #     # create a versioned client
    #     Aws::S3.new
    #     #=> #<Aws::S3::V20060301>
    #
    # You can register multiple API versions for a service, and
    #
    # @param [String] name The name of the new service class.
    # @param [Hash] versions
    # @return [class<Service>]
    def add_service(name, versions = {})
      svc = const_set(name, Service.define(name.downcase.to_sym, versions))
      add_helper(svc.identifier, svc)
      svc
    end

    private

    def add_helper(method_name, svc_class)
      service_classes[method_name] = svc_class
      define_method(method_name) do |options = {}|
        svc_class.new(options)
      end
      module_function(method_name)
    end

  end

  Api::Manifest.default_manifest.services.each do |service|
    add_service(service.name, service.versions)
  end

end
