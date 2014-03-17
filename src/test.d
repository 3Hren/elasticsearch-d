import std.stdio;

import elasticsearch.client;
import elasticsearch.detail.log;
import elasticsearch.domain.request.cluster.node.info;
import elasticsearch.domain.request.document.get;
import elasticsearch.domain.request.document.index;
import elasticsearch.domain.response.cluster.node.info;
import elasticsearch.domain.response.document.index;
import elasticsearch.exception;

void main() {}

version (FunctionalTesting) {

unittest {    
    log!(Level.info)("Performing 'IndexRequest' with specifying just index, type and id ...");

    struct Tweet {
        string message; 
    }

    Client client = new Client();
    Tweet tweet = Tweet("Wow, I'm using elasticsearch!");    
    IndexResponse!ManualIndexRequest response = client.index("twitter", "tweet", "1", tweet);

    log!(Level.info)("'IndexRequest' finished: %s\n", response);

    IndexResult result = response.result;

    assert("twitter" == result.index);
    assert("tweet" == result.type);
    assert("1" == result.id);
}

unittest {    
    log!(Level.info)("Performing 'IndexRequest' with specifying just index and type ...");

    struct Tweet {
        string message; 
    }

    Client client = new Client();
    Tweet tweet = Tweet("Wow, I'm using elasticsearch without id specifying!");    
    IndexResponse!AutomaticIndexRequest response = client.index("twitter", "tweet", tweet);

    log!(Level.info)("'IndexRequest' finished: %s\n", response);

    IndexResult result = response.result;

    assert("twitter" == result.index);
    assert("tweet" == result.type);
}   

unittest {    
    log!(Level.info)("Performing 'IndexRequest' with specifying just index ...");

    struct Tweet {
        string message; 
    }

    Client client = new Client();
    Tweet tweet = Tweet("Wow, I'm using elasticsearch without id and type specifying!");    
    IndexResponse!AutomaticIndexRequest response = client.index("twitter", tweet);

    log!(Level.info)("'IndexRequest' finished: %s\n", response);

    IndexResult result = response.result;

    assert("twitter" == result.index);
    assert("tweets" == result.type);
}

unittest {    
    log!(Level.info)("Performing 'IndexRequest' with specifying, emmm, nothing. Using default index ...");

    struct Tweet {
        string message; 
    }

    Client client = new Client(ClientSettings("twitter"));
    Tweet tweet = Tweet("Wow, I'm using elasticsearch with specifying nothing!");
    IndexResponse!AutomaticIndexRequest response = client.index(tweet);

    log!(Level.info)("'IndexRequest' finished: %s\n", response);

    IndexResult result = response.result;

    assert("twitter" == result.index);
    assert("tweets" == result.type);
} 

unittest {    
    log!(Level.info)("Performing 'IndexRequest' with full parameters set ...");

    struct Tweet {
        string message; 
    }

    Client client = new Client();
    ManualIndexRequest request = ManualIndexRequest("twitter", "tweet", "1");    
    Tweet tweet = Tweet("Wow, I'm using elasticsearch!");    
    IndexResponse!ManualIndexRequest response = client.index(request, tweet);

    log!(Level.info)("'IndexRequest' finished: %s\n", response);
}

unittest {    
    log!(Level.info)("Performing 'IndexRequest' with full parameters set with version ...");

    struct Tweet {
        string message; 
    }

    Client client = new Client();
    ManualIndexRequest request = ManualIndexRequest("twitter", "tweet", "1");
    request.version_ = 1;

    Tweet tweet = Tweet("Wow, I'm using elasticsearch!");    
    try {
        IndexResponse!ManualIndexRequest response = client.index(request, tweet);
        assert(false);
    } catch (ElasticsearchError!(ManualIndexRequest.Method) err) {
        assert(err.response.code == 409);
    } finally {
        log!(Level.info)("'IndexRequest' finished\n");
    }    
}

unittest {
    log!(Level.info)("Performing 'NodesInfoRequest' with 'None' type (updating nodes) ...");

    Client client = new Client();
    NodesInfoRequest request = NodesInfoRequest(NodesInfoRequest.Type.none);
    NodesInfoResponse.Result result = client.nodesInfo(request);

    log!(Level.info)("'NodesInfoRequest' finished: %s\n", result);
}

unittest {
    log!(Level.info)("Performing 'NodesInfoRequest' with 'Settings' type ...");

    Client client = new Client();
    NodesInfoRequest request = NodesInfoRequest(NodesInfoRequest.Type.settings);
    NodesInfoResponse.Result result = client.nodesInfo(request);

    log!(Level.info)("'NodesInfoRequest' finished: %s\n", result);
}

unittest {
    log!(Level.info)("Performing 'NodesInfoRequest' with 'OS' type ...");

    Client client = new Client();
    NodesInfoRequest request = NodesInfoRequest(NodesInfoRequest.Type.os);
    NodesInfoResponse.Result result = client.nodesInfo(request);

    log!(Level.info)("'NodesInfoRequest' finished: %s\n", result);
}

unittest {
    log!(Level.info)("Performing 'NodesInfoRequest' with 'Process' type ...");

    Client client = new Client();
    NodesInfoRequest request = NodesInfoRequest(NodesInfoRequest.Type.process);
    NodesInfoResponse.Result result = client.nodesInfo(request);

    log!(Level.info)("'NodesInfoRequest' finished: %s\n", result);
}

unittest {
    log!(Level.info)("Performing 'NodesInfoRequest' with 'JVM' type ...");

    Client client = new Client();
    NodesInfoRequest request = NodesInfoRequest(NodesInfoRequest.Type.jvm);
    NodesInfoResponse.Result result = client.nodesInfo(request);

    log!(Level.info)("'NodesInfoRequest' finished: %s\n", result);
}

unittest {
    log!(Level.info)("Performing 'NodesInfoRequest' with 'ThreadPool' type ...");

    Client client = new Client();
    NodesInfoRequest request = NodesInfoRequest(NodesInfoRequest.Type.threadPool);
    NodesInfoResponse.Result result = client.nodesInfo(request);

    log!(Level.info)("'NodesInfoRequest' finished: %s\n", result);
}

unittest {
    log!(Level.info)("Performing 'NodesInfoRequest' with 'Network' type ...");

    Client client = new Client();
    NodesInfoRequest request = NodesInfoRequest(NodesInfoRequest.Type.network);
    NodesInfoResponse.Result result = client.nodesInfo(request);

    log!(Level.info)("'NodesInfoRequest' finished: %s\n", result);
}

unittest {
    log!(Level.info)("Performing 'NodesInfoRequest' with 'HTTP' type ...");

    Client client = new Client();
    NodesInfoRequest request = NodesInfoRequest(NodesInfoRequest.Type.http);
    NodesInfoResponse.Result result = client.nodesInfo(request);

    log!(Level.info)("'NodesInfoRequest' finished: %s\n", result);
}

unittest {
    log!(Level.info)("Performing 'NodesInfoRequest' with 'Plugins' type ...");

    Client client = new Client();
    NodesInfoRequest request = NodesInfoRequest(NodesInfoRequest.Type.plugins);
    NodesInfoResponse.Result result = client.nodesInfo(request);

    log!(Level.info)("'NodesInfoRequest' finished: %s\n", result);
}

unittest {
    log!(Level.info)("Performing 'NodesInfoRequest' with 'Mixed OS and Settings' type ...");

    Client client = new Client();
    NodesInfoRequest request = NodesInfoRequest(NodesInfoRequest.Type.os | NodesInfoRequest.Type.settings);
    NodesInfoResponse.Result result = client.nodesInfo(request);

    log!(Level.info)("'NodesInfoRequest' finished: %s\n", result);
}

unittest {
    log!(Level.info)("Performing 'GetRequest' ...");

    struct Tweet {
        string message; 
    }

    Client client = new Client();
    GetRequest request = GetRequest("twitter", "tweet", "1");
    Tweet tweet = client.get!Tweet(request);

    log!(Level.info)("'GetRequest' finished: %s\n", tweet);
}

unittest {
    log!(Level.info)("Performing 'GetRequest' with automatic index and type detecting ...");

    struct Tweet {
        string message; 
    }

    Client client = new Client();
    try {
        Tweet tweet = client.get!Tweet("tweet", "1");
        log!(Level.info)("'GetRequest' finished: %s\n", tweet);
    } catch (Error err) {
        log!(Level.info)("'GetRequest' finished: %s\n", err.msg);
    }
}

}