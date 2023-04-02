### Install asdf
```
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.3
echo ". \"$HOME/.asdf/asdf.sh\"" >> ~/.bashrc
echo ". \"$HOME/.asdf/completions/asdf.bash\"" >> ~/.bashrc
source ~/.bashrc
asdf plugin add ruby
asdf plugin add direnv
echo "direnv 2.32.2" >> ~/.tool_versions
asdf direnv setup --version latest
source ~/.bashrc
```

### Install Ruby
```
cd riazi_cafe/
direnv allow
sudo apt install  autoconf bison patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
asdf install ruby
```
