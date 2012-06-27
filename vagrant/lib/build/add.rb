module Vagrant
  module Command
    class BuildAdd < Base

      include Vagrant::Command::BuildTools

      def execute
        options = { :os => 'all' }

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant build add <release> <build>"
          opts.separator ""

          opts.on('--os [OS]', "Operating system of the build to add") do |os|
            options[:os] = os
          end

          opts.on('-s', '--sources [source1, source2]', "Sources to search for builds (comma separated)") do |source|
            remote_sources = source.split(',')
          end
        end

        argv = parse_options(opts)
        return if !argv
        raise Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 2

        requested_release, requested_build = [argv[0], argv[1]]
        local_builds.each do |build|
          if ( build[:build] == requested_build and
               build[:release] == requested_release and
               build[:os] == options[:os] )
            puts 'Build already added. No action taken.'
            exit
          end
        end

        remote_builds.each do |build|
          if ( build[:release] == requested_release and
               build[:build] == requested_build and
               build[:os] =~ /#{options[:os]}/ )
            get_build(build[:source])
          end
        end

        print_errors
      end

      def get_build(source)
        build_name = source.split('/').last
        print "Retrieving build #{build_name}.... "
        filename = "#{build_directory}/#{build_name}"
        `curl --silent #{source} >> #{filename}`
        if $?.success?
          puts "\033[32mDone\033[0m"
        else
          File.unlink filename if File.exists? filename
          puts 'Unable to retrieve build'

          exit
        end

        print "Unpacking build #{build_name}.... "
        `tar -C #{build_directory} -xzf #{filename}`
        if $?.success?
          puts "\033[32mDone\033[0m"
        else
          File.unlink filename if File.exists? filename
          puts 'Unable to unpack build'
          exit
        end

        File.unlink filename if File.exists? filename
      end
    end
  end
end
