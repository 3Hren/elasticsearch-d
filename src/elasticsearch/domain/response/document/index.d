module elasticsearch.domain.response.document.index;

import elasticsearch.domain.response.base;
import elasticsearch.domain.request.document.index;

import vibe.data.json;

struct IndexResult {
	@name("_index") string index;
	@name("_type") string type;
	@name("_id") string id;
	ulong _version;
	bool created;
}

struct IndexResponse {
	mixin Response!(IndexRequest, IndexResult);
}