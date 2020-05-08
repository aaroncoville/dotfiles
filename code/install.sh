#!/bin/sh

if test ! $(which code)
then
  echo "  Installing required VS Code Extensions."
  code --install-extension juanmnl.vscode-theme-1984
  code --install-extension qinjia.seti-icons
  code --install-extension dbaeumer.vscode-eslint
  echo "  VS Code Extensions installed!"
fi
