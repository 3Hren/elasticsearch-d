module elasticsearch.domain.request.cluster.node.info;

import std.array;
import std.conv;
import std.stdio;
import std.traits;

import elasticsearch.domain.request.method;
import elasticsearch.detail.string;

struct NodesInfoRequest {
    enum Method = ElasticsearchMethod.get;

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

    Type type;    

    public string path() {             
        // TODO: Selective nodes. 
        return "/_nodes/_all/" ~ typeToString(type);
    }

    private static string typeToString(Type type) {
        if (type == Type.none || type == Type.all) {
            return to!string(type);
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

unittest {
    assert("/_nodes/_all/none" == NodesInfoRequest(NodesInfoRequest.Type.none).path);    
    assert("/_nodes/_all/settings" == NodesInfoRequest(NodesInfoRequest.Type.settings).path);
    assert("/_nodes/_all/os" == NodesInfoRequest(NodesInfoRequest.Type.os).path);
    assert("/_nodes/_all/process" == NodesInfoRequest(NodesInfoRequest.Type.process).path);
    assert("/_nodes/_all/jvm" == NodesInfoRequest(NodesInfoRequest.Type.jvm).path);
    assert("/_nodes/_all/thread_pool" == NodesInfoRequest(NodesInfoRequest.Type.threadPool).path);
    assert("/_nodes/_all/network" == NodesInfoRequest(NodesInfoRequest.Type.network).path);
    assert("/_nodes/_all/transport" == NodesInfoRequest(NodesInfoRequest.Type.transport).path);
    assert("/_nodes/_all/http" == NodesInfoRequest(NodesInfoRequest.Type.http).path);
    assert("/_nodes/_all/plugins" == NodesInfoRequest(NodesInfoRequest.Type.plugins).path);
    assert("/_nodes/_all/all" == NodesInfoRequest(NodesInfoRequest.Type.all).path);

    assert("/_nodes/_all/settings,os" == NodesInfoRequest(NodesInfoRequest.Type.settings | NodesInfoRequest.Type.os).path);
}