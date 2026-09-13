#!/usr/bin/env bash
sudo env -i PATH=$PATH HOME=$HOME USER=$USER apptainer build wannier90_develop.sif wannier90-develop.def
