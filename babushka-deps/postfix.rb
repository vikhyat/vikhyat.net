dep 'postfix installed' do
  met? do
    package_installed? "postfix"
  end

  meet do
    debconf_set "postfix postfix/mailname", "string", "neko.vikhyat.net"
    debconf_set "postfix postfix/main_mailer_type", "select", "'Internet Site'"
    install_package "postfix"
  end
end

dep 'postfix configured' do
  met? do
    Dir.glob(dependency.load_path.parent / "postfix/*.erb").map do |config|
      file = config.split('/').last.gsub('.erb', '')
      Babushka::Renderable.new("/etc/postfix" / file).from? config
    end.all?
  end

  meet do
    Dir.glob(dependency.load_path.parent / "postfix/*.erb").each do |config|
      file = config.split('/').last.gsub('.erb', '')
      render_erb config, to: "/etc/postfix" / file
    end
  end

  after do
    log_shell "running postmap", "postmap /etc/postfix/virtual"
    log_shell "restarting postfix", "service postfix restart"
  end
end

dep 'postfix running' do
  requires 'postfix installed'
  requires 'postfix configured'
end
