# auth.py

from flask import Blueprint, render_template, redirect, url_for, request, flash, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import login_user, logout_user, login_required
from .models import User
from . import db
import os
import re

auth = Blueprint('auth', __name__)
APP_ROOT = os.path.dirname(os.path.abspath(__file__))   # refers to application_top

@auth.route('/login')
def login():
    return render_template('login.html')

@auth.route('/login', methods=['POST'])
def login_post():
    email = request.form.get('email')
    password = request.form.get('password')
    if (request.form.get('remember')):
        remember = True
    else:
        remember = False

    user = User.query.filter_by(email=email).first()

    # check if user actually exists
    # take the user supplied password, hash it, and compare it to the hashed password in database
    if not user or not check_password_hash(user.password, password): 
        flash('Please check your login details and try again.')
        return redirect(url_for('auth.login')) # if user doesn't exist or password is wrong, reload the page

    # if the above check passes, then we know the user has the right credentials
    login_user(user, remember=remember)
    return redirect(url_for('main.profile'))


@auth.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('main.index'))

@auth.route('/checkzone/<zonename>',methods=['GET'])
@login_required
def checkzone(zonename):

    status = os.system('sh '+APP_ROOT+'/changezone.sh '+zonename)

    return jsonify({'result': status})

@auth.route('/checkdns',methods=['GET'])
@login_required
def checkdns():
   status = os.system('nslookup netflix.com - 127.0.0.1 > '+APP_ROOT+'/dnsResult')
   file_object = open(APP_ROOT+'/dnsResult')
   try:
      file_context = file_object.read()
   finally:
      file_object.close()

   return jsonify({'result': file_context})

def checkip(ip):
    p = re.compile('^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$')
    if p.match(ip):
        return True
    else:
        return False
