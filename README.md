# riazi_cafe

## Setting up the environment

### 1. Install Requirements

Ubuntu:
```
wget https://github.com/postmodern/ruby-install/releases/download/v0.9.3/ruby-install-0.9.3.tar.gz
tar -xzvf ruby-install-0.9.3.tar.gz
cd ruby-install-0.9.3/
sudo make install

sudo apt-get update
sudo apt install -y pandoc direnv
ruby-install 3.1.4
```

OS X:
```
brew install direnv pandoc ruby-install
ruby-install 3.1.4
```

### 2. Setup direnv
```
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc
cd /path/to/riazi_cafe
direnv allow
```

Check if ruby-install Ruby is being used:
```
which ruby
/home/hadi/.rubies/ruby-3.1.4/bin/ruby
```

### 3. Install gems
```
bundle install
```

## Running

1. To generate the website, run `bundle exec make -j16`.
2. Then run `bundle exec make http` and visit http://localhost:8000/.
