#!/bin/bash
set -eou pipefail

source /dev/stdin <<< "$(curl -fsSL https://raw.githubusercontent.com/aaroncoville/dotfiles/mac/script/prompt)"

brewInstall () {
    # Install brew
    if test ! $(which brew); then
    # Install the correct homebrew for each OS type
        if test "$(uname)" = "Darwin"
        then
            action "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            ok "Installed Homebrew. I can't believe I had to even do that for you."
        elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
        then
            action "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
            ok "Installed Homebrew. I can't believe I had to even do that for you."
        fi
    else
        info 'Well, color me shocked. Homebrew is already installed!?'
    fi
}

brewUpdate () {
    brew update
    ok 'Okay, I made sure homebrew is updated.'
}

zshInstall () {
    # zsh install
    # todo add in check for macOS 10.15 since zsh is default
    if test $(which zsh); then
        info "zsh already installed..."
    else
        brew install zsh
        ok 'zsh installed'
    fi
}

zshZInstall () {
    # Install z for dir searching
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-z" ]; then
        info "zsh-z already exists..."
    else
        git clone https://github.com/agkozak/zsh-z ~/.oh-my-zsh/custom/plugins/zsh-z
        ok 'zsh-z installed'
    fi
}

configureGitCompletion () {
    GIT_VERSION=`git --version | awk '{print $3}'`
    URL="https://raw.github.com/git/git/v$GIT_VERSION/contrib/completion/git-completion.bash"
    if ! curl "$URL" --silent --output "$HOME/.git-completion.bash"; then
        error "ERROR: Couldn't download git completion script. Make sure you have a working internet connection."
        fail 'git completion download failed'
    fi
    ok "git-completion for $GIT_VERSION downloaded"
}

ohmyzshInstall () {
    # oh-my-zsh install
    if [ -d ~/.oh-my-zsh/ ] ; then
    bot 'It looks like oh-my-zsh is already installed...'
    read -p "Would you like to update oh-my-zsh now? y/n " -n 1 -r
    echo ''
        if [[ $REPLY =~ ^[Yy]$ ]] ; then
        cd ~/.oh-my-zsh && git pull
            if [[ $? -eq 0 ]]
            then
                ok "Update complete..." && cd
            else
                fail "Update not complete..." >&2 cd
            fi
        fi
    else
    echo "oh-my-zsh not found, now installing oh-my-zsh..."
    echo ''
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
    ok 'oh-my-zsh installed'
    fi
}

ohmyzshPluginInstall () {
    # oh-my-zsh plugin install
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-completions" ]; then
        info 'zsh-completions already installed'
    else
        running "Now installing zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions && ok 'zsh-completions installed'
    fi
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        info 'zsh-autosuggestions already installed'
    else
        running "Now installing zsh-autosuggestions..."
        git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && ok 'zsh-autosuggestions installed'
    fi
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        info 'zsh-syntax-highlighting already installed'
    else
        running "Now installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && ok 'zsh-syntax-highlighting installed'
    fi
}

pl10kInstall () {
    # powerlevel10k install
    if [ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        info 'powerlevel10k already installed'
    else
        running "Now installing powerlevel10k..."
        git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && ok 'powerlevel10k installed'
    fi
}

tmuxTpmInstall () {
    # tmux tpm install
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        info 'tmux tpm already installed'
    else
        running "Now installing Tmux TPM manager..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ok 'tmux tpm manager installed'
    fi
}

fubectlInstall () {
    # fubectl install
    # todo - move to after ~/bin check on bootstrap
    if [ -f "$HOME/bin/fubectl.source" ]; then
        info 'fubectl.source already exists'
    else
        running "Now installing fubectl..."
        if [ ! -d "$HOME/bin" ]; then
            mkdir $HOME/bin
        fi
        curl -o "$HOME/bin/fubectl.source" -LO https://rawgit.com/kubermatic/fubectl/master/fubectl.source && ok "fubectl placed in $HOME/bin"
    fi
}

vundleInstall () {
    if [ -d "$HOME/.vim/bundle/Vundle.vim" ]; then
        info 'vundle already exists'
    else
        # vimrc vundle install
        running "Now installing vundle..."
        git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim && ok 'vundle installed'
    fi
}

pathogenInstall () {
    if [ -f "$HOME/.vim/autoload/pathogen.vim" ]; then
        info 'pathogen already installed'
    else
        mkdir -p ~/.vim/autoload ~/.vim/bundle && \
            curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim && ok 'pathogen installed'
    fi
}

nerdtreeInstall () {
    if [ -d "$HOME/.vim/bundle/nerdtree" ]; then
        info 'vim nerdtree already installed'
    else
        git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree && ok 'vim nerdtree installed'
    fi
}

wombatColorSchemeInstall () {
    if [ -f "$HOME/.vim/colors/wombat.vim" ]; then
        info "wombat color scheme already installed"
    else
        # Vim color scheme install
        git clone https://github.com/sheerun/vim-wombat-scheme.git ~/.vim/colors/wombat 
        mv ~/.vim/colors/wombat/colors/* ~/.vim/colors/
        ok 'vim wombat color scheme installed'
    fi
}

bot "Greetings meatbag. Unsurprisingly you need help setting up your system."

bot "Okay, lets get the prerequisites out of the way."
running "Setting up Homebrew..."
# brew setup
brewInstall
brewUpdate

# zsh setup
zshInstall
configureGitCompletion

# oh my zsh setup
ohmyzshInstall
zshZInstall
ohmyzshPluginInstall
pl10kInstall
tmuxTpmInstall
#fubectlInstall

#vim setup
vundleInstall
pathogenInstall
nerdtreeInstall
wombatColorSchemeInstall

# Pull down personal dotfiles
echo ''
read -p "Do you want to use aaroncoville's dotfiles? y/n" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo ''
	echo "Now pulling down aaroncoville's dotfiles..."
	git clone https://github.com/aaroncoville/dotfiles.git ~/.dotfiles
	echo ''
	cd $HOME/.dotfiles && echo "switched to .dotfiles dir..."
	echo ''
	echo "Checking out macOS branch..." && git checkout mac
	echo ''
	echo "Now configuring symlinks..." && $HOME/.dotfiles/script/bootstrap
    echo ''

    if [[ $? -eq 0 ]]
    then
        echo "Successfully configured your environment with aaroncoville's macOS dotfiles..."
    else
        echo "aaroncoville's macOS dotfiles were not applied successfully..." >&2
fi
else 
	echo ''
    echo "You chose not to apply aaroncoville's macOS dotfiles. You will need to configure your environment manually..."
	echo ''
	echo "Setting defaults for .zshrc and .bashrc..."
	echo ''
	echo "source $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc && echo "added zsh-syntax-highlighting to .zshrc..."
	echo ''
	echo "source $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc && echo "added zsh-autosuggestions to .zshrc..."
	echo ''
    echo "[ -f ~/bin/fubectl.source ] && source ~/bin/fubectl.source" >> ${ZDOTDIR:-$HOME}/.zshrc && echo "added fubectl to .zshrc..."
	
fi
