
from pyspark.sql import  *
from pyspark.sql.functions import *
from pyspark.ml.feature import HashingTF, IDF, Tokenizer
from pyspark.ml.classification import NaiveBayes
from pyspark.ml.evaluation import MulticlassClassificationEvaluator
from pyspark.ml.feature import StringIndexer, VectorAssembler,IndexToString,StopWordsRemover
from pyspark.ml.classification import RandomForestClassifier
from pyspark.ml.evaluation import BinaryClassificationEvaluator
from pyspark.sql.functions import col


# Read csv
df = spark.read.csv('/Users/ericjiang/Downloads/spam.csv', header = True )
df=df.select(df.columns[:2])

#### Transformation and cleaning
df2=df.withColumnRenamed('v1','target').withColumnRenamed('v2','email')

# Remove null values
df2=df2.where(~df2.email.isNull())

# Convert target column to numeric
df2=df2.withColumn('target',when(df2.target=='spam',1).otherwise(0))\
.withColumn('email',lower(col('email')))\
.withColumn('split_email',split(col('email'), ' '))


# Removing stop words

STOP_WORDS = ['ourselves', 'hers', 'between', 'yourself', 'but', 'again', 'there', 'about',
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


add_stopwords = STOP_WORDS
stopwordsRemover = StopWordsRemover(inputCol="split_email", outputCol="split_email2").setStopWords(add_stopwords)
df2=stopwordsRemover.transform(df2)


# Convert target to stringindex
label_stringIdx = StringIndexer(inputCol="target", outputCol="label")
df2_new=label_stringIdx.fit(df2).transform(df2)

# Fectorize words
hashingTF = HashingTF(inputCol="split_email2", outputCol="rawFeatures", numFeatures=100)
featurizedData = hashingTF.transform(df2_new)


# Split train and test data
[training_data, test_data] = featurizedData.randomSplit([0.8, 0.2])
training_data.cache()
test_data.cache()




# Naive Bayes
nb = NaiveBayes(smoothing=1.0,featuresCol='rawFeatures', labelCol='label',modelType='multinomial')
# train the model
model = nb.fit(training_data)
# select example rows to display.
predictions = model.transform(test_data)



# Evaluate with ROC
evaluator = BinaryClassificationEvaluator(labelCol="target")
print('Test Area Under ROC', 1-evaluator.evaluate(predictions))
#0.8552561538793538



# Print out confusion matrix
predictions.crosstab('target','prediction').show()
+-----------------+---+---+
|target_prediction|0.0|1.0|
+-----------------+---+---+
|                1| 79| 63|
|                0|956| 23|
+-----------------+---+---+


# Random forest
# Create an initial RandomForest model.
rf = RandomForestClassifier(labelCol="label", featuresCol="rawFeatures",numTrees=30)

# Train model with Training Data
rfModel = rf.fit(training_data)

predictions2=rfModel.transform(test_data)


### Evaluating the model
evaluator = BinaryClassificationEvaluator(labelCol="label")
print('Test Area Under ROC', evaluator.evaluate(predictions2))
#0.9497690946496158


# Print out confusion matrix
predictions2.crosstab('target','prediction').show()

+-----------------+---+---+
|target_prediction|0.0|1.0|
+-----------------+---+---+
|                1|124| 18|
|                0|979|  0|
+-----------------+---+---+
