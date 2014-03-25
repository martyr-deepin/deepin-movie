import SocketServer

class MyTCPHandler(SocketServer.BaseRequestHandler):

    def handle(self):
        self.data = self.request.recv(1024).strip()
        self.url = [l for l in self.data.split('\n') if l.startswith('qvod:')][0]
        print self.url
        
def listenURL():
    HOST, PORT = "localhost", 8888
    
    server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)
    server.serve_forever()
