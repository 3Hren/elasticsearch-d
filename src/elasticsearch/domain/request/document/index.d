module elasticsearch.domain.request.document.index;

import vibe.inet.path;

import elasticsearch.domain.request.method;

struct IndexRequest {
    enum Method = ElasticsearchMethod.put;

    PathEntry index;
    PathEntry type;
    PathEntry id;

    public this(string index, string type, string id) {
        this.index = PathEntry(index);
        this.type = PathEntry(type);
        this.id = PathEntry(id);        
    }

    public string path() @property const {
        immutable(PathEntry)[] entries = [index, type, id];
        return Path(entries, true).toString;
    }
}