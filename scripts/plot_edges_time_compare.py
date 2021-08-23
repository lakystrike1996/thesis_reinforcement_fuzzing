from matplotlib import pyplot as plt
import sys

file_path = sys.argv[1]
file = open(file_path, "r")
x = []
y = []
for line in file.readlines()[1:]:
    s = line.split(",")

    time = int(s[0])//1000
    n_exec = int(s[11])
    edges_found = int(s[12])

    x.append(time)
    y.append(edges_found)
plt.plot(x, y, label="rain")

file_path = sys.argv[2]
file = open(file_path, "r")
x = []
y = []
for line in file.readlines()[1:]:
    s = line.split(",")

    time = int(s[0])//1000
    n_exec = int(s[11])
    edges_found = int(s[12])

    x.append(time)
    y.append(edges_found)
plt.plot(x, y, label="rand")

file_path = sys.argv[3]
file = open(file_path, "r")
x = []
y = []
for line in file.readlines()[1:]:
    s = line.split(",")

    time = int(s[0])//1000
    n_exec = int(s[11])
    edges_found = int(s[12])

    x.append(time)
    y.append(edges_found)
plt.plot(x, y, label="aflpp")

plt.legend()
plt.savefig("./edges_time_compare")
