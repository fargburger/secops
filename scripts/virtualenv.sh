#!/usr/bin/env bash

# vim: filetype=sh:tabstop=2:shiftwidth=2:expandtab

readonly SCRIPT_NAME=$(basename $0)
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd $SCRIPT_DIR/.. && pwd)"


###
# First, check for direnv support
###
readonly DIRENV_CMD=`which direnv`
if [[ -n "$DIRENV_CMD" ]]; then
  if [ -f "$ROOT_DIR/.envrc" ]; then
    echo ""
    echo "This machine has direnv installed."
    echo "  And the .envrc file exists."
    echo "    So no need to use this script to manage your python virtual environment"
    echo ""
    exit
  else
    echo ""
    echo "This machine has direnv installed."
    echo "  But the .envrc file is missing."
    echo "    You may want to re-consider using direnv to manage your python virtual environment"
    echo ""
  fi
fi


##############
# What follows is the same as what would go into a .envrc file
# It's based loosely on https://www.digitalocean.com/community/tutorials/how-to-manage-python-with-pyenv-and-direnv
##############


###
# Gather information about our environment
###
readonly POETRY_CMD=`which poetry`
readonly PYENV_CMD=`which pyenv`


###
# Brass tacks
###

# check if python version is set in current dir. And if so,
# this indicates pyenv was used at some point.
if [ -f ".python-version" ] ; then
  readonly PYENV_VERSION=$(cat ".python-version")

  # using pyenv, install a local python version
  if [ -n "$PYENV_CMD" ] ; then
    pyenv local "$PYENV_VERSION"
    pyenv_used="true"
  else
    echo "WARNING: Found .python-version file, but pyenv doesn't appear to be installed."
    echo ""
    echo "Exiting before finishing!!!"
    exit
  fi
fi

# attempt to use poetry to manage virtual environment
if [ -f "pyproject.toml" ]; then
  if [ -n "$POETRY_CMD" ] ; then
    echo ""
    echo "Installing virtualenv using Poetry"
    echo ""
    poetry install
    poetry env info
  else
    echo ""
    echo "WARNING: Found pyproject.toml file, but poetry doesn't appear to be installed."
    echo ""
    echo "Exiting before finishing!!!"
    exit
  fi

# no poetry configuration, so use tried & true venv/virtualenv
elif [ ! -d ".venv" ] ; then
  echo ""
  echo "Installing virtualenv using venv/virtualenv"

  if [ -n "pyenv_used" ]; then
    # if we didn't install `py2venv` for python 2.x, we would need to use
    # `virtualenv`, which you would have to install separately.
    echo ""
    echo "Using pyenv's python to create .venv"
    python -m venv .venv
  else
    python3_cmd=`which python3`
    if [ -n "$python3_cmd" ] ; then
      echo ""
      echo "Using system's python3 to create .venv"
      python3 -m venv .venv
    else
      echo ""
      echo "Using system's python to create .venv"
      echo ""
      echo "Warning: You should really upgrade to python3!!!"
      python -m virtualenv .venv
    fi
  fi

  if [ -f "requirements.txt" ]; then
    echo ""
    echo "Installing project dependencies from requirements.txt file"
    echo ""
    pip install -r requirements.txt
  fi

   echo ""
   echo "Activating $(python -V) virtualenv"
   source .venv/bin/activate
fi # using poetry or venv

