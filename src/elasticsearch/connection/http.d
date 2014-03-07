module elasticsearch.connection.http;

import std.conv;
import std.net.curl : CurlException;
import std.socket;
import std.stdio;

import elasticsearch.detail.log;
import elasticsearch.domain.request.method;
import elasticsearch.domain.request.base;
import elasticsearch.domain.response.base;

abstract class NodeClient {
    private string address;

    public this(Address address) {
        this.address = to!string(address);
    }

    public string getAddress() {
        return address;
    }

    //public abstract ElasticsearchResponse!(ElasticsearchMethod.head) perform(ElasticsearchRequest!(ElasticsearchMethod.head) request);
    public abstract ElasticsearchResponse!(ElasticsearchMethod.get) perform(ElasticsearchRequest!(ElasticsearchMethod.get) request);
    public abstract ElasticsearchResponse!(ElasticsearchMethod.put) perform(ElasticsearchRequest!(ElasticsearchMethod.put) request);
    public abstract ElasticsearchResponse!(ElasticsearchMethod.post) perform(ElasticsearchRequest!(ElasticsearchMethod.post) request);

    public override string toString() {
        return super.toString() ~ "(" ~ address ~ ")";
    }
}

class HttpNodeClient : NodeClient {
    public this(Address address) {
        super(address);
    }

    public override ElasticsearchResponse!(ElasticsearchMethod.get) perform(ElasticsearchRequest!(ElasticsearchMethod.get) request) {
        string url = getUrl(request);
        log!(Level.trace)("requesting %s ...", url);
        char[] content = std.net.curl.get(url);
        log!(Level.trace)("request finished: %s", content);
        return ElasticsearchResponse!(ElasticsearchMethod.get)(true, 200, address, to!string(content), request);
    }

    public override ElasticsearchResponse!(ElasticsearchMethod.put) perform(ElasticsearchRequest!(ElasticsearchMethod.put) request) {
        string url = getUrl(request);
        log!(Level.trace)("requesting %s ...", url);
        char[] content = std.net.curl.put(url, request.data);
        log!(Level.trace)("request finished: %s", content);
        return ElasticsearchResponse!(ElasticsearchMethod.put)(true, 200, address, to!string(content), request);
    }

    public override ElasticsearchResponse!(ElasticsearchMethod.post) perform(ElasticsearchRequest!(ElasticsearchMethod.post) request) {
        string url = getUrl(request);
        log!(Level.trace)("requesting %s ...", url);
        char[] content = std.net.curl.post(url, request.data);
        log!(Level.trace)("request finished: %s", content);
        return ElasticsearchResponse!(ElasticsearchMethod.post)(true, 200, address, to!string(content), request);
    }

    private string getUrl(T)(T request) {
        return address ~ request.uri;
    }
}