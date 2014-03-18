module elasticsearch.domain.action.request.document.get;

import std.algorithm;
import std.conv;

import vibe.inet.path;

import elasticsearch.domain.action.request.base;
import elasticsearch.domain.action.request.method;

struct GetRequest {
    enum Method = ElasticsearchMethod.get;
    mixin UriBasedRequest;

    public this() @disable;

    public this(string index, string type, string id) {
        setPath(index, type, id);
    }
}

unittest {
    assert("/twitter/tweet/1" == GetRequest("twitter", "tweet", "1").uri);
}