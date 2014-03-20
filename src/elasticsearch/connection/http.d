module elasticsearch.connection.http;

import std.array;
import std.conv;
import std.net.curl : CurlException;
import std.socket;
import std.stdio;

import elasticsearch.exception;
import elasticsearch.detail.log;
import elasticsearch.domain.action.request.method;
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
        Appender!string stream = appender!string();
        string url = makeUrl(request);

        auto http = std.net.curl.HTTP(url);
        http.method = mapMethod!(std.net.curl.HTTP.Method)(request.method);

        if (request.method == ElasticsearchMethod.PUT || request.method == ElasticsearchMethod.POST) {
            auto msg = request.data;
            http.contentLength = msg.length;
            http.onSend = (void[] data) {
                auto m = cast(void[])msg;
                size_t len = m.length > data.length ? data.length : m.length;
                if (len == 0) {
                    return len;
                }

                data[0..len] = m[0..len];
                msg = msg[len..$];
                return len;
            };
        }

        http.onReceive = delegate(ubyte[] data) {
            stream.put(data);
            return data.length;
        };

        if (request.method == ElasticsearchMethod.PUT || request.method == ElasticsearchMethod.POST) {
            log!(Level.trace)("requesting [%s] %s -d %s ...", request.method, url, request.data);
        } else {
            log!(Level.trace)("requesting [%s] %s ...", request.method, url);
        }
        http.perform();
        auto status = http.statusLine;
        string content = stream.data;
        log!(Level.trace)("request finished: [%d] %s", status.code, content);
        return ElasticsearchResponse(status.code, address, content, request);
    }

    private string makeUrl(T)(T request) const {
        return address ~ request.uri;
    }

    private T mapMethod(T)(ElasticsearchMethod method) const pure @safe if (is(T == std.net.curl.HTTP.Method)) {
        final switch (method) with (ElasticsearchMethod) {
            case HEAD:
                return std.net.curl.HTTP.Method.head;
            case GET:
                return std.net.curl.HTTP.Method.get;
            case PUT:
                return std.net.curl.HTTP.Method.put;
            case POST:
                return std.net.curl.HTTP.Method.post;
            case DELETE:
                return std.net.curl.HTTP.Method.del;
        }
    }
}
