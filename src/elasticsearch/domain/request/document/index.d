module elasticsearch.domain.request.document.index;

import vibe.inet.path;

import elasticsearch.domain.request.method;

mixin template BaseIndexRequest() {
    private PathEntry index;
    private PathEntry type;
    private PathEntry id;

    //q TODO: ulong version
    //pq TODO: bool create
    //q TODO: string routing
    //q TODO: string parent
    //q TODO: datetime timestamp
    //q TODO: ulong ttl
    //q TODO: ulong timeout

    public string path() @property const {
        immutable(PathEntry)[] entries = [index, type, id];
        return Path(entries, true).toString;
    }
}

struct ManualIndexRequest {
    enum Method = ElasticsearchMethod.put;    
    mixin BaseIndexRequest;

    public this(string index, string type, string id) {
        this.index = PathEntry(index);
        this.type = PathEntry(type);
        this.id = PathEntry(id);        
    }
}

struct AutomaticIndexRequest {
    enum Method = ElasticsearchMethod.post;
    mixin BaseIndexRequest;

    public this(string index, string type) {
        this.index = PathEntry(index);
        this.type = PathEntry(type);
    }
}
