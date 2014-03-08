module elasticsearch.domain.request.document.index;

import std.algorithm;
import std.conv;

import vibe.inet.path;

import elasticsearch.domain.request.method;



mixin template BaseIndexRequest(ElasticsearchMethod M) {
    enum Method = M;
    private const string path;
    private string[string] parameters;
    //pq TODO: bool create
    //q TODO: string routing
    //q TODO: string parent
    //q TODO: datetime timestamp
    //q TODO: ulong ttl
    //q TODO: ulong timeout

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
        parameters["version"] = to!string(value);
    }

    public void create(bool value) @property {
        parameters["op_type"] = "create";
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