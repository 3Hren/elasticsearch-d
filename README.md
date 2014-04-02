# Elasticsearch Client for D

Low-level fiber-aware synchronous/asynchronous client for Elasticsearch.

* Almost one-to-one mapping with official REST API.
* Embedded load balancing and nodes synchronization mechanizm.
* Supports both synchronous and asynchronous variants in single API. This becames possible with using powerful asynchronous I/O framework [vibe.d](vibed.org).
* Fiber... Fibers everywhere.
* Strongly typed mapping from json requests/response bodies to the real structs and vice versa.
* Covered by functional and unit tests with pretty unit testing framework.

## Disclaimer

I just needed some elasticsearch mappings for own usages, but code base rapidly growed up.
It is very unstable at this moment, also it's very likely that some API will be changed in the
nearest future.
Currently I don't have much time to develop it, but there will be at least 2 features from
todo list every week.

## Examples

Indexing some own type:
```
struct Tweet {
    string message;
}

Tweet tweet = Tweet("Wow, I'm using elasticsearch!");

Client client = new Client();
auto response = client.index("twitter", "tweet", "1", tweet);
auto result = response.result;

assert("twitter" == result.index);
assert("tweet" == result.type);
assert("1" == result.id);
```

Further getting it:
```
Tweet tweet = client.get!Tweet("twitter", "tweet", "1");
```

Search (only hand-written queries are supported now, query DSL is in plans):
```
SearchRequest request = SearchRequest("twitter");
request.setQuery(`{"query": {"match": {"message": "Wow!"}}}`);

// Will be mapped json object, which is better than string, but not so good as collection of objects.
Json response = client.search(request);
```

More examples you can find in `src/tests` directory.

## Todo

Here are features I'd like to implement. I plan to do at least 2 of them per week:

* Document api
    * Bulk
    * Multi-get
    * Exists
    * Update
    * Delete by query
* Cluster api
    * Health request.
    * Settings
    * Pending tasks
    * Put settings
    * Reroute
    * State
    * Stats
* Search api
    * Count
    * Multi-search
    * Scroll
    * Count percolate
    * Multi-percolate
    * Explain
* Index api
    * Analyze
    * Clear cache
    * Close
    * Create
    * Delete
    * Exists
    * Flush
    * Stats
    * Status
* Nodes api
    * Stats
    * Shutdown
* And much more ...
