module elasticsearch.domain.request.document.get;

import std.algorithm;
import std.conv;

import vibe.inet.path;

import elasticsearch.domain.request.base;
import elasticsearch.domain.request.method;

struct GetRequest {
    enum Method = ElasticsearchMethod.get;
    mixin UriBasedRequest;

    public this(string index, string type, string id) {
        setPath(index, type, id);
    }
}

unittest {
    assert("/twitter/tweet/1" == GetRequest("twitter", "tweet", "1").uri);
}