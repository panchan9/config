#!/bin/bash

ask() {
  printf "$* [y/n] "
  local answer
  read answer

  case $answer in
    "yes" ) return 0 ;;
    "y"   ) return 0 ;;
    *     ) return 1 ;;
  esac
}

sectionize () {
  echo
  echo '#########################'
  echo "# $1"
  echo '#########################'
}

set -e

DOT_FILES=$(find ~/config -maxdepth 1 -type f -name '.*' -exec basename {} \;)

# make symbolic links
for f in ${DOT_FILES}; do
  if [ ! -L ~/${f} -a ! -f ~/${f} ]; then
    if ask "make symbolick link for ${f} ?"; then
      ln -sv ~/config/${f} ~/${f}
    fi
  fi
done

# install homebrew
if [ ! $(which brew) ]; then
  if ask 'install homebrew?'; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    # install homebrew bundle
    sectionize 'Homebrew Bundle'
    brew tap Homebrew/bundle
  fi
fi

# install homebrew based dependencies from Brewfile
if ask 'install homebrew based dependencies from Brewfile?'; then
  brew bundle
fi

if ask 'install GNU Core Utilities?'; then
  sectionize 'GNU Core Utilities'
  brew install coreutils
  source ~/.bash_profile

  # https://github.com/Homebrew/homebrew-dupes
  brew tap homebrew/dupes
  brew install diffutils
  brew install findutils  --with-default-names
  brew install gnu-sed    --with-default-names
  brew install gnu-tar    --with-default-names
  brew install grep       --with-default-names
  brew install gzip
  brew install gawk

  source ~/.bashrc
fi

# Python
# anyenv
if [ ! -d ~/.anyenv ]; then
  if ask 'install anyenv?'; then
    git clone https://github.com/riywo/anyenv ~/.anyenv
  fi
fi
