import std.stdio;

import elasticsearch.client;
import elasticsearch.detail.log;
import elasticsearch.domain.request.cluster.node.info;
import elasticsearch.domain.request.document.index;
import elasticsearch.domain.response.cluster.node.info;
import elasticsearch.domain.response.document.index;

void main() {}

version (FunctionalTesting) {

unittest {
    log!(Level.info)("Performing 'NodesInfoRequest' with none type (updating nodes) ...");

    Client client = new Client();
    NodesInfoRequest request = NodesInfoRequest(NodesInfoRequest.Type.none);
    NodesInfoResponse.Result nodesInfo = client.nodesInfo(request);
}

unittest {    
    log!(Level.info)("Performing 'IndexRequest' with full parameters set ...");

    struct Tweet {
        string message; 
    }

    Client client = new Client();
    IndexRequest indexRequest = IndexRequest("twitter", "tweet", "1");    
    Tweet tweet = Tweet("Wow, I'm using elasticsearch!");    
    IndexResponse indexResponse = client.index(indexRequest, tweet);
}

}