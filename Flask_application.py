from flask import Flask
app = Flask(__name__)

@app.route('/')
def my_flask_application():
    return 'Application Up and Running with no downtime, smmooothhh  Yay!!'

