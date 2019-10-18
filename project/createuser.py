# auth.py

from werkzeug.security import generate_password_hash, check_password_hash
import sys
import sqlite3

username = sys.argv[1]
nickname = sys.argv[2]
password = generate_password_hash(sys.argv[3], method='sha256')


conn = sqlite3.connect('db.sqlite')
c = conn.cursor()
print ("数据库连接成功。");

c.execute("delete from user");
c.execute("INSERT INTO user values (1,'"+username+"','"+password+"','"+nickname+"')");

conn.commit()
print ("用户创建完毕。注意，每次新建用户都会清空老用户！");
conn.close()

