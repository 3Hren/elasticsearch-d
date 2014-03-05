module elasticsearch.domain.response.base;

import elasticsearch.domain.request.method;
import elasticsearch.domain.request.base;

struct ElasticsearchResponse(ElasticsearchMethod Method) {
	bool success;	
	uint code;	
	string address;

	// string[] headers; Really need?
	static if (Method == ElasticsearchMethod.put || Method == ElasticsearchMethod.post) {
		string data;
	}

	ElasticsearchRequest!Method request;
}