#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jul  7 18:45:23 2019

@author: Mac
"""

# Use MRJob to sort words by frequency

from mrjob.job import MRJob
from mrjob.step import MRStep
import re

WORD_RE = re.compile(r"[\w']+")

class MRMostUsedWord(MRJob):

    def mapper_get_words(self, _, line):
        for word in WORD_RE.findall(line):
            yield (word.lower(), 1)

    def combiner_count_words(self, word, counts):
        yield (word, sum(counts))

    def reducer_count_words(self, word, counts):
        yield None, (sum(counts), word)

    def reducer_sort_counts(self, _, word_counts):
        # sort and return
        for count, key in sorted(word_counts, reverse=True):
            yield ( key, int(count) )

    def steps(self):
        return [
            MRStep(mapper=self.mapper_get_words,
                   combiner=self.combiner_count_words,
                   reducer=self.reducer_count_words),
            MRStep(reducer=self.reducer_sort_counts)
        ]


if __name__ == '__main__':
    MRMostUsedWord.run()