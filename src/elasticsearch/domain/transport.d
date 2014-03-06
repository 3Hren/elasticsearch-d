module elasticsearch.domain.transport;

import std.algorithm;
import std.conv;
import std.regex;
import std.socket : Address, AddressInfo, SocketType, ProtocolType;

import vibe.data.serialization;
import vibe.data.json;

import elasticsearch.connection.http;
import elasticsearch.connection.pool;
import elasticsearch.exception;
import elasticsearch.detail.log;
import elasticsearch.domain.response.base;
import elasticsearch.domain.response.cluster.node.info;
import elasticsearch.domain.request.base;
import elasticsearch.domain.request.method;

struct NodeUpdateSettings {
	bool onStart = true;
	bool onConnectionError = true;
	ulong interval = 60000;
	ulong timeout = 10;	
}

struct TransportSettings {
	enum DEFAULT_HOST = "localhost";
	enum DEFAULT_PORT = 9200;

	string host = DEFAULT_HOST;
	uint port = DEFAULT_PORT;
	uint maxRetries = 3;
	NodeUpdateSettings nodeUpdate;
}

class Transport {	
	private TransportSettings settings;
	private ClientPool!NodeClient pool;	

	public this(TransportSettings settings = TransportSettings()) {
		AddressInfo[] infos = std.socket.getAddressInfo(settings.host, to!string(settings.port), SocketType.STREAM, ProtocolType.TCP);
		foreach (AddressInfo info; infos) {			
			addNode(info.address);
		}

		if (settings.nodeUpdate.onStart) {
			log!(Level.trace)("updating nodes list ...");
			updateNodesList();
		}
	}

	public void addNode(Address address) {
		log!(Level.trace)("adding node %s ...", address);		
		pool.add(new HttpNodeClient(address));
	}

	public ElasticsearchResponse!Method perform(ElasticsearchMethod Method)(ElasticsearchRequest!Method request) {
		log!(Level.trace)("performing %s ...", request);
		if (pool.empty()) {
			throw new PoolIsEmptyError();			
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

	private void updateNodesList() {
		log!(Level.trace)("updating nodes list ...");
		ElasticsearchRequest!(ElasticsearchMethod.get) request = ElasticsearchRequest!(ElasticsearchMethod.get)("/_nodes/_all/none");
		ElasticsearchResponse!(ElasticsearchMethod.get) response = perform(request);		
		NodesInfoResponse.Result result = deserializeJson!(NodesInfoResponse.Result)(response.data);		
		
		log!(Level.trace)("nodes list successfully updated: %s", map!(node => node.httpAddress)(result.nodes.values));
		foreach (node; result.nodes) {
			try {
				Address address = parseAddress(node.httpAddress);
				addNode(address);
			} catch (std.socket.SocketException err) {
				log!(Level.trace)("failed to parse %s: %s", node.httpAddress, err.msg);
			}
		}
	}

	private Address parseAddress(in string address) {
		enum RX = ctRegex!(`^inet\[(?P<domain>.*)/(?P<ip>.+):(?P<port>\d+)\]$`); // inet[/127.0.0.1:9200]

		auto captures = matchFirst(address, RX);
		string ip = captures["ip"];
		ushort port = to!ushort(captures["port"]);
		return std.socket.parseAddress(ip, port);
	}
}