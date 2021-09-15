#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jul  7 17:25:47 2019

@author: Mac
"""

# implement map(f, L) using yield

sample_list = [i for i in range(11)]

def square(number):
    result = number * number
    return result

def map(function, list_input):
    for element in list_input:
        yield function(element)

my_obj = map(square, sample_list)

print(list(my_obj))