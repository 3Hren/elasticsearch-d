module elasticsearch.domain.request.document.index;

import std.algorithm;
import std.conv;
import std.datetime;
import std.uri;

import vibe.inet.path;

import elasticsearch.domain.request.base;
import elasticsearch.domain.request.method;

mixin template BaseIndexRequest(ElasticsearchMethod M) {
    enum Method = M;
    mixin UriBasedRequest;

    public this() @disable;    

    public void version_(ulong value) @property {
        addParameter("version", to!string(value));
    }

    public void create(bool value) @property {        
        addParameter("op_type", "create");
    }

    public void routing(string routing) @property {
        addParameter("routing", routing);        
    }

    public void parent(string parent) @property {
        addParameter("parent", parent);        
    }

    public void timestamp(string timestamp) @property {
        addParameter("timestamp", timestamp);
    }

    public void timestamp(DateTime timestamp) @property {
        addParameter("timestamp", timestamp.toISOExtString());
    }

    public void ttl(string ttl) @property {
        addParameter("ttl", ttl);
    }

    public void timeout(string timeout) @property {
        addParameter("timeout", timeout);
    }
}

struct ManualIndexRequest {
    mixin BaseIndexRequest!(ElasticsearchMethod.put);

    public this(string index, string type, string id) {        
        setPath(index, type, id);
    }
}

struct AutomaticIndexRequest {    
    mixin BaseIndexRequest!(ElasticsearchMethod.post);

    public this(string index, string type) {        
        setPath(index, type);
    }
}

unittest {
    auto request = ManualIndexRequest("index", "type", "id");
    request.version_ = 1;
    assert("/index/type/id?version=1" == request.uri);
}

unittest {
    auto request = ManualIndexRequest("index", "type", "id");
    request.create = true;
    assert("/index/type/id?op_type=create" == request.uri);
}

unittest {
    auto request = ManualIndexRequest("index", "type", "id");
    request.routing = "kimchi";
    assert("/index/type/id?routing=kimchi" == request.uri);
}

unittest {
    auto request = ManualIndexRequest("index", "type", "id");
    request.parent = "1111";
    assert("/index/type/id?parent=1111" == request.uri);
}

unittest {
    auto request = ManualIndexRequest("index", "type", "id");
    request.timestamp = "2009-11-15T14:12:12";    
    assert("/index/type/id?timestamp=2009-11-15T14%3A12%3A12" == request.uri);
}

unittest {
    auto request = ManualIndexRequest("index", "type", "id");
    request.timestamp = DateTime(2009, 11, 15, 14, 12, 12);
    assert("/index/type/id?timestamp=2009-11-15T14%3A12%3A12" == request.uri);
}

unittest {
    auto request = ManualIndexRequest("index", "type", "id");
    request.ttl = "86400000";    
    assert("/index/type/id?ttl=86400000" == request.uri);
}

unittest {
    auto request = ManualIndexRequest("index", "type", "id");
    request.timeout = "5m";    
    assert("/index/type/id?timeout=5m" == request.uri);
}