#!/bin/bash

while getopts "c" arg; do
  case $arg in
  c)    COPY_BACK=True;;
  *)    exit 1
  esac
done

WORKING_DIR=/working

if [ -d /${WORKING_DIR}/source/_posts ]; then
  source /root/.nvm/nvm.sh

  cp -r /${WORKING_DIR}/source/_posts /root/blog/source/
  cd /root/blog
  npx gulp deploy

  if [ "x$COPY_BACK" == "xTrue" ]; then
    cp -r public /${WORKING_DIR}/.
  fi
else
  echo "There is no post under /${WORKING_DIR}/source/_posts..."
fi
