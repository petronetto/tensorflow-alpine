#!/bin/sh

FILE=~/.ipython/profile_default/startup/disable-warnings.py

if [ "${WARNINGS}" = "enable" ]; then
    sed -i 's/ignore/always/' $FILE
else
    sed -i 's/always/ignore/' $FILE
fi;

exec jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --NotebookApp.token=