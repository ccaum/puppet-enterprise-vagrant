require 'facter'

Facter.add('environment') do
  setcode do
    if File.exists? '/vagrant/shared/puppet_environment'
      IO.read '/vagrant/shared/puppet_environment'
    else
      'production'
    end
  end
end
