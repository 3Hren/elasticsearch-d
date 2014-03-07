module elasticsearch.domain.request.document.index;

import vibe.inet.path;

import elasticsearch.domain.request.method;

mixin template BaseIndexRequest(ElasticsearchMethod M) {
    enum Method = M;
    private const string path;

    //q TODO: ulong version
    //pq TODO: bool create
    //q TODO: string routing
    //q TODO: string parent
    //q TODO: datetime timestamp
    //q TODO: ulong ttl
    //q TODO: ulong timeout

    public this() @disable;        

    public string uri() @property const {
        return path;
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
