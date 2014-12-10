require_relative 'config'

def mysql(command, options={})
  user = options[:user] || "root"
  pass = options[:pass] || config("mysql_#{user}_password")
  command = "#{command};" unless command.end_with?(";")
  shell "mysql -u #{user} -p#{pass} --batch --skip-column-names -e #{command.inspect}"
end

dep 'mysql installed' do
  packages = %w[mysql-server mysql-client libmysqlclient-dev]

  met? do
    packages.all? {|package| package_installed? package }
  end

  meet do
    debconf_set "mysql-server mysql-server/root_password", "password", config(:mysql_root_password)
    debconf_set "mysql-server mysql-server/root_password_again", "password", config(:mysql_root_password)
    install_packages(packages)
  end
end

dep 'mysql database', :database do
  met? do
    mysql("use #{database};")
  end

  meet do
    mysql("CREATE DATABASE #{database};")
    log "created #{database} database"
  end
end

dep 'mysql anime_graph user' do
  requires 'mysql database'.with(database: 'anime')

  met? do
    mysql("use anime;", user: "anime_graph")
  end

  meet do
    mysql("GRANT ALL PRIVILEGES ON anime.* TO 'anime_graph'@'localhost' IDENTIFIED BY '#{config(:mysql_anime_graph_password)}'")
    log "created anime_graph user"
  end
end

dep 'mysql running' do
  requires 'mysql installed'
  requires 'mysql anime_graph user'
end
