module elasticsearch.client;

import std.algorithm;
import std.container;
import std.conv;
import std.net.curl : HTTP, CurlException, curlPut = put, curlHead = connect;
import std.socket;
import std.stdio;
import std.range;

import vibe.data.serialization;
import vibe.data.json;

struct ElasticsearchRequest(HTTP.Method Method) {
	string path;

	static if (Method == HTTP.Method.put || Method == HTTP.Method.post) {
		string data;
	}
}

struct ElasticsearchResponse(HTTP.Method Method) {
	bool success;	
	uint code;	
	string address;

	// string[] headers; Really need?
	static if (Method == HTTP.Method.put || Method == HTTP.Method.post) {
		string data;
	}

	ElasticsearchRequest!Method request;
}

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

abstract class NodeClient {
	private string address;

	public this(Address address) {
		this.address = to!string(address);
	}

	public string getAddress() {
		return address;
	}

	//public ElasticsearchResponse perform(ElasticsearchRequest!(HTTP.Method.head) request);
	//public ElasticsearchResponse perform(ElasticsearchRequest!(HTTP.Method.get) request);
	public abstract ElasticsearchResponse!(HTTP.Method.put) perform(ElasticsearchRequest!(HTTP.Method.put) request);	
	//public ElasticsearchResponse perform(ElasticsearchRequest!(HTTP.Method.post) request);	
}

class HttpNodeClient : NodeClient {
	public this(Address address) {
		super(address);
	}

	public override ElasticsearchResponse!(HTTP.Method.put) perform(ElasticsearchRequest!(HTTP.Method.put) request) {
		string url = getUrl(request);
		debug { writeln("Requesting ", url); }
		char[] content = curlPut(url, request.data);
		debug { writeln("Received data ", content); }
		return ElasticsearchResponse!(HTTP.Method.put)(true, 200, address, to!string(content), request);
	}	

	private string getUrl(T)(T request) {
		return address ~ request.path;
	}
}

interface Balancer(R) if (isRandomAccessRange!R) {
	alias Client = ElementType!R;

	Client next(R range);
}

class RoundRobinBalancer(R) : Balancer!R {
	private int current;

	public override Client next(R range) {
		if (current + 1 >= range.length) {
			current = 0;
		}

		Client client = range[current++];
		debug { writeln("Balancing at ", client.getAddress()); }
		return client;
	}	
}

struct ClientPool(Client) {
	private alias Pool = Array!Client;
	private alias PoolRange = Pool.Range;

	private Pool pool;
	private Balancer!PoolRange balancer = new RoundRobinBalancer!PoolRange();

	public bool empty() {
		return pool.empty();
	}

	public bool contains(Client client) {
		foreach (Client c; pool) {
			if (c.getAddress() == client.getAddress()) {
				return true;
			}
		}

		return false;
	}

	public void add(Client client) {
		if (contains(client)) {
			debug { writeln("Client ", client, " already exists in pool"); }
			return;
		}

		pool.insert(client);
	}

	// TODO: void remove(Address address);
	void remove(Client client) {
		bool found = false;
		ulong pos = 0;
		for (ulong i = 0; i < pool.length; i++) {
			Client c = pool[i];
			if (c.getAddress() == client.getAddress()) {
				found = true;
				pos = i;
				break;
			}
		}
		if (!found) {

		} else {
			pool.linearRemove(pool[pos .. pos + 1]);
		}
	}

	public Client next() {
		return balancer.next(pool[]);
	}	
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