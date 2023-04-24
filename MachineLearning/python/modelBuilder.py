import nltk
import numpy as np
import pandas as pd
import tensorflow as tf
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from nltk.tokenize import word_tokenize

def df_to_dataset(dataframe):
  batch_size= 32
  #create new dataframe variable and assign to dataframe that was passed
  df = dataframe.copy()

  #remove tge sentiment from dataframe and assign to labels variable
  labels = df.pop('sentiment')

  #remove any redundant data that may exists by assigning the tweet_text colum to the df
  df = df["tweet_text"]

  #create tensorflow dataset from combination of tweet texts and sentiment
  ds = tf.data.Dataset.from_tensor_slices((df, labels))
  
  #shuffle the dataset
  ds = ds.shuffle(buffer_size=len(dataframe))
  #create a batch size so that the dataset can be put into chunks for learning / testing
  ds = ds.batch(batch_size)

  # Prefetch the next batch in the background while the GPU is working on the current batch
  ds = ds.prefetch(tf.data.AUTOTUNE)
  return ds


import re
import string


def preProcess(dataset):
  #Required download for performing Natural language processing 
  nltk.download('stopwords')
  nltk.download('punkt')
  nltk.download('wordnet')
  
  stop_words = set(stopwords.words('english'))
  lemmatizer = WordNetLemmatizer()
  
  preprocessed_tweets = []
  
  for tweets in dataset['tweet_text']:
      # Using regular expression to remove hashtags and the word assoiciated 
      hashTagsRemoved = re.sub(r'#\w+', '', tweets)
      #Removing tweets that contains @ other users
      atRemoved = re.sub(r'@\w+', '', hashTagsRemoved)
      #Tokenize each word
      tokens = word_tokenize(atRemoved)
      #Remove all hashtags and their associated words
      tokens = [token for token in tokens if not token.startswith('#')]
      # Remove Punctuation from words
      tokens = [token for token in tokens if token not in string.punctuation]
      # Convert all words to lowercase to ensure no case confusion
      tokens = [token.lower() for token in tokens]
      # Remove Stop Words ie this, is , a
      tokens = [token for token in tokens if token not in stop_words]
      # Lemmatization bring words down to their basic form ie jumps jumper jumping == jump
      tokens = [lemmatizer.lemmatize(token) for token in tokens]
      # Untokenize each word and bring back together in the original format
      preprocessed_tweets.append(' '.join(tokens))

  # Return a new dataframe with tweets pre processed using pandas
  return pd.DataFrame({'tweet_text': preprocessed_tweets, 'sentiment': dataset['sentiment']})



#read in csv file
dataframe = pd.read_csv('C:/Users/dylan/Desktop/test/python/test.csv')

print(dataframe.head(5))

processedDf = preProcess(dataframe)

print(processedDf.head(5))

# This takes the processed dataframe and creates 3 different variables where they get a split of the dataframe each
# The training variables takes 80%, and validation takes the next 10% while test takes the remaining 10%
# Frac = 1 means all rows within the dataset are shuffled
train, val, test = np.split(processedDf.sample(frac=1), [int(0.8*len(processedDf)), int(0.9*len(processedDf))])

train_data = df_to_dataset(train)
val = df_to_dataset(val)
test_data = df_to_dataset(test)


#Set maximum vocabulary size and create TextVectorization layer to preprocess text data
VOCAB_SIZE = 1000

#Build vocabulary of TextVectorization layer based on training data
encoder = tf.keras.layers.TextVectorization(
    max_tokens=VOCAB_SIZE)
encoder.adapt(train_data.map(lambda text, label: text))


model = tf.keras.Sequential([
    #Text vectorizer that was created
    encoder,
    #Encoding the text into vectors and using mask zero to ignore different variations length
    tf.keras.layers.Embedding(len(encoder.get_vocabulary()), 64, mask_zero=True),
    #RNN layer to allow inputs to go both forward and backwards
    tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(64,  return_sequences=True)),
    #RNN layer that is of smaller size
    tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(32)),
    #Dense layer with 64 units and RelU activation
    tf.keras.layers.Dense(64, activation='relu'),
    #Dropout layer to prevent model over fitting
    tf.keras.layers.Dropout(0.5),
    #Final dense layer, sigmoid is used for 
    tf.keras.layers.Dense(1, activation='sigmoid')
])

#Configure the model for training with binary cross-entropy loss, Adam optimizer and accuracy metric for to determine its accuracy
model.compile(loss=tf.keras.losses.BinaryCrossentropy(from_logits=True),
              optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001),
              metrics=['accuracy'])

#Train model
model.fit(train_data, epochs=10,
                    validation_data=test_data,
                    validation_steps=30)

#Getting loss and accuracy
test_loss, test_acc = model.evaluate(test_data)

#Printing results of model
print('Test Loss:', test_loss)
print('Test Accuracy:', test_acc)

# Save the model
tf.keras.models.save_model(model, '/Users/dylanhayes/Desktop/FYPProject/TalkTwoYou/MachineLearning/python')