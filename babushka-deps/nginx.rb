dep 'nginx installed' do
  met? do
    package_installed? "nginx"
  end

  meet do
    install_package "nginx"
  end
end

dep 'www symlinked' do
  target = "/var/vikhyat/web/Output/Vikhyat"

  met? do
    shell("readlink /var/www") == target
  end

  meet do
    log_shell "unlinked /var/www", "unlink /var/www" if "/var/www".p.exists?
    shell "ln -s #{target} /var/www"
    log "made the symlink"
  end
end

dep 'nginx configured' do
  requires 'nginx installed'
  requires 'www symlinked'

  met? do
    Dir.glob(dependency.load_path.parent / "nginx/*.erb").map do |config|
      file = config.split('/').last.gsub('.erb', '')
      Babushka::Renderable.new("/etc/nginx/sites-enabled" / file).from? config
    end.all?
  end

  meet do
    log_shell "removed old nginx config", "rm /etc/nginx/sites-enabled/*"
    Dir.glob(dependency.load_path.parent / "nginx/*.erb").each do |config|
      file = config.split('/').last.gsub('.erb', '')
      render_erb config, to: "/etc/nginx/sites-enabled" / file
    end
  end

  after do
    shell "service nginx restart"
    log "Restarted nginx"
  end
end

dep 'nginx running' do
  requires 'nginx configured'

  met? do
    shell? "netstat -an | grep -E '^tcp.*[.:]80 +.*LISTEN'"
  end

  meet do
    sudo "service nginx start"
    log "started nginx service"
  end
end
