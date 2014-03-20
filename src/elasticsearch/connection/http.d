module elasticsearch.connection.http;

import std.array;
import std.conv;
import std.net.curl : CurlException;
import std.socket;
import std.stdio;

import vibe.http.common;

import elasticsearch.exception;
import elasticsearch.detail.log;
import elasticsearch.domain.action.request.base;
import elasticsearch.domain.action.response.base;

abstract class NodeClient {
    private string address;

    public this(Address address) {
        this.address = to!string(address);
    }

    public string getAddress() {
        return address;
    }

    public abstract ElasticsearchResponse perform(ElasticsearchRequest request);

    public override string toString() {
        return super.toString() ~ "(" ~ address ~ ")";
    }
}

class HttpNodeClient : NodeClient {
    public this(Address address) {
        super(address);
    }

    public override ElasticsearchResponse perform(ElasticsearchRequest request) {
        import vibe.http.client;
        import vibe.stream.operations;

        Appender!string stream = appender!string();
        string url = makeUrl(request);
        uint statusCode = 200;

        if (request.method == HTTPMethod.PUT || request.method == HTTPMethod.POST) {
            log!(Level.trace)("requesting [%s] %s -d %s ...", request.method, url, request.data);
        } else {
            log!(Level.trace)("requesting [%s] %s ...", request.method, url);
        }

        requestHTTP(url,
            (scope req) {
                req.method = request.method;
                if (request.method == HTTPMethod.PUT || request.method == HTTPMethod.POST) {
                    req.writeBody(cast(ubyte[])(request.data));
                }
            },
            (scope res) {
                stream.put(res.bodyReader.readAllUTF8());
                statusCode = res.statusCode;
            }
        );

        string content = stream.data;
        log!(Level.trace)("request finished: [%d] %s", statusCode, content);
        return ElasticsearchResponse(statusCode, address, content, request);
    }

    private string makeUrl(T)(T request) const {
        return "http://" ~ address ~ request.uri;
    }
}
