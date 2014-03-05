module elasticsearch.domain.response.document.index;

import elasticsearch.domain.response.base;
import elasticsearch.domain.request.document.index;

import vibe.data.json;

struct IndexResponse {
	enum Method = IndexRequest.Method;

	ElasticsearchResponse!Method response;
	
	struct Result {
		@name("_index") string index;
		@name("_type") string type;
		@name("_id") string id;
		ulong _version;
		bool created;
	}
	Result result;
}