from http.server import BaseHTTPRequestHandler, HTTPServer
import subprocess
from urllib.parse import parse_qs
import hashlib
import json
import os
import threading

class RequestHandler(BaseHTTPRequestHandler):
    # 定义变量md5key
    md5key = 'yourmd5password'
    defpath = '/youruripath'
    file = '/etc/reqserver/list'

    def send_response_json(self, error_code):
        # 构建json格式的响应内容
        response_data = {
            'result': error_code
        }
        response_json = json.dumps(response_data)

        # 设置响应的状态码和头部信息
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()

        # 将json格式的响应内容写入响应体
        self.wfile.write(response_json.encode())


    def do_POST(self):
        # 如果请求的路径不对，则忽略请求
        if self.path != self.defpath:
            return

        # 解析请求参数
        length = int(self.headers['Content-Length'])
        body = self.rfile.read(length).decode()
        params = parse_qs(body)

        # 获取参数
        ps = params['ps'][0]
        keyword = params['keyword'][0]
        md5 = params['md5'][0]

        # 使用hashlib库进行md5哈希运算
        try:
            hl = hashlib.md5()
            hlstr = keyword + self.md5key + ps
            hl.update(hlstr.encode(encoding='utf-8'))
        except:
            self.send_response_json('hash error')
            return

        # 比对客户端发送的md5值与计算出的哈希值
        if hl.hexdigest() != md5:
            self.send_response_json('md5 error!')
            return


        lock = threading.Lock()

        with lock:
            found_keyword = False
            lines = []
            if os.path.exists(self.file):
                with open(self.file, 'r') as f:
                    for line in f:
                        if keyword in line:
                            line = '{},{}\n'.format(keyword, ps)
                            found_keyword = True
                        lines.append(line)

            if not found_keyword:
                lines.append('{},{}\n'.format(keyword, ps))

                
            with open(self.file, 'w') as f:
                for line in lines:
                    f.write(line)
       
        # 如果比对结果一致，则返回状态码为0的响应
        self.send_response_json(0)

def run(server_class=HTTPServer, handler_class=RequestHandler):
    server_address = ('', 8181)
    httpd = server_class(server_address, handler_class)
    httpd.serve_forever()

run()
