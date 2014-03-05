import std.stdio;

import elasticsearch.client;

struct Tweet {
	string message;	
}

int main(string[] args) {	
	IndexRequest request = IndexRequest("twitter", "tweet", "1");
	Tweet tweet = Tweet("Wow, I'm using elasticsearch!");	

	Client client = new Client();
	IndexResponse response = client.index(request, tweet);
	writeln(response);
	return 0;
}