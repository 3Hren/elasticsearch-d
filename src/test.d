import std.stdio;

import elasticsearch.client;
import elasticsearch.domain.request.document.index;
import elasticsearch.domain.response.document.index;

struct Tweet {
	string message;	
}

int main(string[] args) {	
	IndexRequest request = IndexRequest("twitter", "tweet", "1");
	Tweet tweet = Tweet("Wow, I'm using elasticsearch!");	

	Client client = new Client();
	for (int i = 0; i < 4; i++) {
		IndexResponse response = client.index(request, tweet);
		writeln(response);
	}
	return 0;
}