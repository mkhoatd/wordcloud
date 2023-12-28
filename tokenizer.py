from underthesea import word_tokenize
from nltk.tokenize import RegexpTokenizer

import re

stop_words = None
with open('./stopwords.txt', 'r') as f:
    stop_words = f.read().split('\n')
    
regtok = RegexpTokenizer(r'\w+')

def tokenize(text):
    text = text.lower()
    text = regtok.tokenize(text)
    text = " ".join(text)
    tokens = word_tokenize(text)
    tokens = [token for token in tokens if token not in stop_words and not token.isnumeric() and len(token.split()) > 1]
    if len(tokens) == 0:
        tokens = [' ']
    return tokens