#!/bin/bash

VENV=$(poetry env info -p)
[[ -d $VENV ]] && rm -rf $VENV


PYTHON_VERSION=$(pyenv version-name)

pyenv install --skip-existing
poetry env use $HOME/.pyenv/versions/$PYTHON_VERSION/bin/python
poetry config --local virtualenvs.in-project true
poetry check
poetry install --no-root
