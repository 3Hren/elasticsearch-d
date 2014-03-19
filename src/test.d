import std.stdio;
import std.typecons;
import std.variant;

import vibe.data.json;

import elasticsearch.client;
import elasticsearch.detail.log;
import elasticsearch.domain.action.request.cluster.node.info;
import elasticsearch.domain.action.request.document.get;
import elasticsearch.domain.action.request.document.index;
import elasticsearch.domain.action.request.search.search;
import elasticsearch.domain.action.response.cluster.node.info;
import elasticsearch.domain.action.response.document.index;
import elasticsearch.exception;
import elasticsearch.testing;

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
    request.setDocumentVersion(1);

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
    log!(Level.info)("Performing 'GetRequest' with automatic index detecting ...");

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

template isNullable(T) {
    const isNullable = __traits(compiles, (T t){
        t.isNull();
        t.nullify();
        t.get;
    });
}

class Query {
    public abstract void build(ref Json o);
}

class Term : Query {
    private const string name;
    private Json value;
    private float boost = -1;
    private string queryName;

    public this(T)(string name, T value) {
        this.name = name;
        this.value = value;
    }

    public Term setBoost(float boost) {
        this.boost = boost;
        return this;
    }

    public Term setQueryName(string queryName) {
        this.queryName = queryName;
        return this;
    }

    public override void build(ref Json o) {
        if (boost == -1 && queryName.length == 0) {
            o[name] = value;
        } else {
            o[name] = Json.emptyObject;
            o[name].value = value;

            if (boost != -1) {
                o[name].boost = boost;
            }

            if (queryName.length != 0) {
                o[name]._name = queryName;
            }
        }
    }
}

class MatchQuery {
    enum Type {
        BOOLEAN
    }

    private const string name;
    private const string text;
    private Nullable!Type type;

    public this(string name, string text) {
        this.name = name;
        this.text = text;
    }

    public MatchQuery setType(Type type) {
        this.type = type;
        return this;
    }

    public void build(ref Json o) {
        o.match = Json.emptyObject;
        o.match.name = Json.emptyObject;
        o.match.name.query = text;
        setField(o.match.name, "type", type);
    }

    private void setField(T)(ref Json o, string name, Nullable!T value) {
        if (!value.isNull) {
            setField(o, name, value.get);
        }
    }

    private void setField(T)(ref Json o, string name, T value) if (!isNullable!(T)) {
        o[name] = to!string(value);
    }
}

unittest {
    Json object = Json.emptyObject;
    auto query = new MatchQuery("message", "Wow!")
        .setType(MatchQuery.Type.BOOLEAN);
    query.build(object);
    log!(Level.info)("%s", object);
}

unittest {
    Json object = Json.emptyObject;
    auto q = new Term("field", 42)
        .setBoost(2)
        .setQueryName("blah");
    q.build(object);
    log!(Level.info)("%s", object);
}

//unittest {
//    log!(Level.info)("Performing 'SearchRequest' with match all ...");

//    Client client = new Client();
//    SearchRequest request = SearchRequest("twitter");
//    auto response = client.search(request);

//    log!(Level.info)("'SearchRequest' finished: %s\n", response);
//}

}
