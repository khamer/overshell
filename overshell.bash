## This snippet prevents overshell from doing anything when not running interactively.
case $- in
	*i*) ;;
	*) return;;
esac

## Make typing 'cd' optional
shopt -s autocd

## Look for simple spelling mistakes when changing directories and fix them.
shopt -s cdspell
shopt -s dirspell

## Allow * to match dot-files.
shopt -s dotglob

## Allow for extended bash regex
shopt -s extglob

## Allow for ** to recursively match.
shopt -s globstar

## Add the current directory to the path.
export PATH=$PATH:.

source $HOME/.overshell/lib/overshell
