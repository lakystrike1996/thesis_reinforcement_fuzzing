#!/bin/bash

if [ "$#" -ne 11 ]; then
  echo "Usage: $0 [max_seed] [reward_function] [max_time] [rand_percentage] [learning_rate] [clip_param] [temperature] [buffer_length] [activation_function] [layer_size] [number_of_layers]" >&2
  exit 1
fi

binary_name="libjpegturbo"
binary_path="../libjpegturbo"
corpus_path="../libjpegturbo_corpus/"
rainfuzz_repo="../rainfuzz"
python_mutator_repo="../py_mutator"
scripts_repo="../scripts"

export AFL_NO_AFFINITY=1

#remove existing experiment files
echo "removing existing experiment files ..."
shopt -s extglob #enable pattern-matching operations
rm -rf !("run_single_experiment.sh")

#clone rainfuzz files
echo "copyng rainfuzz files ..."
cp -r $rainfuzz_repo ./

#clone scripts files
echo "copying scripts files ..."
cp -r $scripts_repo ./

#copyng python mutator's files
echo "copying python mutator's files ..."
cp -r $python_mutator_repo ./
sudo ./rainfuzz/afl-system-config

# read all the parameters
max_seed=$1
reward_function=$2
max_time=$3
rand_percentage=$4

learning_rate=$5
clip_param=$6
temperature=$7
buffer_length=$8
activation_function=$9
intermediate_layer_size=${10}
num_layers=${11}

echo "experiment \"$experiment_name\" ..."
echo "building rainfuzz with the specified parameters ..."

cd ./rainfuzz && \
    export CFLAGS='-DMAX_FILE='$max_seed'u -DRAIN_'$reward_function'=1' && \
    export AFL_NO_X86=1 && \
    PYTHON_INCLUDE=/ make clean > /dev/null && make > /dev/null
cd ..

#write experiment_info file inside the directory, specifying the parameters used for the experiment
echo "max_seed=$max_seed reward_function=$reward_function max_time=$max_time rand_percentage=$rand_percentage learning_rate=$learning_rate clip_param=$clip_param temperature=$temperature buffer_length=$buffer_length activation_function=$activation_function intermediate_layer_size=$intermediate_layer_size" > "experiment_info"

mkdir in
cp $corpus_path* ./in/
mkdir out
mkdir logs
mkdir graphs
cp ../$binary_name ./

#start python mutator server in background
echo "starting python mutator server in background ..."
echo "python ../py_mutator/mutator.py ./logs $max_seed $rand_percentage $learning_rate $clip_param $temperature $buffer_length $activation_function $intermediate_layer_size $num_layers"
python ./py_mutator/mutator.py ./logs $max_seed $rand_percentage $learning_rate $clip_param $temperature $buffer_length $activation_function $intermediate_layer_size $num_layers > mutator_out.txt 2>&1 &

sleep 15

echo "running rainfuzz for $max_time seconds ..."
./rainfuzz/afl-fuzz -d -i ./in -o ./out -m none -- ./$binary_name &
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
