dep 'iptables configured' do
  met? do
    Babushka::Renderable.new("/etc/iptables.rules").from?(dependency.load_path.parent / "iptables/rules.erb")
  end

  meet do
    render_erb dependency.load_path.parent / "iptables/rules.erb", to: "/etc/iptables.rules"
  end

  after do
    log_shell "loading iptables rules", "iptables-restore < /etc/iptables.rules"
  end
end
