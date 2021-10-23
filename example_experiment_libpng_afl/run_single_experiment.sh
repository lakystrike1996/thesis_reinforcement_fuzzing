#!/bin/bash

binary_name="libpng_read_fuzzer"
corpus_path="../libpng_corpus/"
rainfuzz_repo="../AFLplusplus"
dict_path="../libpng.dict"
scripts_repo="../scripts"

export AFL_NO_AFFINITY=1

#remove existing experiment files
echo "removing existing experiment files ..."
shopt -s extglob #enable pattern-matching operations
rm -rf !("run_single_experiment.sh")

#clone rainfuzz files
echo "copyng rainfuzz files ..."
cp -r $rainfuzz_repo ./

echo "copyng dict file ..."
cp -r $dict_path ./

#clone scripts files
echo "copying scripts files ..."
cp -r $scripts_repo ./

sudo ./AFLplusplus/afl-system-config

# read all the parameters
max_time=$1

echo "building rainfuzz with the specified parameters ..."

cd ./AFLplusplus && \
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
./AFLplusplus/afl-fuzz -d -i ./in -o ./out -m none -x libpng.dict -- ./$binary_name &
fuzzer_pid=$!

sleep $max_time
kill -SIGINT $fuzzer_pid || echo "somethingwrong"

cd graphs
python3 ../../scripts/plot_avg_rewards_rand.py ../logs/rewards.log ../logs/rand_rewards.log > res.txt
python3 ../../scripts/plot_navg_rewards_rand.py 10000 ../logs/rewards.log ../logs/rand_rewards.log
python3 ../../scripts/plot_rewards_rand.py ../logs/rewards.log ../logs/rand_rewards.log
python3 ../../scripts/plot_rewards.py ../logs/rewards.log
python3 ../../scripts/plot_entropy.py ../logs/entropies.log
python3 ../../scripts/plot_edges_exec.py ../out/default/plot_data
python3 ../../scripts/plot_edges_time.py ../out/default/plot_data

cd ../..
