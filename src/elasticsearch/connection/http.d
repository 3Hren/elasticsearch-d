module elasticsearch.connection.http;

import std.conv;
import std.net.curl : CurlException, curlPut = put, curlHead = connect;
import std.socket;
import std.stdio;

import elasticsearch.detail.log;
import elasticsearch.domain.request.method;
import elasticsearch.domain.request.base;
import elasticsearch.domain.response.base;

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
	public abstract ElasticsearchResponse!(ElasticsearchMethod.put) perform(ElasticsearchRequest!(ElasticsearchMethod.put) request);	
	//public ElasticsearchResponse perform(ElasticsearchRequest!(HTTP.Method.post) request);	
}

class HttpNodeClient : NodeClient {
	public this(Address address) {
		super(address);
	}

	public override ElasticsearchResponse!(ElasticsearchMethod.put) perform(ElasticsearchRequest!(ElasticsearchMethod.put) request) {
		string url = getUrl(request);
		log!(Level.trace)("requesting %s", url);
		char[] content = curlPut(url, request.data);
		log!(Level.trace)("received data %s", content);
		return ElasticsearchResponse!(ElasticsearchMethod.put)(true, 200, address, to!string(content), request);
	}	

	private string getUrl(T)(T request) {
		return address ~ request.path;
	}
}