module Vagrant
  module Command
    class BuildUse < Base

      include Vagrant::Command::BuildTools

      def execute
        options = { :os => 'all' }

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant use <release> <build>"
          opts.separator ""

          opts.on('--os [OS]', "Operating system of the build to use") do |os|
            options[:os] = os
          end

          opts.on('-a', '--architecture [architecture]', 'Architecture of the build to use') do |o|
            options[:architecture] = o
          end
        end

        argv = parse_options(opts)
        return if !argv
        raise Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 2

        requested_release, requested_build = [argv[0], argv[1]]
        builds = get_matching_local_builds(requested_release, requested_build, options[:os], options[:architecture])
        if builds.length > 0
          build = builds.first
          if builds.length > 1
            puts "There are #{builds.length} matching builds. Only the first will be used."
          end
          print 'Updating build for project...'
          `rm #{shared_directory}/pe`
          `ln -s builds/#{build[:source].split('/').last} #{shared_directory}/pe`
          puts "\033[32mDone\033[0m"
          puts '(You probably need to rebuild your VMs)'
        else
          error 'No matching builds found locally. Use *add* subcommand to add a local build.'
        end

        print_errors
      end
    end
  end
end
