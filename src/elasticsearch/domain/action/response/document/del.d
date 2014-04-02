module elasticsearch.domain.action.response.document.del;

import vibe.data.json;

import elasticsearch.domain.action.response.base;
import elasticsearch.domain.action.request.document.del;

struct DeleteResult {
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
}

struct DeleteResponse {
    mixin Response!(DeleteRequest, DeleteResult);
}
