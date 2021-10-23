#!/bin/bash

binary_name="libjpegturbo"
binary_path="../libjpegturbo"
corpus_path="../libjpegturbo_corpus/"
rainfuzz_repo="../rainfuzz"
AFLplusplus_nomf_repo="../AFLplusplus"
python_mutator_repo="../py_mutator"
scripts_repo="../scripts"

export AFL_NO_AFFINITY=1

#remove existing experiment files
echo "removing existing experiment files ..."
shopt -s extglob #enable pattern-matching operations
rm -rf !("run_single_experiment.sh")

#clone rainfuzz files
echo "copyng rainfuzz files ..."
cp -r $AFLplusplus_nomf_repo ./rainfuzz

echo "copyng AFLplusplus_nomf files ..."
cp -r $AFLplusplus_nomf_repo ./

#clone scripts files
echo "copying scripts files ..."
cp -r $scripts_repo ./

sudo ./rainfuzz/afl-system-config

max_time=$1


echo "building AFLplusplus_nomf with the specified parameters ..."

cd ./AFLplusplus_nomf && \
    export AFL_NO_X86=1 && \
    PYTHON_INCLUDE=/ make clean > /dev/null && make > /dev/null
cd ..

echo "building rainfuzz with the specified parameters ..."

cd ./rainfuzz && \
    export AFL_NO_X86=1 && \
    PYTHON_INCLUDE=/ make clean > /dev/null && make > /dev/null
cd ..

mkdir in
cp $corpus_path* ./in/
mkdir out
mkdir logs
mkdir graphs
cp ../$binary_name ./


echo "running rainfuzz for $max_time seconds ..."
./rainfuzz/afl-fuzz -d -i ./in -o ./out -M rainfuzz -m none -- ./$binary_name &
fuzzer_pid=$!

echo "running AFLplusplus_nomf for $max_time seconds ..."
./AFLplusplus_nomf/afl-fuzz -d -i ./in -o ./out -S AFLpp -m none -- ./$binary_name &
fuzzer_pid1=$!

sleep $max_time
kill -SIGINT $fuzzer_pid || echo "somethingwrong"
kill -SIGINT $fuzzer_pid1 || echo "somethingwrong"

cd graphs
python3 ../../scripts/plot_edges_exec.py ../out/rainfuzz/plot_data
python3 ../../scripts/plot_edges_time.py ../out/rainfuzz/plot_data

cd ../..
