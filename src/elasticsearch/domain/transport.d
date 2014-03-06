module elasticsearch.domain.transport;

import std.conv;
import std.socket;

import elasticsearch.connection.http;
import elasticsearch.connection.pool;
import elasticsearch.detail.log;
import elasticsearch.domain.response.base;
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
		AddressInfo[] infos = getAddressInfo(settings.host, to!string(settings.port), SocketType.STREAM, ProtocolType.TCP);		
		foreach (AddressInfo info; infos) {			
			addNode(info.address);
		}

		if (settings.nodeUpdate.onStart) {
			log!(Level.trace)("updating nodes list ...");
		}
	}

	public void addNode(Address address) {
		log!(Level.trace)("adding node %s ...", address);
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

	private void updateNodesList() {

	}
}