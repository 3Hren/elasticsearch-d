module elasticsearch.client;

import std.algorithm;
import std.container;
import std.conv;
import std.socket;
import std.stdio;
import std.range;

import vibe.data.serialization;
import vibe.data.json;

import elasticsearch.connection.http;
import elasticsearch.connection.pool;

struct IndexRequest {
	enum Method = HTTP.Method.put;

	string index;
	string type;
	string id;

	public string path() {
		return "/" ~ to!string(joiner([index, type, id], "/"));
	}
}

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

struct ClientSettings {
	string index;
}

class Transport {
	enum DEFAULT_HOST = "localhost";
	enum DEFAULT_PORT = 9200;

	private ClientPool!NodeClient pool;

	public this() {
		AddressInfo[] infos = getAddressInfo(DEFAULT_HOST, to!string(DEFAULT_PORT), SocketType.STREAM, ProtocolType.TCP);		
		foreach (AddressInfo info; infos) {			
			addNode(info.address);
		}
	}

	public void addNode(Address address) {
		debug { writeln("Adding node ", address); }
		pool.add(new HttpNodeClient(address));
	}

	public ElasticsearchResponse!Method perform(HTTP.Method Method)(ElasticsearchRequest!Method request) {
		if (pool.empty()) {
			throw new Error("pool is empty");
		}

		NodeClient client = pool.next();
		try {
			return client.perform(request);
		} catch (CurlException error) {
			debug { writeln("Request failed: ", error.msg); }
			pool.remove(client);
			return perform(request);
		}
	}
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