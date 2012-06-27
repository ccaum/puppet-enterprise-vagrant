module Vagrant
  module Command
    class BuildList < Base

      include Vagrant::Command::BuildTools

      def execute
        options = Hash.new

        # XXX : Why do I need this?
        alias remote_sources_alias remote_sources=

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant build list"
          opts.separator ""

          opts.on('-r', '--remote', "Include builds from remote sources") do
            options[:remote] = true
          end

          opts.on('--os [OS]', "List only builds of this operating system") do |os|
            options[:os] = os
          end

          opts.on('-a', '--architecture [architecture]', 'List only builds of this architecture') do |arch|
            options[:architecture] = arch
          end

          opts.on('-s', '--sources= [source1, source2]', "Sources to search for builds (comma separated)") do |source|
            remote_sources_alias source.split(',')
          end
        end

        parse_options(opts)

        builds = Array.new
        builds += remote_builds if options[:remote]
        builds += local_builds

        if options[:os]
          builds = builds.select { |b| b[:os].split(' ').first == options[:os] }
        end

        if options[:architecture]
          builds = builds.select { |b| b[:architecture] == options[:architecture] }
        end

        layout = "%-3s%s%-10s%-8s%-14s%s%s"
        puts layout % ['L', '', 'Release', 'Build', 'OS', 'Architecture', '']
        puts '='*43

        builds.each do |build|
          colors = if build[:remote]
                     ["\033[31m", "\033[0m"]
                   elsif currently_used_build? build
                     ["\033[32m", "\033[0m"]
                   else
                     ['','']
                   end

          latest = build.latest? ? "\033[32m*\033[0m  " : ' '

          puts layout % [ latest, colors[0], build[:release], build[:build], build[:os], build[:architecture], colors[1] ]
        end

        if current_used_missing?
          error <<EOD
The currently used build is missing from the local system.
You can use the following command to cache the build locally:
# vagrant build add #{current_used_build[:release]} #{current_used_build[:build]}
EOD
        end

        error 'Unable to retrieve latest data. Perhaps you need to connect to the VPN?' unless Vagrant::Command::BuildTools::latest

        print_errors

      end
    end
  end
end
