#!/usr/bin/env bash
unset no_proxy ftp_proxy http_proxy https_proxy all_proxy rsync_proxy
unset NO_PROXY FTP_PROXY HTTP_PROXY HTTPS_PROXY ALL_PROXY RSYNC_PROXY
sudo apptainer build psi4_191.sif psi4_191.def
