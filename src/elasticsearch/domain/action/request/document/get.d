module elasticsearch.domain.action.request.document.get;

import std.algorithm;
import std.conv;

import vibe.data.json;
import vibe.http.common;
import vibe.inet.path;

import elasticsearch.domain.action.request.base;
import elasticsearch.testing;

struct GetRequest(T = Json) {
    alias Type = T;
    enum method = HTTPMethod.GET;
    mixin UriBasedRequest!(typeof(this));

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
    struct Tweet {
        string message;
    }

    @Test("Uri")
    unittest {
        assert("/twitter/tweet/1" == GetRequest!Tweet("twitter", "tweet", "1").uri);
    }
}
