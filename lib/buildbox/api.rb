require 'faraday'
require 'faraday_middleware'
require 'hashie/mash'

module Buildbox
  class Api
    def initialize(config = Buildbox.config)
      @config = config
    end

    def worker(access_token: access_token, hostname: hostname)
      put("workers/#{access_token}", :hostname => hostname)
    end

    def scheduled_builds(project)
      get(project.scheduled_builds_url)
    end

    def update_build(build)
      put(build.url, :output => build.output, :exit_status => build.exit_status)
    end

    private

    def connection
      @connection ||= Faraday.new(:url => @config.api_endpoint) do |faraday|
        faraday.request  :json

        faraday.response :logger
        faraday.response :mashify

        # json needs to come after mashify as it needs to run before the mashify
        # middleware.
        faraday.response :json

        faraday.adapter Faraday.default_adapter
      end
    end

    def post(path, body = {})
      connection.post(path) do |request|
        request.body = body
      end.body
    end

    def put(path, body = {})
      connection.put(path) do |request|
        request.body = body
      end.body
    end

    def get(path)
      connection.get(path).body
    end
  end
end
