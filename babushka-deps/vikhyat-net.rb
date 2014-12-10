dep 'vikhyat-net' do
  requires 'iptables configured'
  requires 'nginx running'
  requires 'mysql running'
  requires 'thin running'
  requires 'ghost running'
  requires 'postfix running'
end
