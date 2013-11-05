#!/bin/bash

# Adapted from http://troy.jdmz.net/rsync/index.html

case "$SSH_ORIGINAL_COMMAND" in
    *\&*) echo "Rejected" ;;
    *\(*) echo "Rejected" ;;
    *\{*) echo "Rejected" ;;
    *\;*) echo "Rejected" ;;
    *\<*) echo "Rejected" ;;
    *\`*) echo "Rejected" ;;
    *\|*) echo "Rejected" ;;
    rsync\ --server\ -vlogDtprze.iLsf\ .\ /*) $SSH_ORIGINAL_COMMAND ;;
    *) echo "Rejected" ;;
esac 
