require 'sinatra/base'
require 'sinatra/jsonp'
require 'logger'
require_relative '../voteatx.rb'

module VoteATX

  class Service < Sinatra::Base   

    # Initialization performed at service start-up.
    # 
    # Environment parameters to override configuration settings:
    #
    # APP_ROOT - Root directory of the application.
    # APP_DATABASE - Path to database file.
    # APP_DEBUG - If set, logging set to DEBUG level, which logs SQL operations.
    #
    configure do
      log = Logger.new($stderr)
      log.progname = self.name
      log_level = (ENV['APP_DEBUG'] ? "DEBUG" : "INFO")
      log.level = Logger.const_get(log_level)

      log.info "environment=#{settings.environment}"
      log.info "log level=#{log_level}"

      set :root, ENV['APP_ROOT'] || VoteATX::BASEDIR
      log.info "root=#{settings.root}"

      database = ENV['APP_DATABASE'] || "#{settings.root}/voteatx.db"
      log.info "database=#{database}"
      @@app = VoteATX::Finder.new(:database => database, :log => log)

      log.info "configuration complete"
    end


    # Helper methods for request handling.
    helpers Sinatra::Jsonp
    helpers do  

      def search(params)
        lat = nil
        lng = nil
        juris = nil
        query_opts = {}

        params.each do |k, v|
          k = k.to_sym
          case k
          when :latitude, :lat
            lat = v.to_f
          when :longitude, :lng
            lng = v.to_f
          when :juris
            juris = v
          when :time, :max_distance, :max_locations
            query_opts[k] = v
          end
        end

        return [400, "\"lat\" undefined"] if lat.nil?
        return [400, "\"lng\" undefined"] if lng.nil?
        return [400, "\"juris\" undefined"] if juris.nil?

        result = @@app.search(lat, lng, juris, query_opts)

        content_type :json
        jsonp result
      end

    end


    before do
      @params = {}
      env = request.env
      @params.merge!(env['rack.request.form_hash']) unless env['rack.request.form_hash'].empty?
      @params.merge!(env['rack.request.query_hash']) unless env['rack.request.query_hash'].empty?
    end

    get '/search' do
      search(@params)
    end

    post '/search' do
      search(@params)
    end

    get '/district/precinct/:juris/:id' do
      juris = VoteATX::Jurisdiction.get(@@app.db, params["juris"])
      raise Sinatra::NotFound if juris.nil?
      district = VoteATX::District::Precinct.get(@@app.db, juris, params["id"])
      raise Sinatra::NotFound if district.nil?
      jsonp district.to_h
    end

    get '/district/city_council/:juris/:id' do
      juris = VoteATX::Jurisdiction.get(@@app.db, params["juris"])
      raise Sinatra::NotFound if juris.nil?
      district = VoteATX::District::CityCouncil.get(@@app.db, juris, params["id"])
      raise Sinatra::NotFound if district.nil?
      jsonp district.to_h
    end

    run! if app_file == $0

  end # Service
end # VoteATX
