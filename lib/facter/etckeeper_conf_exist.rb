# etckeeper_conf_exists.rb

Facter.add("etckeeper_conf_exist") do
  setcode do
    if File.exist? "/etc/etckeeper/etckeeper.conf"
      true
    else
      nil
    end
  end
end
