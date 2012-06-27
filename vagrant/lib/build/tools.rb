module Vagrant
  module Command
    module BuildTools
      def remote_sources
        @remote_sources ||= [ 'https://pm.puppetlabs.com/puppet-enterprise/2.5/',
                              'https://pm.puppetlabs.com/puppet-enterprise/2.0/',
                              'http://pluto.puppetlabs.lan/previews/' ]
      end

      def remote_sources=(value)
        @remote_sources = remote_sources + value
      end

      def local_sources
        @local_sources ||= [ build_directory ]
      end

      def local_sources=(value)
        @local_sources = local_sources + value
      end

      def error(msg)
        @errors = Array.new unless @errors
        @errors << msg
      end

      def errors
        @errors
      end

      def print_errors
        if errors
          puts "\n\033[31mERRORS:\033[0m"
          errors.each { |e| puts "\033[31m  #{e}\033[0m" }
        end
      end

      def parse_build(build)
        parts = build.split('-')

        case parts.size
        when 4
          [ parts[2], '0', 'all', 'all']
        when 6
          if parts.last == 'all' or parts.last == 'all.tar.gz'
            [ parts[2], parts[3], 'all', 'all' ]
          else
            [ parts[2], '0', [parts[3], parts[4]].join(' '), parts[5].split('.').first ]
          end
        when 8
          [ parts[2], parts[3], [parts[5], parts[6]].join(' '), parts[7].split('.').first ]
        else
          raise "Unable to parse build: #{build}"
        end
      end

      def remote_builds
        require 'nokogiri'
        require 'open-uri'

        return @remote_builds if @remote_builds

        @remote_builds = Array.new

        remote_sources.each do |source|
          begin
            doc = Nokogiri::HTML(open(source))
          rescue SocketError
            error "\033[31mUnable to connect to remote repository #{source}\033[0m\n"
            next
          end

          doc.xpath('//a').each do |link|
            begin
              release, build, os, architecture = parse_build(link.text)
            rescue
              next
            end

            @remote_builds << { :release => release, :build => build, :os => os, :architecture => architecture, :remote => true, :source => "#{source}/#{link.text}" }
          end
        end

        @remote_builds
      end

      def local_builds
        return @local_builds if @local_builds

        @local_builds = Array.new

        local_sources.each do |source|
          Dir["#{source}/*"].each do |local_build|
            begin
              release, build, os, architecture = parse_build(local_build)
            rescue
              next
            end

            @local_builds << { :release => release, :build => build, :os => os, :architecture => architecture, :remote => false, :source => local_build}
          end
        end

        @local_builds
      end

      def shared_directory
        @shared_directory ||= "#{File.dirname(__FILE__)}/../../provisions"
      end

      def shared_directory=(value)
        @shared_directory = value
      end

      def build_directory
        @build_directory ||= "#{shared_directory}/builds"
      end

      def build_directory=(value)
        @build_directory = value
      end

      def self.latest
        return @latest if @latest
        host = "pluto.puppetlabs.lan"
        `ping -c 1 #{host}`
        raise "Cannot contact #{host}" unless $?.success?
        request = `curl http://#{host}/previews/LATEST --silent`.chomp
        return unless $?.success?
        parts = request.split('-')
        return unless parts.length > 0
        @latest = {
          :release => parts[0],
          :build => parts.length > 1 ? parts[1] : '0'
        }
      end

      def currently_used_build?(build)
        current_used_build[:release] == build[:release] \
          and current_used_build[:build] == build[:build] \
          and current_used_build[:architecture] == build[:architecture] \
          and current_used_build[:os] == build[:os]
      end

      def current_used_build
        return @current_used_build if @current_used_build
        source = File.readlink("#{shared_directory}/pe").split('/').last
        build  = source.split('/').last
        release, build, os, architecture = parse_build(build)
        @current_used_build = { :release => release, :build => build, :os => os, :architecture => architecture, :remote => true, :source => "#{shared_directory}/pe/#{build}" }
      end

      def current_used_missing?
        local_builds.each do |build|
          return false if currently_used_build? build
        end
        true
      end

      def get_matching_local_builds(release, build, os=nil, architecture=nil)
        local_builds.find_all do |local_build|
          ( local_build[:release] == release and
            local_build[:build] == build and
            (os.nil? ? true : local_build[:os] = os) and
            (architecture.nil? ? true : local_build[:architecture] == architecture) )
        end
      end

    end
  end
end
