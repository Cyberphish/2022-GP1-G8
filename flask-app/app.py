import json
from flask import Flask, request, jsonify
import numpy as np
import pickle
import sklearn
import pandas as pd
import imblearn

model = pickle.load(open('SVMmodel.pkl', 'rb'))
vectorizer = pickle.load(open("vectorizer.pkl", "rb"))

app = Flask(__name__)

# declared an empty variable for reassignment
response = ''


@app.route('/', methods=['GET', 'POST'])
def pred():
    global response
    # checking the request type we get from the app
    if (request.method == 'POST'):
        subject = ''
        body=''
        Vocab_list = {}
        data = request.data
        request_data = json.loads(data.decode('utf-8'))
        subject = request_data['subject']
        body = request_data['body']
        features = "\n".join([subject, body])
        Vocab_list = {}
        prediction = model.predict([features])
        encode  = vectorizer.transform([features]).toarray()  
        bag_of_words = pd.DataFrame(
                 encode, columns=vectorizer.get_feature_names_out())
        Vocab_list = {}
        for vector in bag_of_words:
           if (bag_of_words[vector].values[0] > 0):
               Vocab_list[bag_of_words[vector].name] = bag_of_words[vector].values[0]
        prediction = f'{prediction}'
        response = f'{Vocab_list}'        
        return jsonify({'prediction': prediction[1],
                        'vocabulary': response
                        }) 
