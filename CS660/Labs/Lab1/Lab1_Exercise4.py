#!/usr/bin/env python3

'''
Exercise 4
requirements
download a bunch of books
get a book count the number of words
and get the average lenght of words
https://stackoverflow.com/questions/7409780/reading-entire-file-in-python#7409814
https://www.geeksforgeeks.org/find-average-list-python/
http://techoverflow.in/remove-special-characters-from-a-string-in-python/python/
https://www.digitalocean.com/community/tutorials/how-to-use-string-formatters-in-python-3
'''
from pathlib import Path #used to get the contents of the file
from statistics import mean #used to get teh average word size
import urllib.request

def Main():
    #same thing as Exercise 3 but now we are getting more
    #info so we need to keep track of all the books
    #we download
    word_count = []
    mean_count = []
    success = 0
    j = 0
    while success < 1000: #I want to get 1000 successful downloads
        url = f'http://www.gutenberg.org/files/{j}/{j}-0.txt'
        j += 1
        try:
            response = urllib.request.urlopen(url)
            data = response.read()      # a `bytes` object
            text = data.decode('utf-8-sig')
        except urllib.error.HTTPError:
            continue
        except Exception as e:
            print(e)
            continue
        success += 1
        len_of_words = []
        contents = text.split(' ')
        #just to get the len of each word
        for i in contents:
            #just getting special char
            i = i.strip('\r')
            i = i.strip('\n')
            i = i.strip('\t')
            len_of_words.append(len(i))
        mean_count.append(mean(len_of_words))
        word_count.append(len(contents))
    print('average word count per book : {0:.2f}'.format(mean(word_count)))
    print('average word length         : {0:.2f}'.format(mean(mean_count)))



Main()

