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
import elasticsearch.detail.log;
import elasticsearch.domain.response.base;
import elasticsearch.domain.response.document.index;
import elasticsearch.domain.request.base;
import elasticsearch.domain.request.method;
import elasticsearch.domain.request.document.index;

struct ClientSettings {
	string index;
}

struct NodeUpdateSettings {
	bool onStart = true;
	bool onConnectionError = true;
	ulong interval = 60000;
	ulong timeout = 10;	
}

struct TransportSettings {
	NodeUpdateSettings nodeUpdateSettings;
	uint maxRetries = 3;
}

class Transport {
	enum DEFAULT_HOST = "localhost";
	enum DEFAULT_PORT = 9200;	

	private TransportSettings settings;
	private ClientPool!NodeClient pool;

	public this(TransportSettings settings = TransportSettings()) {
		AddressInfo[] infos = getAddressInfo(DEFAULT_HOST, to!string(DEFAULT_PORT), SocketType.STREAM, ProtocolType.TCP);		
		foreach (AddressInfo info; infos) {			
			addNode(info.address);
		}
	}

	public void addNode(Address address) {
		log!(Level.trace)("adding node %s", address);
		pool.add(new HttpNodeClient(address));
	}

	public ElasticsearchResponse!Method perform(ElasticsearchMethod Method)(ElasticsearchRequest!Method request) {
		if (pool.empty()) {
			throw new Error("pool is empty");
		}

		NodeClient client = pool.next();
		try {
			return client.perform(request);
		} catch (CurlException error) {
			log!(Level.trace)("request failed: %s", error.msg);
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