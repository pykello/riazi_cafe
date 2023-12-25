# riazi_cafe

## Setting up the environment

### Ubuntu

Install ruby-install:
```
wget https://github.com/postmodern/ruby-install/releases/download/v0.9.3/ruby-install-0.9.3.tar.gz
tar -xzvf ruby-install-0.9.3.tar.gz
cd ruby-install-0.9.3/
sudo make install
```

Install Requirements:
```
sudo apt-get update
sudo apt install -y pandoc direnv
ruby-install 3.1.4
```

Setup direnv:
```
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc
direnv reload
direnv allow
```

Check if ruby-install Ruby is being used:
```
which ruby
/home/hadi/.rubies/ruby-3.1.4/bin/ruby
```

## Running

1. To generate the website, run `bundle make -j16`.
2. Then run `bundle make http` and visit http://localhost:8000/.
