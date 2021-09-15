#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jun 30 12:02:43 2019

@author: Mac
"""

import string
import wget
import matplotlib.pyplot as plt

url = 'http://www.gutenberg.org/files/23/23.txt'
corpus = wget.download(url)
infile = open(corpus,'r')

freq = {}
count = 0
for c in string.ascii_lowercase:
	freq[c] = 0

for line in infile:
    for c in line.lower():
        if c >= 'a' and c <= 'z':
            freq[c] = freq[c] + 1
            count = count + 1

keys = sorted(freq)
    
# the histogram of the data
fig = plt.figure()
ax = fig.add_subplot(111)
x = range(26)
ax.bar(x, [item/count * 100 for item in freq.values()], width=0.8,
       color='g', alpha=0.5, align='center')
ax.set_xticks(x)
ax.set_xticklabels(keys)
ax.tick_params(axis='x', direction='out')
ax.set_xlim(-0.5, 25.5)
ax.yaxis.grid(True)
ax.set_ylabel('Letter Frequency by Percentage')
plt.xlabel('Letters')
plt.title('Histogram of Letter Frequency by Percentage')
plt.show()