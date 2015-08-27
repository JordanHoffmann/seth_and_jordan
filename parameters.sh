#!/bin/bash
# -------------------------------  GENERAL  ------------------------------------------
run_name="TESTRUN"
filepath="/PATH/TO/FILES/TEST/"
dataset="dataset.xml"
firstczi="firstczi.czi"
t_start=1
t_end=4
no_angles=4
no_channels=2
no_illuminations=2
FIJIPATH="/n/home11/jhoffmann/Fiji/Fiji.app/ImageJ-linux64"
# ------------------------------ TO DO ---------------------------------------
czi2tifQ='True'
defineQ='True'
detectregQ='True'
createlogfile='True'
# ------------------------------ DECONVOLUTION ---------------------------------------
iter=15
# ------------------------------ SYSTEM REQUIREMENTS ---------------------------------------
#CZI to TIF
no_processors1=20
RAM1=32000
time_1="0-10:00"
#define multiviewdataset
no_processors2=1
RAM2=8000
time_2="0-00:10"
#detect and register
no_processors3=64
RAM3=128000
time_3="1-00:00"


























True='True'