#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jul 23 21:11:20 2019

@author: Mac
"""

#inverse index method 1 (non-optimal)

from mrjob.job import MRJob
from mrjob.step import MRStep
import re
import os

WORD_RE = re.compile(r"[\w']+")

class MRMostUsedWord(MRJob):

    def mapper(self, _, filepath):
        file_contents = open(filepath,'r')
        book = str( os.path.basename(filepath))
        for line in file_contents:
            for term in WORD_RE.findall(line.strip()):
                yield [term.lower(), book], 1

    def combine_word_terms(self, term_book, count):
        yield term_book ,sum(count)
    
    def put_counts (self, selection, count):
        yield selection[0], [selection[1], sum(count)]
    
    def reducer(self, term, postings):
        P = []
        for post in postings:
            P.append(post)
        yield term, P

    def get_frequency(self, term, postings):
        string_builder = ''
        frequency = 0
        records = []
        for r in postings:
            records.append(r)
        for record in records:
            for book, count in record:
                frequency += count
        string_builder += "{0} {1} ".format(frequency,term)
        for record in records:
            for book, count in record:
                string_builder += "{0} {1}".format(book,count)
        yield None, (frequency, string_builder)
            
    ##sorted when it gets here
    def show_results(self, _, freq_term ):
        for number, letter in sorted(freq_term, reverse = True):
            yield int(number), letter

    def steps(self):
        return [
            MRStep(mapper=self.mapper,
                   combiner=self.combiner,
                   reducer=self.reducer_primary),
            MRStep(combiner=self.tracker),
            MRStep(reducer=self.reducer_secondary),
            MRStep(reducer=self.get_frequency),
            MRStep(reducer=self.show_results)
        ]


if __name__ == '__main__':
    MRMostUsedWord.run()
