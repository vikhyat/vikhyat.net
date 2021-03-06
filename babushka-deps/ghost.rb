dep 'node installed' do
  met? do
    packages_installed? "node", "npm", "nodejs-legacy"
  end

  meet do
    install_packages "node", "npm", "nodejs-legacy"
  end
end

dep 'grunt installed' do
  met? do
    shell? "which grunt"
  end

  meet do
    shell "npm install -g grunt-cli"
  end
end

dep 'forever installed' do
  met? do
    shell? "which forever"
  end

  meet do
    shell "npm install -g forever"
  end
end

dep 'ghost installed', :root do
  requires 'node installed'
  requires 'grunt installed'

  met? do
    if root.p.exists?
      log_shell "fetching custom casper git repo", "git fetch --all", cd: root
    end
    root.p.exists? && !Babushka::GitRepo.new(root).behind?
  end

  meet do
    if root.p.exists?
      log_shell "pulling ghost", "git pull", cd: root
    else
      log_shell "cloning ghost repo", "git clone https://github.com/tryghost/Ghost.git --branch stable --single-branch #{root}"
    end

    log_shell "running npm install", "npm install", cd: root
    log_shell "running grunt init", "grunt init", cd: root
    log_shell "running grunt prod", "grunt prod", cd: root
  end
end

dep 'custom theme installed', :root do
  path = root / "content/themes/casper-custom"

  met? do
    if root.p.exists?
      log_shell "fetching custom casper git repo", "git fetch --all", cd: path
    end
    path.p.exists? && !Babushka::GitRepo.new(path).behind?
  end

  meet do
    if path.p.exists?
      log_shell "pulling custom casper theme", "git pull", cd: path
    else
      log_shell "cloning custom casper theme", "git clone https://github.com/vikhyat/Casper.git #{path}"
    end
  end

  after do
    log_shell "restarting ghost", "service ghost restart"
  end
end

dep 'ghost configured', :root do
  requires 'forever installed'
  requires 'custom theme installed'.with(root: root)

  met? do
    Babushka::Renderable.new(root / "config.js").from?(dependency.load_path.parent / "ghost/config.js.erb") &&
      Babushka::Renderable.new("/etc/init.d/ghost").from?(dependency.load_path.parent / "ghost/init.erb")
  end

  meet do
    render_erb dependency.load_path.parent / "ghost/config.js.erb", to: root / "config.js", comment: '//'
    render_erb dependency.load_path.parent / "ghost/init.erb", to: "/etc/init.d/ghost"
    shell "chmod +x /etc/init.d/ghost"
  end

  after do
    shell "service ghost restart"
    log "restarted ghost"
  end
end

dep 'ghost running' do
  requires 'ghost installed'.with(root: "/var/ghost")
  requires 'ghost configured'.with(root: "/var/ghost")
end
