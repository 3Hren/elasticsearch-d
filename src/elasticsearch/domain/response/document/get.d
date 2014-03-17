module elasticsearch.domain.response.document.get;

import elasticsearch.domain.response.base;
import elasticsearch.domain.request.document.get;

import vibe.data.json;

struct GetResponse(T) {
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
}
