#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jul  7 16:29:57 2019

@author: Mac
"""

#import wget
#import numpy as np

#url = 'http://www.gutenberg.org/files/23/23.txt'
#corpus = wget.download(url)
#infile = open(corpus,'r')

upper_bound = 15

def is_prime(n):
    if (n < 2):
        return False
    d = 2
    while d*d <= n:
        if (n % d) == 0: return False
        d = d+1 
        return True


def prime_gen(search_space):
    for number in range(search_space + 1):
        if is_prime(number):
            #print(number)
            yield number
            
prime_gen(upper_bound)
