import std.stdio;

import elasticsearch.client;
import elasticsearch.detail.log;
import elasticsearch.domain.request.cluster.node.info;
import elasticsearch.domain.request.document.index;
import elasticsearch.domain.response.cluster.node.info;
import elasticsearch.domain.response.document.index;

struct Tweet {
    string message; 
}

int main(string[] args) {   
    IndexRequest indexRequest = IndexRequest("twitter", "tweet", "1");
    Tweet tweet = Tweet("Wow, I'm using elasticsearch!");

    Client client = new Client();
    IndexResponse indexResponse = client.index(indexRequest, tweet);
    log!(Level.trace)(indexResponse);

    //NodesInfoRequest nodesInfoRequest = NodesInfoRequest(NodesInfoRequest.Type.all);
    //NodesInfoResponse.Result nodesInfo = client.nodesInfo(nodesInfoRequest);
    return 0;
}