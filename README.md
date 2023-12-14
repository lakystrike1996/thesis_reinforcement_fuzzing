# Thesis Reinforcement Fuzzing

This repository contains all the artifacts produced for my master thesis: 

"Rainfuzz : reinforcement-learning driven heat-maps for boosting coverage-guided fuzzing"
https://www.politesi.polimi.it/handle/10589/182259

Please consider that the code provided is highly experimental, and it was not tested extensively.
This repository is just meant as a reference for people that want to run their own experiments using Rainfuzz, in order to create a baseline to evaluate similar approaches.

Please use my thesis as documentation for understanding the architecture and running the experiments successfully;

A lot of the code contained in this repository was borrowed from AFL++ (https://github.com/AFLplusplus/AFLplusplus), in particular sub-folders `./rainfuzz`, `./AFLplusplus_nomf`, `AFLplusplus`.

## ./example_experiment/run_single_experiment.sh
This example script coordinates all the components needed to run an experiment;
many parameters can be specified to customize the experiment. 
Please use this script as a starting point, and customize it to your needs.

## ./rainfuzz
This is the core program handling fuzzing functionalities, it was created starting from afl++ repository (https://github.com/AFLplusplus/AFLplusplus), last commit from afl++: f7179e44f6c46fef318b6413d9c00693c1af4602;
The changes made to the code mainly concern how the seed is mutated: every time a mutation needs to be performed, it asks the python module for the new position to mutate, we perform a number of mutations at that offset and then we provide feedback to the python module about the effectiveness of this mutations.

## ./py_mutaor
Contains the python module that implements the reinforcement-learning part. It connects to the fuzzer in order to send the next position to mutate and receive feedback (reward).

## ./scripts
Contains some utility scripts to visualize the results of the experiments

## ./AFLplusplus
Just a clean AFLplusplus instance, used in some of the experiments

## ./AFLplusplus_nomf
An instance of AFLplusplus that allows to specify maximum input size at compile-time.
Used in some experiments, within the thesis this is referred to as `aflpp_mod`

## ./example_experiment_parallel/run_single_experiment.sh
Script for the experiment where aflpp_mod and rainfuzz are run in parallel (RQ6)

## ./example_experiment_parallel_2afl/run_single_experiment.sh
Script for the experiment where 2 instances of AFL++ are run in parallel (RQ6)

## ./example_experiment_parallel_2afl_nomf_nosplice/run_single_experiment.sh
Script for the experiment where 2 instances of aflpp_mod are run in parallel (RQ6)