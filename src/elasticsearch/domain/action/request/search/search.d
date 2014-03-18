module elasticsearch.domain.action.request.search.search;

import std.algorithm;
import std.conv;

import vibe.inet.path;

import elasticsearch.domain.action.request.base;
import elasticsearch.domain.action.request.method;

struct SearchRequest {
    enum Method = ElasticsearchMethod.GET;
    mixin UriBasedRequest!SearchRequest;

    private void buildUri(UriBuilder builder) const {
        builder.setPath("_all", "_search");
    }
}

//! ==================== UNIT TESTS ====================

class AssertError : Exception {
    this(string reason) {
        super(reason);
    }
}

struct Assert {
    static void equals(T)(T expected, T actual) {
        if (expected != actual) {
            throw new AssertError(`assertion failed - expected: "` ~ to!string(expected) ~ `", actual: "` ~ to!string(actual) ~ `"`);
        }
    }
}

unittest {
    // Will search all indices by default.
    SearchRequest request = SearchRequest();
    Assert.equals("/_all/_search", request.uri);
}

unittest {
    // SearchRequest has get method.
    Assert.equals(ElasticsearchMethod.GET, SearchRequest.Method);
}
