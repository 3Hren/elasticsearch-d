module elasticsearch.domain.action.request.document.get;

import std.algorithm;
import std.conv;

import vibe.inet.path;

import elasticsearch.domain.action.request.base;
import elasticsearch.domain.action.request.method;
import elasticsearch.testing;

struct GetRequest {
    enum Method = ElasticsearchMethod.GET;
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

class GetRequestTestCase : BaseTestCase!GetRequestTestCase {
    @Test("Uri")
    unittest {
        assert("/twitter/tweet/1" == GetRequest("twitter", "tweet", "1").uri);
    }
}
