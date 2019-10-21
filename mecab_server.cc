#include <iostream>
#include <memory>
#include <string>

#include <grpcpp/grpcpp.h>
#include <mecab.h>

#include "mecab_server.grpc.pb.h"

using mecab_server::MeCabServer;
using mecab_server::Text;

class MeCabServerImpl final : public MeCabServer::Service {
 public:
  explicit MeCabServerImpl(MeCab::Tagger &tagger) {
    this->_tagger = &tagger;
  }

  grpc::Status Parse(grpc::ServerContext* context, const Text* origin, Text* parsed) override {
    parsed->set_text(this->_tagger->parse(origin->text().c_str()));
    return grpc::Status::OK;
  }

 private:
  MeCab::Tagger *_tagger;
};

int main(int argc, char** argv) {
  grpc::ServerBuilder builder;
  std::string port = std::getenv("PORT") ? std::getenv("PORT") : "50051";
  builder.AddListeningPort("0.0.0.0:" + port, grpc::InsecureServerCredentials());

  MeCab::Tagger *tagger = MeCab::createTagger(std::getenv("MECAB_OPTS"));
  MeCabServerImpl service(*tagger);
  builder.RegisterService(&service);

  std::unique_ptr<grpc::Server> server(builder.BuildAndStart());
  std::cout << "Server listening on port " << port << std::endl;
  server->Wait();

  return 0;
}