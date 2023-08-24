# riazi_cafe

## Setting up the environment

### Using system package manager

```
sudo apt update
sudo apt install ruby ruby-dev ruby-bundler

bundle install
```

### Using asdf

Use asdf-vm which allows to use directory specific environments. See [README-asdf.md](./README-asdf.md)

## Running

1. To generate the website, run `make generate`.
2. Then run `make http` and visit http://localhost:8000/.
