Install git:

    apt-get update
    apt-get install git

Install Ruby using rbenv and ruby-build:

    apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev
    git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
    echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    rbenv install 2.1.5 # (after restarting the shell)
    rbenv global 2.1.5
    gem install bundler

Install babushka:

    git clone https://github.com/benhoskings/babushka.git ~/.babushka
    ln -s ~/.babushka/bin/babushka.rb /usr/local/bin/babushka

Deploy:

    sh deploy.sh
