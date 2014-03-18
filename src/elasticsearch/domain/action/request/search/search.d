module elasticsearch.domain.action.request.search.search;

import std.array;
import std.algorithm;
import std.conv;

import vibe.inet.path;

import elasticsearch.domain.action.request.base;
import elasticsearch.domain.action.request.method;

string join(const string[] array, string separator = ",") {
    if (array.length == 0) {
        return "";
    }

    string result;
    for (ulong i = 0; i < array.length - 1; i++) {
        result ~= array[i] ~ separator;
    }

    result ~= array[$ - 1];
    return result;
}

struct SearchRequest {
    enum Method = ElasticsearchMethod.GET;
    mixin UriBasedRequest!SearchRequest;

    private string[] indices;

    public this(string[] indices...) {
        this.indices = indices.dup;
    }

    private void buildUri(UriBuilder builder) const {
        if (indices.length == 0) {
            builder.setPath("_all", "_search");
        } else {
            builder.setPath(join(indices), "_search");
        }
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

unittest {
    // Single index constructor properly maps into uri.
    SearchRequest request = SearchRequest("twitter");
    Assert.equals("/twitter/_search", request.uri);
}

unittest {
    // Multiple index constructor properly maps into uri.
    SearchRequest request = SearchRequest("twitter", "city");
    Assert.equals("/twitter,city/_search", request.uri);
}
