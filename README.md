```
pushd $HOME/.config
git clone --recursive git@github.com:jkozdon/jkozdon_config.git
ln -s $HOME/.config/jkozdon_config/zsh/zshrc $HOME/.zshrc
ln -s $HOME/.config/jkozdon_config/nvim $HOME/.config/nvim
popd
```
