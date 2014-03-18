module elasticsearch.domain.action.request.document.get;

import std.algorithm;
import std.conv;

import vibe.inet.path;

import elasticsearch.domain.action.request.base;
import elasticsearch.domain.action.request.method;

struct GetRequest {
    enum Method = ElasticsearchMethod.get;
    mixin UriBasedRequest!GetRequest;

    private string index;
    private string type;
    private string id;

    public this() @disable;

    public this(string index, string type, string id) {
        this.index = index;
        this.type = type;
        this.id = id;
    }

    private void buildUri(UriBuilder builder) const {
        builder.setPath(index, type, id);
    }
}

//! ==================== UNIT TESTS ====================

unittest {
    assert("/twitter/tweet/1" == GetRequest("twitter", "tweet", "1").uri);
}
