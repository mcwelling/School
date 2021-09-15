from mrjob.job import MRJob
from mrjob.step import MRStep
import re
import math

WORD_RE = re.compile(r"[a-z|A-Z]+")
stop_words = ['ourselves', 'hers', 'between', 'yourself', 'but', 'again', 'there', 'about', 
   'once', 'during', 'out', 'very', 'having', 'with', 'they', 'own', 'an', 'be', 'some', 'for',
   'do', 'its', 'yours', 'such', 'into', 'of', 'most', 'itself', 'other', 'off', 'is', 's', 'am', 
   'or', 'who', 'as', 'from', 'him', 'each', 'the', 'themselves', 'until', 'below', 'are', 'we', 
   'these', 'your', 'his', 'through', 'don', 'nor', 'me', 'were', 'her', 'more', 'himself', 'this', 
   'down', 'should', 'our', 'their', 'while', 'above', 'both', 'up', 'to', 'ours', 'had', 'she', 'all', 
   'no', 'when', 'at', 'any', 'before', 'them', 'same', 'and', 'been', 'have', 'in', 'will', 'on', 'does',
   'yourselves', 'then', 'that', 'because', 'what', 'over', 'why', 'so', 'can', 'did', 'not',
   'now', 'under', 'he', 'you', 'herself', 'has', 'just', 'where', 'too', 'only', 'myself', 'which',
   'those', 'i', 'after', 'few', 'whom', 't', 'being', 'if', 'theirs', 'my', 'against', 'a', 'by',
   'doing', 'it', 'how', 'further', 'was', 'here', 'than' ]


class spam_analizer(MRJob):
    def map_training_data(self, _, line):
        #file_contents = open(filepath,'r', encoding = "ISO-8859-1")
        type_of_tuple = line.split(',',1)
        holder = type_of_tuple[1].split(',', 1)
        type_of_tuple_training = type_of_tuple[0] == 'training'
        if type_of_tuple_training:
            for term in WORD_RE.findall(holder[1].strip()):
                term = term.lower()
                if term not in stop_words:
                    yield [term, holder[0], 'training'], 1
        else:
            yield [holder[1].lower(), holder[0],'confusion'], 1

    def combine_word_terms(self, term_type_matrix, count):
        yield None, [term_type_matrix[0], term_type_matrix[1], sum(count), term_type_matrix[2]]

    def reducer_make_dictionary(self, _, term_type_count_matrix):
        P = [{},{},[]]
        for term, classification, count, matrix in term_type_count_matrix:
            is_training_matrix = matrix == "training"
            if is_training_matrix:
                if(classification == "ham"):
                    P[0][term] = count
                else:
                    P[1][term] = count
            else:
                P[2].append([classification, term])
        yield P, None

    def reducer_do_calculation(self, dictionaries, _):
        spam_threshold = 0.99999
        ham_count = 4825
        spam_count = 747
        ham_probability = 0
        spam_probability = 0
        ham_keys = dictionaries[0].keys()
        spam_keys = dictionaries[1].keys()
        p_spam = spam_count / (ham_count + spam_count)
        p_ham = ham_count / (ham_count + spam_count)
        tests_counts = len(dictionaries[2])
        false_positives = 0
        false_negatives = 0
        true_positives = 0
        true_negatives = 0
        
        for classification ,line in dictionaries[2]:
            items_raw = WORD_RE.findall(line.strip())
            
            for i in items_raw:
                i = i.lower()
            
            def not_stop_words(content):
                for i in content:
                    if i not in stop_words:
                        yield i
            
            joint_spam = 1
            joint_ham = 1
            
            for i in not_stop_words(items_raw):
                if i not in spam_keys:
                    dictionaries[1][i] = 1
                if i not in ham_keys:
                    dictionaries[0][i] = 1
                joint_spam *= (dictionaries[1][i] / spam_count)
                joint_ham *= (dictionaries[0][i] / ham_count)
            
            #Naive Bayes
            spam_probability = (joint_spam * p_spam) / ((joint_spam * p_spam) + (joint_ham * p_ham))
            ham_probability = 1 - spam_probability
            #the spam threshold regulates the sensitivity of our classifier
        
            #if spam_probability > spam_threshold:
            #    yield 'spam', [line, ham_probability, spam_probability]
            #else:
            #    yield 'ham', [line, ham_probability, spam_probability]
        
            if spam_probability > spam_threshold:
                if classification == "spam":
                    true_positives += 1
                else:
                    false_positives += 1
            else:
                if classification == "ham":
                    true_negatives += 1
                else:
                    false_negatives += 1
        
        yield f"real spam {(true_positives/tests_counts)*100}", None
        yield f"real ham {(true_negatives/tests_counts)*100}", None
        yield f"false spam {(false_positives/tests_counts)*100}", None
        yield f"false ham {(false_negatives/tests_counts)*100}", None





    def steps(self):
        return [
            #this is the training data
            MRStep(
                mapper = self.map_training_data,
                reducer = self.combine_word_terms
                ),
            #we need to transpose it
            MRStep(
                reducer = self.reducer_make_dictionary
            ),
            #we then need to run it against the formula
            MRStep(
                reducer = self.reducer_do_calculation
            )
            ]

if __name__ == '__main__':
    spam_analizer.run()
