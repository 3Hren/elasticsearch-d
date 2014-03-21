module elasticsearch.domain.action.request.document.get;

import std.algorithm;
import std.conv;
import std.string;

import vibe.data.json;
import vibe.http.common;
import vibe.inet.path;

import elasticsearch.detail.string;
import elasticsearch.domain.action.request.base;
import elasticsearch.testing;

struct GetRequest(T = Json) {
    alias Type = T;
    enum method = HTTPMethod.GET;
    mixin UriBasedRequest!(typeof(this));

    enum Preference {
        PRIMARY,
        LOCAL
    }

    private string index;
    private string type;
    private string id;
    private string include;
    private string exclude;
    private string[] fields;
    private string routing;
    private string preference;
    private bool refresh;

    public this() @disable;

    public this(string index, string type, string id) {
        this.index = index;
        this.type = type;
        this.id = id;
    }

    public void setInclude(string pattern) {
        this.include = pattern;
    }

    public void setExclude(string pattern) {
        this.exclude = pattern;
    }

    public void setFields(in string[] fields...) {
        this.fields = fields.dup;
    }

    public void setRouting(string routing) {
        this.routing = routing;
    }

    public void setPreference(Preference preference)() {
        static if (preference == Preference.PRIMARY) {
            this.preference = "_primary";
        } else {
            this.preference = "_local";
        }
    }

    public void setPreference(string preference) {
        this.preference = preference;
    }

    public void setRefresh(bool refresh) {
        this.refresh = refresh;
    }

    private void buildUri(UriBuilder builder) const {
        builder.setPath(index, type, id);
        builder.addParameter("_source_include", include.toLower);
        builder.addParameter("_source_exclude", exclude.toLower);
        builder.addParameter!false("fields", Strings.join(fields));
        builder.addParameter("routing", routing.toLower);
        builder.addParameter("preference", preference.toLower);
        if (refresh) {
            builder.addParameter("refresh", to!string(refresh));
        }
    }
}

//! ==================== UNIT TESTS ====================

class GetRequestTestCase : BaseTestCase!GetRequestTestCase {
    struct Tweet {
        string message;
    }

    @Test("Base initialization constructor")
    unittest {
        Assert.equals("/twitter/tweet/1", GetRequest!Tweet("twitter", "tweet", "1").uri);
    }

    @Test("Allows to specify source include")
    unittest {
        auto request = GetRequest!Tweet("twitter", "tweet", "1");
        request.setInclude("*.id");
        Assert.equals("/twitter/tweet/1?_source_include=*.id", request.uri);
    }

    @Test("Allows to specify source exclude")
    unittest {
        auto request = GetRequest!Tweet("twitter", "tweet", "1");
        request.setExclude("entities");
        Assert.equals("/twitter/tweet/1?_source_exclude=entities", request.uri);
    }

    @Test("Allows to specify fields")
    unittest {
        auto request = GetRequest!Tweet("twitter", "tweet", "1");
        request.setFields("title", "content");
        Assert.equals("/twitter/tweet/1?fields=title,content", request.uri);
    }

    @Test("Allows to specify routing")
    unittest {
        auto request = GetRequest!Tweet("twitter", "tweet", "1");
        request.setRouting("kimchy");
        Assert.equals("/twitter/tweet/1?routing=kimchy", request.uri);
    }

    @Test("Allows to specify local preference")
    unittest {
        auto request = GetRequest!Tweet("twitter", "tweet", "1");
        request.setPreference!(GetRequest!(Tweet).Preference.LOCAL);
        Assert.equals("/twitter/tweet/1?preference=_local", request.uri);
    }

    @Test("Allows to specify primary preference")
    unittest {
        auto request = GetRequest!Tweet("twitter", "tweet", "1");
        request.setPreference!(GetRequest!(Tweet).Preference.PRIMARY);
        Assert.equals("/twitter/tweet/1?preference=_primary", request.uri);
    }

    @Test("Allows to specify custom preference")
    unittest {
        auto request = GetRequest!Tweet("twitter", "tweet", "1");
        request.setPreference("blah");
        Assert.equals("/twitter/tweet/1?preference=blah", request.uri);
    }

    @Test("Allows to specify refresh")
    unittest {
        auto request = GetRequest!Tweet("twitter", "tweet", "1");
        request.setRefresh(true);
        Assert.equals("/twitter/tweet/1?refresh=true", request.uri);
    }
}
