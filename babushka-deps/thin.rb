dep 'app bundled', :root do
  met? do
    shell? "bundle check", cd: root, log: true
  end

  meet do
    shell "bundle install | grep -v '^Using '", cd: root, log: true
  end
end

dep 'thin configured', :root, :config_path do
  met? do
    Babushka::Renderable.new(config_path / "app.yaml").from?(dependency.load_path.parent / "thin/app.yaml.erb") &&
    Babushka::Renderable.new("/etc/init.d/thin").from?(dependency.load_path.parent / "thin/init.erb") &&
      (root / "log").p.exists? &&
      (root / "tmp").p.exists?
  end

  meet do
    shell "mkdir -p /etc/thin"
    shell "mkdir -p #{root}/log"
    shell "mkdir -p #{root}/tmp"
    render_erb dependency.load_path.parent / "thin/app.yaml.erb", to: config_path / "app.yaml"
    render_erb dependency.load_path.parent / "thin/init.erb", to: "/etc/init.d/thin"
    shell "chmod +x /etc/init.d/thin"
    log "copied thin config"
  end
end

def port_used?(port_number)
  shell? "netstat -an | grep -E '^tcp.*[.:]#{port_number} +.*LISTEN'"
end

dep 'thin running' do
  app_root = "/var/vikhyat/web/Application"
  config_path = "/etc/thin"

  requires 'app bundled'.with(root: app_root)
  requires 'thin configured'.with(root: app_root, config_path: config_path)

  met? do
    (0..2).all? {|x| port_used?(3000+x) }
  end

  meet do
    shell "service thin start"
    sleep 5
    log "started thin"
  end
end
