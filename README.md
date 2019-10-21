# MeCab gRPC Server

## Run Server
``` console
$ docker run --rm -it -p 50051:50051 hoto17296/mecab-grpc-server
```

## Python Client Example
``` console
$ pip install grpcio grpcio-tools
$ python -m grpc_tools.protoc -I./ --python_out=. --grpc_python_out=. mecab_server.proto
```

``` console
$ python client_example.py "メロスは激怒した。"
メロス  名詞,固有名詞,一般,*,*,*,メロス,メロス,メロス
は      助詞,係助詞,*,*,*,*,は,ハ,ワ
激怒    名詞,サ変接続,*,*,*,*,激怒,ゲキド,ゲキド
し      動詞,自立,*,*,サ変・スル,連用形,する,シ,シ
た      助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
。      記号,句点,*,*,*,*,。,。,。
EOS
```