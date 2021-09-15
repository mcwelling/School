#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jul  7 17:01:49 2019

@author: Mac
"""

# implement map(f,L) by constructing a list

sample_list = [i for i in range(11)]

def square(number):
    result = number * number
    return result

def map(function, list_input):
    list_output = []
    for element in list_input:
        list_output.append(function(element))
    return list_output

my_list = map(square, sample_list)

print(my_list)
        