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
        print('inn')
        data = request.data
        request_data = json.loads(data.decode('utf-8'))
        subject = request_data['subject']
        body = request_data['body']
        features = "\n".join([subject, body])
        prediction = model.predict([features])
        vocabulary  = vectorizer.transform([features]).toarray()   
        Vocab_list = {}
        bag_of_words = pd.DataFrame(
               vocabulary, columns=vectorizer.get_feature_names_out())
        for vector in bag_of_words:
           if (bag_of_words[vector].values > 0):
               Vocab_list[bag_of_words[vector].name] = bag_of_words[vector].values[0]
        prediction = f'{prediction}'
        response = f'{Vocab_list}'        
        return jsonify({'prediction': prediction,
                        'vocabulary': response
                        }) 

    else:
        # sending data back to your frontend app
        subject = 'funds to share'
        body = "The University of Washington System is sharing funds for all students during this pandemic, please update your \n financial aid status to claim yours. \nLogin.uw.edu/covid-19-aid-update\n For instructions on Accepting Your Financial Aid on https://login.uw.edu/login/login./.\n Regards,\n Assistant Professor \nUniversity of Washington"
        features = "\n".join([subject, body])
        vocabulary  = vectorizer.transform([features]).toarray()   
        Vocab_list = {}
        bag_of_words = pd.DataFrame(
               vocabulary, columns=vectorizer.get_feature_names_out())
        for vector in bag_of_words:
           if (bag_of_words[vector].values > 0):
               Vocab_list[bag_of_words[vector].name] = bag_of_words[vector].values[0]
        prediction = model.predict([features])
        prediction = f'{prediction}'
        response = f'{Vocab_list}'        
        return jsonify({'prediction': prediction,
                        'vocabulary': response
                        }) 
