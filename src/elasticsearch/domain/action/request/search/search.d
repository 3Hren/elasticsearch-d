module elasticsearch.domain.action.request.search.search;

import std.array;
import std.algorithm;
import std.conv;
import std.string;

import vibe.inet.path;

import elasticsearch.detail.string;
import elasticsearch.detail.log;
import elasticsearch.domain.action.request.base;
import elasticsearch.domain.action.request.method;
import elasticsearch.testing;

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

class SearchRequestTestCase : BaseTestCase!SearchRequestTestCase {
    @Test("Will search all indices by default")
    unittest {
        SearchRequest request = SearchRequest();
        Assert.equals("/_all/_search", request.uri);
    }

    @Test("SearchRequest has get method")
    unittest {
        Assert.equals(ElasticsearchMethod.GET, SearchRequest.Method);
    }

    @Test("Single index constructor properly maps into uri")
    unittest {
        SearchRequest request = SearchRequest("twitter");
        Assert.equals("/twitter/_search", request.uri);
    }

    @Test("Multiple index constructor properly maps into uri")
    unittest {
        SearchRequest request = SearchRequest("twitter", "city");
        Assert.equals("/twitter,city/_search", request.uri);
    }

    @Test("Accepts type field")
    unittest {
        SearchRequest request = SearchRequest("twitter");
        request.setType("tweet");
        Assert.equals("/twitter/tweet/_search", request.uri);
    }

    @Test("Allows to specify multiple types")
    unittest {
        SearchRequest request = SearchRequest("twitter");
        request.setTypes("tweet", "compiler");
        Assert.equals("/twitter/tweet,compiler/_search", request.uri);
    }

    @Test("Allows to specify search type")
    unittest {
        SearchRequest request = SearchRequest("twitter");
        request.setSearchType(SearchType.DFS_QUERY_THEN_FETCH);
        Assert.equals("/twitter/_search?search_type=dfs_query_then_fetch", request.uri);
    }

    @Test("Allows to specify raw query")
    unittest {
        SearchRequest request = SearchRequest();
        request.setQuery(`{"query": {"match": {"message": "Wow!"}}}`);
        Assert.equals(`{"query": {"match": {"message": "Wow!"}}}`, request.data);
    }
}
