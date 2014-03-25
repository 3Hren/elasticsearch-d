module elasticsearch.domain.action.request.document.del;

import std.array;
import std.conv;
import std.exception;
import std.string;
import std.typecons;

import vibe.http.common;

import elasticsearch.domain.action.request.base;
import elasticsearch.testing;

public enum VersionType {
    INTERNAL,
    EXTERNAL,
    EXTERNAL_GTE,
    FORCE
}

struct DeleteRequest {
    enum method = HTTPMethod.DELETE;
    mixin UriBasedRequest!DeleteRequest;

    enum Consistency {
        ONE,
        QUORUM,
        ALL
    }

    enum Replication {
        SYNC,
        ASYNC
    }

    private string index;
    private string type;
    private string id;

    private Consistency consistency_ = Consistency.QUORUM;
    private string parent_;
    private bool refresh_;
    private Replication replication_ = Replication.SYNC;
    private string routing_;
    private string timeout_;
    private Nullable!ulong version_;
    private VersionType versionType_;

    public this() @disable;

    public this(string index, string type, string id) {
        enforce(!index.empty && !type.empty && !id.empty, "all fields are required");

        this.index = index;
        this.type = type;
        this.id = id;
    }

    public this(T : int)(string index, string type, T id) {
        enforce(!index.empty && !type.empty, "all fields are required");

        this.index = index;
        this.type = type;
        this.id = to!string(id);
    }

    public void consistency(Consistency consistency) @property {
        this.consistency_ = consistency;
    }

    public void parent(string parent) @property {
        this.parent_ = parent;
    }

    public void refresh(bool refresh = true) @property {
        this.refresh_ = refresh;
    }

    public void replication(Replication replication) @property {
        this.replication_ = replication;
    }

    public void routing(string routing) @property {
        this.routing_ = routing;
    }

    public void timeout(string timeout) @property {
        this.timeout_ = timeout;
    }

    public void documentVersion(ulong documentVersion) @property {
        this.version_ = documentVersion;
    }

    public void versionType(VersionType versionType) @property {
        this.versionType_ = versionType;
    }

    private void buildUri(UriBuilder builder) const {
        builder.setPath(index, type, id);

        if (consistency_ != Consistency.QUORUM) {
            builder.addParameter("consistency", to!string(consistency_).toLower);
        }

        builder.addParameter("parent", parent_);

        if (refresh_) {
            builder.addParameter("refresh", to!string(refresh_));
        }

        if (replication_ != Replication.SYNC) {
            builder.addParameter("replication", to!string(replication_).toLower);
        }

        builder.addParameter("routing", routing_);
        builder.addParameter("timeout", timeout_);

        if (!version_.isNull) {
            builder.addParameter("version", to!string(version_));
        }

        if (versionType_ != VersionType.INTERNAL) {
            builder.addParameter("version_type", to!string(versionType_).toLower);
        }
    }
}

class DeleteRequestTestCase : BaseTestCase!DeleteRequestTestCase {
    @Test("Method is delete")
    unittest {
        Assert.equals(HTTPMethod.DELETE, DeleteRequest.method);
    }

    @Test("Basic uri")
    unittest {
        auto request = DeleteRequest("twitter", "tweet", "1");
        Assert.equals("/twitter/tweet/1", request.uri);
    }

    @Test("Throws exception if index is empty")
    unittest {
        try {
            DeleteRequest("", "tweet", "1");
        } catch (Exception err) {
            Assert.equals("all fields are required", err.msg);
        }
    }

    @Test("Support integer id")
    unittest {
        auto request = DeleteRequest("twitter", "tweet", 1);
        Assert.equals("/twitter/tweet/1", request.uri);
    }

    @Test("Parameter: consistency")
    unittest {
        auto request = DeleteRequest("twitter", "tweet", 1);
        request.consistency = DeleteRequest.Consistency.ONE;
        Assert.equals("/twitter/tweet/1?consistency=one", request.uri);
    }

    @Test("Parameter: parent")
    unittest {
        auto request = DeleteRequest("twitter", "tweet", 1);
        request.parent = "tweetty";
        Assert.equals("/twitter/tweet/1?parent=tweetty", request.uri);
    }

    @Test("Parameter: refresh")
    unittest {
        auto request = DeleteRequest("twitter", "tweet", 1);
        request.refresh = true;
        Assert.equals("/twitter/tweet/1?refresh=true", request.uri);
    }

    @Test("Parameter: replication")
    unittest {
        auto request = DeleteRequest("twitter", "tweet", 1);
        request.replication = DeleteRequest.Replication.ASYNC;
        Assert.equals("/twitter/tweet/1?replication=async", request.uri);
    }

    @Test("Parameter: routing")
    unittest {
        auto request = DeleteRequest("twitter", "tweet", 1);
        request.routing = "route";
        Assert.equals("/twitter/tweet/1?routing=route", request.uri);
    }

    @Test("Parameter: timeout (string)")
    unittest {
        auto request = DeleteRequest("twitter", "tweet", 1);
        request.timeout = "5m";
        Assert.equals("/twitter/tweet/1?timeout=5m", request.uri);
    }

    @Test("Parameter: version")
    unittest {
        auto request = DeleteRequest("twitter", "tweet", 1);
        request.documentVersion = 2;
        Assert.equals("/twitter/tweet/1?version=2", request.uri);
    }

    @Test("Parameter: version type")
    unittest {
        auto request = DeleteRequest("twitter", "tweet", 1);
        request.versionType = VersionType.EXTERNAL;
        Assert.equals("/twitter/tweet/1?version_type=external", request.uri);
    }
}
