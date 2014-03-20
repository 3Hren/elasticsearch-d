module elasticsearch.domain.action.request.cluster.node.info;

import std.array;
import std.conv;
import std.stdio;
import std.traits;

import elasticsearch.domain.action.request.base;
import elasticsearch.domain.action.request.method;
import elasticsearch.detail.string;
import elasticsearch.testing;

struct NodesInfoRequest {
    enum method = ElasticsearchMethod.GET;
    mixin UriBasedRequest!NodesInfoRequest;

    enum Type {
        none        = 1 << 0,
        settings    = 1 << 1,
        os          = 1 << 2,
        process     = 1 << 3,
        jvm         = 1 << 4,
        threadPool  = 1 << 5,
        network     = 1 << 6,
        transport   = 1 << 7,
        http        = 1 << 8,
        plugins     = 1 << 9,
        all = settings | os | process | jvm | threadPool | network | transport | http | plugins
    }

    private string nodes;
    private Type type = Type.all;

    public this(Type type) {
        this.type = type;
    }

    public this(string node, Type type = Type.all) {
        this([node], type);
    }

    public this(string[] nodes, Type type = Type.all) {
        this.nodes = to!string(Strings.join(nodes));
        this.type = type;
    }

    private void buildUri(UriBuilder builder) const {
        if (nodes.empty) {
            builder.setPath("_nodes", "_all", typeToString(type));
        } else {
            builder.setPath("_nodes", nodes, typeToString(type));
        }
    }

    private static string typeToString(Type type) {
        if (type == Type.none) {
            return to!string(type);
        }

        if (type == Type.all) {
            return "";
        }

        auto writer = appender!string;
        foreach (immutable flag; EnumMembers!Type) {
            if ((type & flag) == flag) {
                if (!writer.data.empty()) {
                    writer.put(",");
                }
                writer.put(to!string(flag).underscored);
            }
        }

        return writer.data;
    }
}

//! ==================== UNIT TESTS ====================

class InfoRequestTestCase : BaseTestCase!InfoRequestTestCase {
    @Test("By default requests all info from all nodes")
    unittest {
        assert("/_nodes/_all/" == NodesInfoRequest().uri);
    }

    @Test("Various types of settings")
    unittest {
        assert("/_nodes/_all/none" == NodesInfoRequest(NodesInfoRequest.Type.none).uri);
        assert("/_nodes/_all/settings" == NodesInfoRequest(NodesInfoRequest.Type.settings).uri);
        assert("/_nodes/_all/os" == NodesInfoRequest(NodesInfoRequest.Type.os).uri);
        assert("/_nodes/_all/process" == NodesInfoRequest(NodesInfoRequest.Type.process).uri);
        assert("/_nodes/_all/jvm" == NodesInfoRequest(NodesInfoRequest.Type.jvm).uri);
        assert("/_nodes/_all/thread_pool" == NodesInfoRequest(NodesInfoRequest.Type.threadPool).uri);
        assert("/_nodes/_all/network" == NodesInfoRequest(NodesInfoRequest.Type.network).uri);
        assert("/_nodes/_all/transport" == NodesInfoRequest(NodesInfoRequest.Type.transport).uri);
        assert("/_nodes/_all/http" == NodesInfoRequest(NodesInfoRequest.Type.http).uri);
        assert("/_nodes/_all/plugins" == NodesInfoRequest(NodesInfoRequest.Type.plugins).uri);
        assert("/_nodes/_all/" == NodesInfoRequest(NodesInfoRequest.Type.all).uri);

        assert("/_nodes/_all/settings,os" == NodesInfoRequest(NodesInfoRequest.Type.settings | NodesInfoRequest.Type.os).uri);
    }

    @Test("Can specify nodes")
    unittest {
        assert("/_nodes/node1/" == NodesInfoRequest("node1").uri);
        assert("/_nodes/node1/none" == NodesInfoRequest("node1", NodesInfoRequest.Type.none).uri);
        assert("/_nodes/node1,node2/" == NodesInfoRequest(["node1", "node2"]).uri);
        assert("/_nodes/node1,node2/none" == NodesInfoRequest(["node1", "node2"], NodesInfoRequest.Type.none).uri);
    }
}
