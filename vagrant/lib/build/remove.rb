module Vagrant
  module Command
    class BuildRemove < Base

      include Vagrant::Command::BuildTools

      def execute
        options = { :os => 'all' }

        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant use <release> <build>"
          opts.separator ""

          opts.on('--os [OS]', "Operating system of the build to remove") do |os|
            options[:os] = os
          end

          opts.on('-a', '--architecture [architecture]', 'Architecture of the build to remove') do |arch|
            options[:architecture] = arch
          end
        end

        argv = parse_options(opts)
        return if !argv
        raise Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 2

        requested_release, requested_build = [argv[0], argv[1]]
        builds = get_matching_local_builds(requested_release, requested_build, options[:os], options[:architecture])
        if builds.length > 0
          builds.each { |build| `rm -rf #{build[:source]}` }
        else
          error 'No matching builds found locally.'
        end

        print_errors
      end
    end
  end
end
