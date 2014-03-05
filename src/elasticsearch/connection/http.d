module elasticsearch.connection.http;

import std.conv;
import std.net.curl : HTTP, CurlException, curlPut = put, curlHead = connect;
import std.socket;
import std.stdio;

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