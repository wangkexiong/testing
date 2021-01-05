#!/bin/bash

while getopts "r:m" arg; do
  case $arg in
  r)
      SYNC_ENABLE=True
      ;;
  m)
      JVM_HEAP=${OPTARG}
      ;;
  *)
      break
      ;;
  esac
done
