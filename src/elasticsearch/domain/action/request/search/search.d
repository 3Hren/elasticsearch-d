module elasticsearch.domain.action.request.search.search;

import std.algorithm;
import std.conv;

import vibe.inet.path;

import elasticsearch.domain.action.request.base;

struct SearchRequest {
    mixin UriBasedRequest;

    public this() {}
}

//! ========== UNIT TESTS ==========

class AssertError : Exception {
    this(string reason) {
        super(reason);
    }
}

struct Assert {
    static void equals(string expected, string actual) {
        if (expected != actual) {
            throw new AssertError(`assertion failed - expected: "` ~ expected ~ `", actual: "` ~ actual ~ `"`);
        }
    }
}

unittest {
    // Will search all indices by default;
    SearchRequest request = SearchRequest();
    Assert.equals("/_all/_search", request.uri);
}