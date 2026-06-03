#!/usr/bin/env sh
set -eu

if [ ! -x ".venv/bin/python" ]; then
    python3 -m venv .venv
fi

. .venv/bin/activate
python -m pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 127.0.0.1:8000
