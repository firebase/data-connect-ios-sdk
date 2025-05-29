#!/usr/bin/env bash

echo "Starting setup"

## <script src="../readability.js"></script>
## <link href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.16.0/themes/prism-okaidia.min.css" rel="stylesheet" />
## <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.16.0/components/prism-core.min.js" data-manual></script>
## <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.16.0/components/prism-bash.min.js"></script>
## <style>body {color: #272822; background-color: #272822; font-size: 0.8em;} </style>
: ==========================================
:   Introduction
: ==========================================

# This script allows you to install dev dependencies of Firebase Data Connect
# by running:
#
:   curl -sL https://firebase.tools/dataconnect | bash
#
# If you do not want to use this script, follow the manual setup instructions:
# https://firebase.google.com/docs/data-connect/quickstart?userflow=manual#prerequisites
#
# If you only want to install the Firebase CLI, see: https://firebase.tools/dataconnect

: -----------------------------------------
:  Uninstalling - default false
: -----------------------------------------

# You can uninstall the dev environment by passing the "uninstall" flag.
#
: curl -sL https://firebase.tools/dataconnect | uninstall=true bash
#
# This will remove the Firebase CLI standalone binary, some cached files and the
# browser-based IDE (if previously installed). VS Code (desktop version) and
# Node/npm won't be touched -- the script neither installs or uninstalls them.

: ==========================================
:   Source Code
: ==========================================

sorry() {
  echo
  echo "Something went wrong, local dev setup has not been finished."
  echo "Please try manual installation to setup your development environment."
  echo "https://firebase.google.com/docs/data-connect/quickstart?userflow=manual#prerequisites"
  echo

  exit 1
}

STANDALONE_INSTALL_PREFIX=$HOME/.local

# If the user asked for us to uninstall, then do so.
if [ "$uninstall" = "true" ]; then
  if [[ ! "$(firebase --tool:setup-check 2>&1)" == *bins* ]]; then
    echo "Your \"firebase\" install was done via npm, not firebase.tools."
    echo "Run \"npm uninstall -g firebase-tools\" to uninstall."
  else
    echo "-- Removing binary file..."
    rm $(which firebase)
  fi

  echo "-- Removing emulator runtimes..."
  rm -rf ~/.cache/firebase/emulators
  echo "-- Removing npm cache..."
  rm -rf ~/.cache/firebase/tools
  echo "-- Removing firebase runtime..."
  rm -rf ~/.cache/firebase/runtime

  echo "-- Removing code-server installation"
  rm -rf $STANDALONE_INSTALL_PREFIX/lib/code-server-*
  rm -rf $HOME/.cache/code-server/code-server-*
  echo "-- Removing code-server data + config"
  rm -rf ~/.local/share/code-server ~/.config/code-server

  echo "-- uninstallation finished"
  echo "-- All Done!"

  exit 0
fi

echo "**Starting**"

echo "-- Checking your machine type..."

# Now we need to detect the platform we're running on (Linux / Mac / Other)
# so we can fetch the correct binary and place it in the correct location
# on the machine.

# We use "tr" to translate the uppercase "uname" output into lowercase
UNAME=$(uname -s | tr '[:upper:]' '[:lower:]')

# Then we map the output to the names used on the Github releases page
case "$UNAME" in
    linux*)     MACHINE=linux;;
    darwin*)    MACHINE=macos;;
esac

# If we never define the $MACHINE variable (because our platform is neither Mac
# or Linux), then we can't finish our job, so just log out a helpful message
# and close.
if [ -z "$MACHINE" ]
then
    echo "Your operating system is not supported: $UNAME."
    sorry
fi

# Ditto for detecting the architecture.

uname_m=$(uname -m)
case $uname_m in
  aarch64) ARCH=arm64 ;;
  arm64) ARCH=arm64 ;;
  x86_64) ARCH=amd64 ;;
esac

if [ -z "$ARCH" ]
then
    echo "Your architecture is not supported: $uname_m."
    sorry
fi

if [ "$MACHINE" = macos ] && [ "$ARCH" = arm64 ]; then
    if ! arch -x86_64 /usr/bin/true 2> /dev/null; then
        echo '----------------------------------------------------------------------------------'
        echo 'Apple silicon detected. Rosetta is required to proceed. Attempting installation...'
        echo '----------------------------------------------------------------------------------'
        if ! softwareupdate --install-rosetta; then
            echo
            echo '-- Rosetta installation seems to have failed.'
            echo 'Please try running the script again after installing Rosetta. Or, try manual setup:'
            echo "https://firebase.google.com/docs/data-connect/quickstart?userflow=manual#prerequisites"
            exit 1
        fi
    fi
fi

echo "**StartingCodeServer**"

# Detect whether code / code-server is installed.
CODE=${CODE:-code}
if ! which "$CODE" >/dev/null 2>&1; then
  CODE=code-server
  # Install code-server if not found.
  if ! which code-server >/dev/null 2>&1; then
    echo "-- Installing code-server"
    if [ "$MACHINE" = macos ] && [ "$ARCH" = amd64 ]; then
      # Last code-server version that has macos-amd64 builds.
      curl -fsSL "https://github.com/coder/code-server/raw/d9812a5970bde37601adf9ba90f6b3d03b0e6f10/install.sh" | grep -v "Deploy code-server" | sh -s -- --prefix="$STANDALONE_INSTALL_PREFIX" --method=standalone --version=4.23.1 || sorry
    else
      curl -fsSL "https://code-server.dev/install.sh" | grep -v "Deploy code-server" | sh -s -- --prefix="$STANDALONE_INSTALL_PREFIX" --method=standalone || sorry
    fi

    CODE="$STANDALONE_INSTALL_PREFIX/bin/code-server"
    CODE_ARGS="--disable-telemetry"
  fi
  echo "-- Using code-server"
fi

if [ "$CODE"x = "code-server"x ] || [[ "$CODE" == */code-server ]]; then
  LISTEN="127.0.0.1:${PORT:-9394}"

  # Set default code-server config.
  CONFIG_DIR="$HOME/.config/code-server"
  CONFIG_YAML="$CONFIG_DIR/config.yaml"
  mkdir -p "$CONFIG_DIR"
  if ! [ -f "$CONFIG_YAML" ]; then
    echo "bind-addr: '$LISTEN'" > "$CONFIG_YAML"
    echo "auth: none" >> "$CONFIG_YAML"
    echo "cert: false" >> "$CONFIG_YAML"
    echo "open: true" >> "$CONFIG_YAML"
    echo "disable-telemetry: true"  >> "$CONFIG_YAML"
    echo "disable-getting-started-override: true"  >> "$CONFIG_YAML"
  fi
fi

echo "**EndCodeServer**"

# Now download and install the Firebase Data Connect extension.
echo "-- Installing Firebase Data Connect extension"

# First, try to uninstall the old version (with a different ID). This may exit
# with a non-zero code if it's not found and print some errors but that's okay.
"$CODE" $CODE_ARGS --uninstall-extension "firebase.firebase-vscode" >/dev/null 2>&1

if [ "$CODE"x = "code"x ] || [ "$CODE"x = "code-server"x ]; then
  "$CODE" --install-extension "GoogleCloudTools.firebase-dataconnect-vscode" --force || sorry
else
  # When using an unknown fork, try downloading and installing the VSIX file.
  # This is because we're not sure which marketplace the editor is using
  # or there's a marketplace configured at all. Unfortunately, this disables
  # auto-updates (even if previously installed from a marketplace).
  echo "-- Downloading Firebase Data Connect extension"
  VSIX_URL=$(curl -fsSL "https://open-vsx.org/api/GoogleCloudTools/firebase-dataconnect-vscode" | grep -oE '"https:[^"]*\.vsix"' | grep -oE '[^"]*' | head -n 1)
  [ "$VSIX_URL"x != ""x ] || sorry

  CACHE_DIR=$HOME/.cache
  mkdir -p "$CACHE_DIR" || sorry
  VSIX_FILE="$CACHE_DIR/firebase-dataconnect-vscode.vsix"
  curl -fSL "$VSIX_URL"> "$VSIX_FILE" || sorry
  "$CODE" $CODE_ARGS --install-extension "$VSIX_FILE" --force || sorry
fi

echo "**EndFirebaseDataConnectExtension**"

echo "**StartFirebaseCLI**"

# Then install the standalone Firebase CLI build.
INSTALL_DIR="$STANDALONE_INSTALL_PREFIX/bin"

mkdir -p -- "$INSTALL_DIR" || sorry

# TODO: Update only if needed, such as introducing a version check.
DOWNLOAD_URL="https://firebase.tools/bin/$MACHINE/latest"
echo "-- Downloading Firebase CLI binary from $DOWNLOAD_URL"

# We use "curl" to download the binary with a flag set to follow redirects
# (Github download URLs redirect to CDNs) and a flag to show a progress bar.
curl -f -o "$INSTALL_DIR/firebase" -L --progress-bar $DOWNLOAD_URL || sorry

# Once the download is complete, we mark the binary file as readable
# and executable (+rx).
echo "-- Setting permissions on binary..."
chmod +rx "$INSTALL_DIR/firebase" || sorry

# If all went well, the "firebase" binary should be downloaded and executable so
# we'll run it once, asking it to print out the version. This is helpful as
# standalone firebase binaries do a small amount of setup on the initial run
# so this not only allows us to make sure we got the right version, but it
# also does the setup so the first time the developer runs the binary, it'll
# be faster.
VERSION=$("$INSTALL_DIR/firebase" --version)

# If no version is detected then clearly the binary failed to install for
# some reason, so we'll log out an error message.
if [ -z "$VERSION" ]
then
    echo "Something went wrong, firebase has not been installed."
    sorry
fi

echo "**EndFirebaseCLI**"

# In order for the user to be able to actually run the "firebase" command
# without specifying the absolute location, the INSTALL_DIR path must
# be present inside of the PATH environment variable.

echo "-- Checking your PATH variable..."
if [[ ! ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "It looks like $INSTALL_DIR isn't on your PATH."
    echo "Please add the following line to either your ~/.profile or ~/.bash_profile, then restart your terminal."
    echo ""
    echo "PATH=\$PATH:$INSTALL_DIR"
    echo ""
    echo "For more information about modifying PATHs, see https://unix.stackexchange.com/a/26059"
    echo ""
fi

echo "-- firebase-tools@$VERSION is now installed"

# Tell our extension to use the standalone CLI build by default.
export FIREBASE_BINARY="$STANDALONE_INSTALL_PREFIX/bin/firebase"
# Try our best to put it also on PATH for terminals created in the IDE.
# Running `firebase` may invoke something else or not be found if a custom
# bashrc/zshrc (e.g. nvm setup) in said terminals further modifies PATH.
export PATH="$STANDALONE_INSTALL_PREFIX/bin:$PATH"

if [ "$(pwd -P)" = "$HOME" ]; then
  SAMPLE_DIR="$HOME/.cache/firebase/placeholder"
  # Since our way of opening a particular file in code-server is unreliable,
  # make the name stand out so that developer will likely click on it.
  README_RELPATH="FIREBASE_INSTRUCTIONS.md"
  mkdir -p "$SAMPLE_DIR"
  README="$SAMPLE_DIR/$README_RELPATH"
  echo '# Editor setup successful!' > "$README"
  echo 'To get started with Firebase Data Connect, open a folder via **Menu > File > Open Folder...**' >> "$README"
  echo 'Then, click the Firebase Data Connect logo from the left panel.' >> "$README"
  echo >> "$README"
  echo 'A project directory is required for development. (You may create a blank new one if needed.)' >> "$README"
  echo 'For more information, see: https://firebase.google.com/docs/data-connect/quickstart?userflow=automatic#set_up_the_development_environment' >> "$README"
  echo '(To skip this message, `cd` to your project directory before you run the setup script.)' >> "$README"
else
  # The file must be placed within the project folder or there will be annoying
  # VS Code popups regarding opening untrusted files within a trusted folder.
  # Put it in .firebase/ to maximize the chance that it'll be gitignore'd.
  README_DIR=".firebase"
  README_RELPATH="$README_DIR/INSTRUCTIONS.md"
  README="$PWD/$README_RELPATH"
  mkdir -p "$PWD/$README_DIR"
  if [ -f "$README" ]; then
    # This file has been already created by a previous run so it's likely shown
    # to the developer already. Don't show it again.
    README=
  else
    echo '# Editor setup successful!' > "$README"
    echo >> "$README"
    echo 'To start, click the Firebase Data Connect logo from the left panel.' >> "$README"
    echo >> "$README"
    echo 'For more information, see: https://firebase.google.com/docs/data-connect/quickstart?userflow=automatic#set_up_your_project_directory' >> "$README"
  fi
fi

if [ "$CODE"x = "code-server"x ] || [[ "$CODE" == */code-server ]]; then
  # A code-server session must start with a folder, not a single file.
  FOLDER=${SAMPLE_DIR:-$PWD}
  "$CODE" $CODE_ARGS \
    --auth=none \
    --disable-update-check \
    --disable-workspace-trust \
    --disable-proxy \
    --ignore-last-opened \
    --bind-addr "$LISTEN" \
else
  OPEN_PATH="$PWD"
  if [ "$README"x != ""x ]; then
    if [ "$SAMPLE_DIR"x == ""x ]; then
      CODE_ARGS="$CODE_ARGS --goto $README_RELPATH:1"
    else
      # Open just the README file, in its own window, not a directory.
      # This prevents the developer from running firebase init without opening
      # a different directory.
      OPEN_PATH="$README"
      CODE_ARGS="$CODE_ARGS --new-window"
    fi
  fi
  # When reusing an existing window, env vars may be stale. e.g. FIREBASE_BINARY
  # may be missing. But force opening a new window seems like worse experience.
  "$CODE" $CODE_ARGS "$OPEN_PATH" || sorry
  echo
  echo '  +-------------------------------------------------------------------+'
  echo '  |  A VS Code editor window should be opened and you can start by    |'
  echo '  |  clicking the Firebase Data Connect logo in the left-panel.       |'
  echo '  |  If not, launch VS Code manually and open your project directory. |'
  echo '  +-------------------------------------------------------------------+'
  echo
fi

# ------------------------------------------
#   Notes
# ------------------------------------------
#
# This script contains hidden JavaScript which is used to improve
# readability in the browser (via syntax highlighting, etc), right-click
# and "View source" of this page to see the entire bash script!
#
# You'll also notice that we use the ":" character in the Introduction
# which allows our copy/paste commands to be syntax highlighted, but not
# ran. In bash : is equal to `true` and true can take infinite arguments
# while still returning true. This turns these commands into no-ops so
# when ran as a script, they're totally ignored.
#

