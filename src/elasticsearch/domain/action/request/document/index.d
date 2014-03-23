module elasticsearch.domain.action.request.document.index;

import std.algorithm;
import std.conv;
import std.datetime;
import std.typecons;
import std.uri;

import vibe.http.common;

import elasticsearch.domain.action.request.base;
import elasticsearch.testing;

mixin template BaseIndexRequest(HTTPMethod Method) {
    enum method = Method;
    mixin UriBasedRequest!(typeof(this));

    private string index;
    private string type;
    private string id;
    private Nullable!ulong documentVersion;
    private string operationType;
    private string routing;
    private string parent;
    private string timestamp;
    private string timeToLive;
    private string timeout;

    public this() @disable;

    private void buildUri(UriBuilder builder) const {
        builder.setPath(index, type, id);
        builder.addParameter("version", documentVersion);
        builder.addParameter("op_type", operationType);
        builder.addParameter("routing", routing);
        builder.addParameter("parent", parent);
        builder.addParameter("timestamp", timestamp);
        builder.addParameter("ttl", timeToLive);
        builder.addParameter("timeout", timeout);
    }

    public void setDocumentVersion(ulong documentVersion) {
        this.documentVersion = documentVersion;
    }

    public void setCreateMode() {
        this.operationType = "create";
    }

    public void setRouting(string routing) {
        this.routing = routing;
    }

    public void setParent(string parent) {
        this.parent = parent;
    }

    public void setTimestamp(string timestamp) {
        this.timestamp = timestamp;
    }

    public void setTimestamp(DateTime timestamp) {
        this.timestamp = timestamp.toISOExtString();
    }

    public void setTimeToLive(string timeToLive) {
        this.timeToLive = timeToLive;
    }

    public void setTimeout(string timeout) {
        this.timeout = timeout;
    }
}

struct ManualIndexRequest {
    mixin BaseIndexRequest!(HTTPMethod.PUT);

    public this(string index, string type, string id) {
        this.index = index;
        this.type = type;
        this.id = id;
    }
}

struct AutomaticIndexRequest {
    mixin BaseIndexRequest!(HTTPMethod.POST);

    public this(string index, string type) {
        this.index = index;
        this.type = type;
    }
}

//! ==================== UNIT TESTS ====================

class IndexRequestTestCase : BaseTestCase!IndexRequestTestCase {
    @Test("Allows to specify document version")
    unittest {
        auto request = ManualIndexRequest("index", "type", "id");
        request.setDocumentVersion(1);
        assert("/index/type/id?version=1" == request.uri);
    }

    @Test("Allows to specify creation operation")
    unittest {
        auto request = ManualIndexRequest("index", "type", "id");
        request.setCreateMode();
        assert("/index/type/id?op_type=create" == request.uri);
    }

    @Test("Allows to specify routing")
    unittest {
        auto request = ManualIndexRequest("index", "type", "id");
        request.setRouting("kimchi");
        assert("/index/type/id?routing=kimchi" == request.uri);
    }

    @Test("Allows to specify parent")
    unittest {
        auto request = ManualIndexRequest("index", "type", "id");
        request.setParent("1111");
        assert("/index/type/id?parent=1111" == request.uri);
    }

    @Test("Allows to specify timestamp as string")
    unittest {
        auto request = ManualIndexRequest("index", "type", "id");
        request.setTimestamp("2009-11-15T14:12:12");
        assert("/index/type/id?timestamp=2009-11-15T14%3A12%3A12" == request.uri);
    }

    @Test("Allows to specify timestamp as DateTime object")
    unittest {
        auto request = ManualIndexRequest("index", "type", "id");
        request.setTimestamp(DateTime(2009, 11, 15, 14, 12, 12));
        assert("/index/type/id?timestamp=2009-11-15T14%3A12%3A12" == request.uri);
    }

    @Test("Allows to specify ttl")
    unittest {
        auto request = ManualIndexRequest("index", "type", "id");
        request.setTimeToLive("86400000");
        assert("/index/type/id?ttl=86400000" == request.uri);
    }

    @Test("Allows to specify timeout")
    unittest {
        auto request = ManualIndexRequest("index", "type", "id");
        request.setTimeout("5m");
        assert("/index/type/id?timeout=5m" == request.uri);
    }
}
