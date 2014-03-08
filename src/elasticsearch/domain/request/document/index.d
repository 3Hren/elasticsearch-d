module elasticsearch.domain.request.document.index;

import std.algorithm;
import std.conv;
import std.uri;

import vibe.inet.path;

import elasticsearch.domain.request.method;

mixin template BaseIndexRequest(ElasticsearchMethod M) {
    enum Method = M;
    private const string path;
    private string[string] parameters;       

    public this() @disable;        

    public string uri() @property const {
        if (parameters.length == 0) {
            return path;
        }

        string[] queries;
        foreach (name, value; parameters) {
            queries ~= name ~ "=" ~ value;
        }
        
        return path ~ "?" ~ to!string(joiner(queries, "&"));
    }

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

    public void ttl(string ttl) @property {
        addParameter("ttl", ttl);
    }

    public void timeout(string timeout) @property {
        addParameter("timeout", timeout);
    }

    private void addParameter(string name, string value) {
        parameters[name] = std.uri.encodeComponent(value);
    }
}

struct ManualIndexRequest {
    mixin BaseIndexRequest!(ElasticsearchMethod.put);

    public this(string index, string type, string id) {
        immutable(PathEntry)[] entries = [PathEntry(index), PathEntry(type), PathEntry(id)];
        this.path = Path(entries, true).toString;
    }
}

struct AutomaticIndexRequest {    
    mixin BaseIndexRequest!(ElasticsearchMethod.post);

    public this(string index, string type) {
        immutable(PathEntry)[] entries = [PathEntry(index), PathEntry(type)];
        this.path = Path(entries, true).toString;
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
    request.ttl = "86400000";    
    assert("/index/type/id?ttl=86400000" == request.uri);
}

unittest {
    auto request = ManualIndexRequest("index", "type", "id");
    request.timeout = "5m";    
    assert("/index/type/id?timeout=5m" == request.uri);
}