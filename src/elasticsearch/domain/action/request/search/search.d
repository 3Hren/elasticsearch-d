module elasticsearch.domain.action.request.search.search;

import std.array;
import std.algorithm;
import std.conv;
import std.string;

import vibe.inet.path;

import elasticsearch.detail.string;
import elasticsearch.domain.action.request.base;
import elasticsearch.domain.action.request.method;

enum SearchType {
    DFS_QUERY_THEN_FETCH = 0,
    QUERY_THEN_FETCH = 1,
    DFS_QUERY_AND_FETCH = 2,
    QUERY_AND_FETCH = 3,
    SCAN = 4,
    COUNT = 5,

    DEFAULT = QUERY_THEN_FETCH
}

struct SearchRequest {
    enum Method = ElasticsearchMethod.GET;
    mixin UriBasedRequest!SearchRequest;

    private const string[] indices;
    private string[] types;
    private SearchType searchType = SearchType.DEFAULT;
    private string query;

    public this(const string[] indices...) {
        this.indices = indices.dup;
    }

    public void setType(const string type) {
        setTypes(type);
    }

    public void setTypes(const string[] types...) {
        this.types = types.dup;
    }

    public void setSearchType(SearchType searchType) {
        this.searchType = searchType;
    }

    public void setQuery(const string query) {
        this.query = query.dup;
    }

    public string data() const @property {
        return query;
    }

    private void buildUri(UriBuilder builder) const {
        if (indices.length == 0) {
            builder.setPath("_all", Strings.join(types), "_search");
        } else {
            builder.setPath(Strings.join(indices), Strings.join(types), "_search");
        }

        if (searchType != SearchType.DEFAULT) {
            builder.addParameter("search_type", to!string(searchType).toLower());
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

unittest {
    // Accepts type field.
    SearchRequest request = SearchRequest("twitter");
    request.setType("tweet");
    Assert.equals("/twitter/tweet/_search", request.uri);
}

unittest {
    // Allows to specify multiple types.
    SearchRequest request = SearchRequest("twitter");
    request.setTypes("tweet", "compiler");
    Assert.equals("/twitter/tweet,compiler/_search", request.uri);
}

unittest {
    // Allows to specify search type.
    SearchRequest request = SearchRequest("twitter");
    request.setSearchType(SearchType.DFS_QUERY_THEN_FETCH);
    Assert.equals("/twitter/_search?search_type=dfs_query_then_fetch", request.uri);
}

unittest {
    // Allows to specify raw query.
    SearchRequest request = SearchRequest();
    request.setQuery(`{"query": {"match": {"message": "Wow!"}}}`);
    Assert.equals(`{"query": {"match": {"message": "Wow!"}}}`, request.data);
}
