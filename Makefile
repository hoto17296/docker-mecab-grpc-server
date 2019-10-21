CPPFLAGS += `pkg-config --cflags protobuf grpc`
CPPFLAGS += `mecab-config --cflags`
CXXFLAGS += -std=c++11
LDFLAGS += -L/usr/local/lib \
	`pkg-config --libs protobuf grpc++` \
	`mecab-config --libs` \
	-Wl,--no-as-needed -lgrpc++_reflection -Wl,--as-needed \
	-ldl

mecab_server: mecab_server.pb.o mecab_server.grpc.pb.o mecab_server.o
	g++ $^ $(LDFLAGS) -o $@

%.grpc.pb.cc: %.proto
	protoc --grpc_out=. --plugin=protoc-gen-grpc=`which grpc_cpp_plugin` $<

%.pb.cc: %.proto
	protoc --cpp_out=. $<

clean:
	rm -f *.o *.pb.cc *.pb.h mecab_server