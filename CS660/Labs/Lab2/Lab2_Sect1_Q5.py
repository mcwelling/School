#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jul  7 17:46:25 2019

@author: Mac
"""

# implement map(f, L) by creating an iterator

sample_list = [i for i in range(11)]

def square(number):
    result = number * number
    return result

def map(function, list_input):
    iterable = iter(list_input)
    loop = 0
    while loop < len(list_input):
        yield function(next(iterable))
        loop += 1

my_obj = map(square, sample_list)

print(list(my_obj))