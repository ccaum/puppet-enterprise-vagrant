$:.unshift File.dirname(__FILE__)

require 'build/tools'
require 'build/add'
require 'build/list'
require 'build/use'
require 'build/remove'

module Vagrant
  module Command
    class ::Hash
      def latest?
        latest = Vagrant::Command::BuildTools::latest
        latest and latest[:release] == self[:release] and latest[:build] == self[:build]
      end
    end

    class Build < Base
      include BuildTools

      def initialize(argv, env)
        super

        @main_args, @sub_command, @sub_args = split_main_and_subcommand(argv)

        @subcommands = Registry.new
        @subcommands.register(:add)    { Vagrant::Command::BuildAdd }
        @subcommands.register(:remove) { Vagrant::Command::BuildRemove }
        @subcommands.register(:list)   { Vagrant::Command::BuildList }
        @subcommands.register(:use)    { Vagrant::Command::BuildUse }
      end

      def execute
        if @main_args.include?("-h") || @main_args.include?("--help")
          # Print the help for all the box commands.
          return help
        end

        # If we reached this far then we must have a subcommand. If not,
        # then we also just print the help and exit.
        command_class = @subcommands.get(@sub_command.to_sym) if @sub_command
        return help if !command_class || !@sub_command
        @logger.debug("Invoking command class: #{command_class} #{@sub_args.inspect}")

        # Initialize and execute the command class
        command_class.new(@sub_args, @env).execute
      end

      def help
        opts = OptionParser.new do |opts|
          opts.banner = "Usage: vagrant build <command> [<args>]"
          opts.separator ""
          opts.separator "Available subcommands:"

          # Add the available subcommands as separators in order to print them
          # out as well.
          keys = []
          @subcommands.each { |key, value| keys << key.to_s }

          keys.sort.each do |key|
            opts.separator "     #{key}"
          end

          opts.separator ""
          opts.separator "For help on any individual command run `vagrant build COMMAND -h`"
        end

        @env.ui.info(opts.help, :prefix => false)
      end
    end
  end
end

Vagrant.commands.register(:build) { Vagrant::Command::Build }
