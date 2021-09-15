#!/usr/bin/env python3

infile = open("bus.txt", 'r')
outfile = open("bus2.txt", 'w')

source = infile.read()

for i in range(100):
	for line in source:
		outfile.write(line)
