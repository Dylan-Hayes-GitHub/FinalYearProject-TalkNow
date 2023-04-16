from flask import Flask, request
from flask_restful import Api
import tensorflow as tf
import json
from flask_cors import CORS
import string
from nltk.tokenize import word_tokenize
import nltk as nltk
from nltk.stem import WordNetLemmatizer
from nltk.corpus import stopwords
import jwt


app = Flask(__name__)
CORS(app)

api = Api(app)

model = tf.keras.models.load_model(
    '/Users/dylanhayes/Desktop/FYPProject/TalkTwoYou/MachineLearning/python/tensorFlowModel', compile=False)
nltk.download('stopwords')
nltk.download('punkt')
nltk.download('wordnet')
jwtKey = "ODRvcEdnVQx34O943x7jqFWQzZXcHtltktL8Vehkizy8nx9gKSZds48CEmuuGYfmzdw5TmOJL8aPq15nkorsdMzuRw1NQEwM2DMO"
Issuer = "http://localhost:5074"
Audience = "http://localhost:5074"


@app.route('/predict')
def predict():

    # Get the auth header from the request
    auth_header = request.headers.get('Authorization')
    print("headers")
    print(auth_header)
    if auth_header:
        # Check that the header header starts with "Bearer"
        if auth_header.startswith('Bearer '):
            # Get token from auth header
            token = auth_header[len('Bearer '):]

            try:
                # Attempt to decode the jwt as if its invalid or expired it will throw an exception
                jwt.decode(token, jwtKey, leeway=100,
                           algorithms="HS256", audience=Audience, issuer=Issuer)

                lemmatizer = WordNetLemmatizer()
                stop_words = stopwords.words('english')
                messageFromUser = request.args.get('message')

                # Tokenize each word
                tokens = word_tokenize(messageFromUser)
                # Remove all hashtags and their associated words
                tokens = [
                    token for token in tokens if not token.startswith('#')]
                # Remove Punctuation from words
                tokens = [
                    token for token in tokens if token not in string.punctuation]
                # Convert all words to lowercase to ensure no case confusion
                tokens = [token.lower() for token in tokens]
                # Remove Stop Words ie this, is , a
                tokens = [token for token in tokens if token not in stop_words]
                # Lemmatization bring words down to their basic form ie jumps jumper jumping == jump
                tokens = [lemmatizer.lemmatize(token) for token in tokens]
                # Untokenize each word and bring back together in the original format
                message = ' '.join(tokens)
                print(message)
                res = model.predict([message])
                json_str = json.dumps({'sentiment': res.tolist()})
                return json_str
            except (jwt.InvalidTokenError, jwt.ExpiredSignatureError):
                # Return an unauthorized response if the token is invalid
                return "", 401
        else:
            # Return an unauthorized response if the authorization header is not a bearer token
            return "", 401
    else:
        # Return an unauthorized response if the authorization header is missing
        return "", 401
{
    'sentiment': '0.75'
}