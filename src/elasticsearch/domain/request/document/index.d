module elasticsearch.domain.request.document.index;

import std.algorithm;
import std.conv;

import elasticsearch.domain.request.method;

struct IndexRequest {
	enum Method = ElasticsearchMethod.put;

	string index;
	string type;
	string id;

	public string path() {
		return "/" ~ to!string(joiner([index, type, id], "/"));
	}
}