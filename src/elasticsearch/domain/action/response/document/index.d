module elasticsearch.domain.action.response.document.index;

import elasticsearch.domain.action.response.base;
import elasticsearch.domain.action.request.document.index;

import vibe.data.json;

struct IndexResult {
    @name("_index") string index;
    @name("_type") string type;
    @name("_id") string id;
    ulong _version;
    bool created;
}

struct IndexResponse(Request) {
    mixin Response!(Request, IndexResult);
}
