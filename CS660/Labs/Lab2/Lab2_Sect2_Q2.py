#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jul  7 17:56:20 2019

@author: Mac
"""

# Use MRJob to count letter frequencies

import string
from mrjob.job import MRJob

class MRLetterFrequencyCount(MRJob):
    
    def mapper(self, _, line):
        line = line.replace('[^\w\s]','')
        line = line.replace(" ", "")
        line = line.lower()
        for letter in line:
            if letter in string.ascii_lowercase:
                yield str(letter), 1

    def reducer(self, key, values):
        yield key, sum(values)


if __name__ == '__main__':
    MRLetterFrequencyCount.run()