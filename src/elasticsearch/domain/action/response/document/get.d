module elasticsearch.domain.action.response.document.get;

import vibe.data.json;

import elasticsearch.domain.action.response.base;
import elasticsearch.domain.action.request.document.get;

struct GetResult(T) {
    @name("_index")
    string index;

    @name("_type")
    string type;

    @name("_id")
    string id;

    @name("_version")
    ulong _version;

    @name("found")
    bool found;

    @name("_source")
    T source;

    public R field(R)(string name) {
        return deserializeJson!R(source[name]);
    }
}

struct GetResponse(T) {
    mixin Response!(GetRequest!T, GetResult!T);
}
