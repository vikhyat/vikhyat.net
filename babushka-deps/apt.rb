def package_installed?(name)
  shell "dpkg --get-selections | grep #{name}"
end

def packages_installed?(*names)
  names.all? {|package| package_installed? package }
end

def install_package(name)
  install_packages(name)
end

def install_packages(*names)
  shell "apt-get install -y #{names * ' '}"
  log "installed #{names * ', '}"
end

def debconf_set(key, type, value)
  shell "echo #{key} #{type} #{value} | debconf-set-selections"
end
