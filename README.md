# Thesis Reinforcement Fuzzing

This repository contains all the artifacts produced for my master thesis (reinforcement learning techniques applied to fuzzing)
Following a brief explaination of the content of this repository:

##./rainfuzz
this is a fork of the afl++ repository (https://github.com/AFLplusplus/AFLplusplus), last commit from afl++: f7179e44f6c46fef318b6413d9c00693c1af4602;
The changes made to the code mainly concern how the seed is mutated: every time we ask the python module for the new position to mutate, we perform a number of mutations at that offset and then we provide feedback to the python module about the effectiveness of this mutations.

##./py_mutaor
contains the python module that implements the reinforcement-learning part. It connects to the fuzzer in order to send the next position to mutate and receive feedback (reward).

##./scripts
contains some utility scripts to visualize the results of the experiments

##./run_single_experiment.sh
allows to run an experiment, many parameters can be specified to customize the experiment.
