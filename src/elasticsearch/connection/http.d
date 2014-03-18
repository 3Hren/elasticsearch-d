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
        alias Method = ElasticsearchMethod.get;

        Appender!(string) writer = appender!(string)();    
        string url = getUrl(request);

        std.net.curl.HTTP http = std.net.curl.HTTP(url);
        http.method = std.net.curl.HTTP.Method.get;

        http.onReceive = delegate(ubyte[] data) {
            writer.put(data);
            return data.length;            
        };

        log!(Level.trace)("requesting [%s] %s ...", Method, url);
        http.perform();
        auto status = http.statusLine;
        string content = writer.data;        
        log!(Level.trace)("request finished: [%d] %s", status.code, content);
        return ElasticsearchResponse!(ElasticsearchMethod.get)(status.code == 200, status.code, address, content, request);
    }

    public override ElasticsearchResponse!(ElasticsearchMethod.put) perform(ElasticsearchRequest!(ElasticsearchMethod.put) request) {
        alias Method = ElasticsearchMethod.put;

        Appender!string writer = appender!string();
        string url = getUrl(request); // TODO: Replace with property getter.        

        std.net.curl.HTTP http = std.net.curl.HTTP(url);            
        http.method = std.net.curl.HTTP.Method.put;
        auto msg = request.data;
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

        http.onReceive = delegate(ubyte[] data) {
            writer.put(data);
            return data.length;
        };
        
        log!(Level.trace)("requesting [%s] %s -d %s...", Method, url, request.data);                                
        http.perform();
        auto status = http.statusLine;
        string content = writer.data;        
        log!(Level.trace)("request finished: [%d] %s", status.code, content);
        return ElasticsearchResponse!(ElasticsearchMethod.put)(status.code == 200, status.code, address, content, request);
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