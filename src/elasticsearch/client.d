module elasticsearch.client;

import std.string;

import vibe.data.serialization;
import vibe.data.json;

import elasticsearch.exception;
import elasticsearch.detail.inflect;
import elasticsearch.detail.log;
import elasticsearch.domain.action.response.base;
import elasticsearch.domain.action.response.cluster.node.info;
import elasticsearch.domain.action.response.document.get;
import elasticsearch.domain.action.response.document.index;
import elasticsearch.domain.action.request.base;
import elasticsearch.domain.action.request.method;
import elasticsearch.domain.action.request.cluster.node.info;
import elasticsearch.domain.action.request.document.get;
import elasticsearch.domain.action.request.document.index;
import elasticsearch.domain.action.request.search.search;
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
        string data = serializeToJson(post).toString();
        auto request = ElasticsearchRequest(action.uri, action.method, data);
        auto response = perform(request);
        auto result = deserializeJson!(IndexResponse!(Request).Result)(response.data);
        return IndexResponse!(Request)(response, result);
    }

    public T get(T)(string type, string id) {
        GetRequest request = GetRequest(settings.index, type, id);
        return this.get!(T)(request);
    }

    public T get(T)(in GetRequest action) {
        auto request = ElasticsearchRequest(action.uri, action.method);
        auto response = perform(request);

        if (response.code != 200) {
            if (response.code == 404) {
                throw new ElasticsearchError("document not found", response);
            } else {
                throw new ElasticsearchError("document can't be extracted", response);
            }
        }

        auto result = deserializeJson!(GetResponse!(T).Result)(response.data);
        return result.source;
    }

    public Json search(in SearchRequest action) {
        auto request = ElasticsearchRequest(action.uri, action.method, action.data);
        auto response = perform(request);
        auto result = deserializeJson!(Json)(response.data);
        return result;
    }

    public NodesInfoResponse.Result nodesInfo(NodesInfoRequest action) {
        auto request = ElasticsearchRequest(action.uri, action.method);
        auto response = perform(request);
        auto result = deserializeJson!(NodesInfoResponse.Result)(response.data);
        return result;
    }

    private ElasticsearchResponse perform(ElasticsearchRequest request) {
        ElasticsearchResponse response = transport.perform(request);
        if (!response.success) {
            Json result = deserializeJson!(Json)(response.data);
            auto reason = to!string(result["error"]);
            throw new ElasticsearchError(reason, response);
        }

        return response;
    }
}
