import vibe.data.json;

import elasticsearch.client;
import elasticsearch.detail.log;
import elasticsearch.domain.action.request.document.get;
import elasticsearch.testing;

class GetRequestTestCase : BaseTestCase!GetRequestTestCase {
    struct Tweet {
        string message;
    }

    @Test("GetRequest the simpliest")
    unittest {
        auto client = new Client();
        Tweet tweet = client.get!Tweet("twitter", "tweet", "1");
        log!(Level.trace)("'GetRequest' finished: %s", tweet);
    }

    @Test("GetRequest with automatic index detecting")
    unittest {
        auto settings = ClientSettings("twitter");
        auto client = new Client(settings);
        Tweet tweet = client.get!Tweet("tweet", "1");
        log!(Level.trace)("'GetRequest' finished: %s", tweet);
    }

    @Test("GetRequest using request object and json result")
    unittest {
        auto client = new Client();
        auto request = GetRequest!()("twitter", "tweet", "1");
        Json tweet = client.get(request);
        log!(Level.trace)("'GetRequest' finished: %s", tweet);
    }

    @Test("GetRequest using request object and typed result")
    unittest {
        auto client = new Client();
        auto request = GetRequest!Tweet("twitter", "tweet", "1");
        Tweet tweet = client.get(request);
        log!(Level.trace)("'GetRequest' finished: %s", tweet);
    }

    @Test("GetFullRequest")
    unittest {
        auto client = new Client();
//        auto request = GetRequest!()("twitter", "tweet", "1");
//        auto result = client.getFull(request);
//        Assert.equals("twitter", result.index);
//        Assert.equals("tweet", result.type);
//        Assert.equals("1", result.id);
//        static assert(is(typeof(result.source) == Json), "source type must be Json object");
//        result.source["message"];
//        result.source.to!string("message");
//        result.source.to!(Tweet.message);
//        log!(Level.trace)("'GetRequest' finished: %s", tweet);
    }
}
