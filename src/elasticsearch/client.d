module elasticsearch.client;

import vibe.data.serialization;
import vibe.data.json;

import elasticsearch.detail.log;
import elasticsearch.domain.response.base;
import elasticsearch.domain.response.document.index;
import elasticsearch.domain.request.base;
import elasticsearch.domain.request.method;
import elasticsearch.domain.request.document.index;
import elasticsearch.domain.transport;

struct ClientSettings {
	string index;
}

class Client {
	private ClientSettings clientSettings = ClientSettings("default");
	private Transport transport;

	public this() {
		transport = new Transport();
	}

	// Index will be default from settings. Type will be T type name with 's' suffix. Id will be generated automatically.
	//public IndexResponse index(T)(T post) {}	

	// More control over parameters.
	//public IndexResponse index(T)(string index, string type, string id, T post) {}
	//public IndexResponse index(T)(string index, string type, T post) {}
	//public IndexResponse index(T)(string index, T post) {}

	// Full parameters control.
	public IndexResponse index(T)(IndexRequest action, T post) {
		alias Method = IndexRequest.Method;

		immutable string path = action.path();			
		immutable string data = serializeToJson(post).toString();		
		ElasticsearchRequest!Method request = ElasticsearchRequest!Method(path, data);
		ElasticsearchResponse!Method response = transport.perform(request);
		IndexResponse.Result result = deserializeJson!(IndexResponse.Result)(response.data);		
		return IndexResponse(response, result);
	}
}