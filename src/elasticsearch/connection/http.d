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

    //public abstract ElasticsearchResponse!(ElasticsearchMethod.head) perform(ElasticsearchRequest!(ElasticsearchMethod.head) request);
    public abstract ElasticsearchResponse!(ElasticsearchMethod.GET) perform(ElasticsearchRequest!(ElasticsearchMethod.GET) request);
    public abstract ElasticsearchResponse!(ElasticsearchMethod.PUT) perform(ElasticsearchRequest!(ElasticsearchMethod.PUT) request);
    public abstract ElasticsearchResponse!(ElasticsearchMethod.POST) perform(ElasticsearchRequest!(ElasticsearchMethod.POST) request);

    public override string toString() {
        return super.toString() ~ "(" ~ address ~ ")";
    }
}

class HttpNodeClient : NodeClient {
    public this(Address address) {
        super(address);
    }

    public override ElasticsearchResponse!(ElasticsearchMethod.GET) perform(ElasticsearchRequest!(ElasticsearchMethod.GET) request) {
        return doPerform(request);
    }

    public override ElasticsearchResponse!(ElasticsearchMethod.PUT) perform(ElasticsearchRequest!(ElasticsearchMethod.PUT) request) {
        return doPerform(request);
    }

    public override ElasticsearchResponse!(ElasticsearchMethod.POST) perform(ElasticsearchRequest!(ElasticsearchMethod.POST) request) {
        return doPerform(request);
    }

    private ElasticsearchResponse!(Request.method) doPerform(Request)(Request request) {
        alias Method = Request.method;
        alias Response = ElasticsearchResponse!Method;
        enum hasContent = Method == ElasticsearchMethod.PUT || Method == ElasticsearchMethod.POST;

        Appender!string writer = appender!string();
        string url = makeUrl(request);

        auto http = std.net.curl.HTTP(url);
        http.method = mapMethod!(Method, std.net.curl.HTTP.Method);

        static if (hasContent) {
            auto msg = request.data;
            http.contentLength = msg.length;
            http.onSend = (void[] data) {
                auto m = cast(void[])msg;
                log!(Level.trace)("--- %s", m);
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
            writer.put(data);
            return data.length;
        };

        static if (hasContent) {
            log!(Level.trace)("requesting [%s] %s -d %s ...", Method, url, request.data);
        } else {
            log!(Level.trace)("requesting [%s] %s ...", Method, url);
        }
        http.perform();
        auto status = http.statusLine;
        string content = writer.data;
        log!(Level.trace)("request finished: [%d] %s", status.code, content);
        return Response(status.code / 100 == 2, status.code, address, content, request);
    }

    private string makeUrl(T)(T request) const {
        return address ~ request.uri;
    }

    private T mapMethod(ElasticsearchMethod method, T)() if (is(T == std.net.curl.HTTP.Method)) {
        final switch (method) with (ElasticsearchMethod) {
            case head:
                return std.net.curl.HTTP.Method.head;
            case GET:
                return std.net.curl.HTTP.Method.get;
            case PUT:
                return std.net.curl.HTTP.Method.put;
            case POST:
                return std.net.curl.HTTP.Method.post;
            case del:
                return std.net.curl.HTTP.Method.del;
        }
    }
}
