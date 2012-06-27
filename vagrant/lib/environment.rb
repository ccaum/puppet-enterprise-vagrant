module Vagrant
  module Command
    class Environment < Base

      def execute
        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant environment [production|development|show]"
          opts.separator ""
        end

        argv = parse_options
        return if !argv
        raise Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length != 1
        raise Errors::CLIInvalidUsage, :help => opts.help.chomp unless ['production','development','show'].include? argv[0]

        environment_file = "#{File.dirname(__FILE__)}/../shared/puppet_environment"

        if argv[0] == 'show'
          if File.exists? environment_file
            puts IO.read(environment_file)
          else
            puts 'production'
          end
        else
          print 'Setting puppet provisioning environment... '
          File.open(environment_file, 'w') { |f| f.print argv[0] }
          puts "\033[32mDone\033[0m\n\n"

          puts "(It is recommended to run 'vagrant provision' now)"
        end
      end
    end
  end
end

Vagrant.commands.register(:environment) { Vagrant::Command::Environment }
