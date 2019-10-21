import sys
import grpc

import mecab_server_pb2
import mecab_server_pb2_grpc

with grpc.insecure_channel('localhost:50051') as channel:
    stub = mecab_server_pb2_grpc.MeCabServerStub(channel)
    response = stub.Parse(mecab_server_pb2.Text(text=' '.join(sys.argv[1:])))

print(response.text)