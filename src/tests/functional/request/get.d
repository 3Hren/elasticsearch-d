import elasticsearch.client;
import elasticsearch.detail.log;
import elasticsearch.domain.action.request.document.get;
import elasticsearch.testing;

class GetRequestTestCase : BaseTestCase!GetRequestTestCase {
    struct Tweet {
        string message;
    }

    @Test("GetRequest")
    unittest {
        Client client = new Client();
        GetRequest request = GetRequest("twitter", "tweet", "1");
        Tweet tweet = client.get!Tweet(request);

        log!(Level.trace)("'GetRequest' finished: %s\n", tweet);
    }

    @Test("GetRequest with automatic index detecting")
    unittest {
        auto settings = ClientSettings("twitter");
        auto client = new Client(settings);
        Tweet tweet = client.get!Tweet("tweet", "1");
        log!(Level.trace)("'GetRequest' finished: %s\n", tweet);
    }
}
