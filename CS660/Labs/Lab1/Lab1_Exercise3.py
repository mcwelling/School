#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jun 30 18:06:58 2019

@author: Mac
"""

import wget
import numpy as np

url = 'http://www.gutenberg.org/files/23/23.txt'
corpus = wget.download(url)
infile = open(corpus,'r')
doc = infile.read()
word_vec = doc.split()

std_word_dict = {word.lower(): len(word.lower()) for word in word_vec}
word_count = len(std_word_dict.keys())
avg_word_length = np.array(list(std_word_dict.values())).mean()

print("Total Word Count: {n} | Average Word Length: {s}".format(n=word_count, s=avg_word_length))