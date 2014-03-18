module elasticsearch.domain.action.request.search.search;

import std.array;
import std.algorithm;
import std.conv;
import std.datetime;
import std.string;
import std.stdio;

import vibe.inet.path;

import elasticsearch.detail.string;
import elasticsearch.detail.log;
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

struct Test {
    string name;
}

interface TestCase {
    public void run();
}

template Tuple(T...) {
    alias Tuple = T;
}

class BaseTestCase(T) : TestCase {
    enum Color {
        RED,
        GREEN
    }

    public override void run() {
        alias tests = Tuple!(__traits(getUnitTests, T));
        StopWatch sw;
        ulong last = 0;

        writefln("%s %d tests from '%s'", colored("[----------]", Color.GREEN), tests.length, T.stringof);
        foreach (test; tests) {
            alias attributes = Tuple!(__traits(getAttributes, test));
            static assert(attributes.length == 1);

            string name = attributes[0].name;
            try {
                writefln("%s %s '%s' ...", colored("[ RUN      ]", Color.GREEN), T.stringof, name);
                sw.start();
                test();
                sw.stop();
                writefln("%s %s '%s' (%d us)", colored("[       OK ]", Color.GREEN), T.stringof, name, sw.peek.usecs - last);
                last = sw.peek.usecs;
            } catch (Exception err) {
                writefln("%s %s '%s' - %s", colored("[     FAIL ]", Color.RED), T.stringof, name, err.msg);
            }
        }
    }

    private string colored(string text, Color color) {
        return "\033[1;" ~ to!string(31 + to!int(color)) ~ "m" ~ text ~ "\033[0m";
    }
}

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
