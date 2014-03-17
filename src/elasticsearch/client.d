module elasticsearch.client;

import std.string;

import vibe.data.serialization;
import vibe.data.json;

import elasticsearch.exception;
import elasticsearch.detail.inflect;
import elasticsearch.detail.log;
import elasticsearch.domain.response.base;
import elasticsearch.domain.response.cluster.node.info;
import elasticsearch.domain.response.document.get;
import elasticsearch.domain.response.document.index;
import elasticsearch.domain.request.base;
import elasticsearch.domain.request.method;
import elasticsearch.domain.request.cluster.node.info;
import elasticsearch.domain.request.document.get;
import elasticsearch.domain.request.document.index;
import elasticsearch.domain.transport;

struct ClientSettings {
    string index;
}

class Client {
    private ClientSettings settings = ClientSettings("default");
    private Transport transport;

    public this() {
        this.transport = new Transport();
    }

    public this(ClientSettings settings) {
        this.settings = settings;
        this();
    }

    public IndexResponse!(ManualIndexRequest) index(T)(string index, string type, string id, T post) {
        return this.index(ManualIndexRequest(index, type, id), post);
    }

    public IndexResponse!(AutomaticIndexRequest) index(T)(string index, string type, T post) {
        return this.index(AutomaticIndexRequest(index, type), post);        
    }

    public IndexResponse!(AutomaticIndexRequest) index(T)(string index, T post) {
        return this.index(index, Pluralizer.make(T.stringof.toLower), post);
    }

    public IndexResponse!(AutomaticIndexRequest) index(T)(T post) {
        return this.index(settings.index, post);
    }

    public IndexResponse!(Request) index(Request, T)(in Request action, T post) {
        alias Method = Request.Method;

        string data = serializeToJson(post).toString();
        auto request = ElasticsearchRequest!(Method)(action.uri, data);
        auto response = perform(request);
        auto result = deserializeJson!(IndexResponse!(Request).Result)(response.data);
        return IndexResponse!(Request)(response, result);
    }

    public T get(T)(string type, string id) {
        GetRequest request = GetRequest(settings.index, type, id);
        return this.get!(T)(request);
    }

    public T get(T)(in GetRequest action) {
        alias Method = GetRequest.Method;

        auto request = ElasticsearchRequest!(Method)(action.uri);        
        auto response = perform(request);

        if (response.code != 200) {
            if (response.code == 404) {
                throw new ElasticsearchError!(Method)("document not found", response); 
            } else {
                throw new ElasticsearchError!(Method)("document can't be extracted", response); 
            }
        }

        auto result = deserializeJson!(GetResponse!(T).Result)(response.data);
        return result.source;
    }

    public NodesInfoResponse.Result nodesInfo(NodesInfoRequest action) {
        alias Method = NodesInfoRequest.Method;

        auto request = ElasticsearchRequest!(Method)(action.uri);
        auto response = perform(request);
        auto result = deserializeJson!(NodesInfoResponse.Result)(response.data);
        return result;
    }

    private ElasticsearchResponse!(Method) perform(ElasticsearchMethod Method)(ElasticsearchRequest!(Method) request) {
        ElasticsearchResponse!(Method) response = transport.perform(request);
        if (response.code != 200) {
            Json result = deserializeJson!(Json)(response.data);
            auto reason = to!string(result["error"]);
            throw new ElasticsearchError!(Method)(reason, response);
        }

        return response;
    }
}