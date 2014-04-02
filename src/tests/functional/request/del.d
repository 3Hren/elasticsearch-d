import vibe.data.json;

import elasticsearch.client;
import elasticsearch.detail.log;
import elasticsearch.domain.action.request.document.del;
import elasticsearch.exception;
import elasticsearch.testing;

class DeleteRequestTestCase : BaseTestCase!DeleteRequestTestCase {
    @Test("Delete document by providing delete request object")
    unittest {
        auto client = new Client();
        auto request = DeleteRequest("twitter", "tweet", 100500);
        try {
            auto result = client.deleteDocument(request);
            log!(Level.trace)("'DeleteRequest' finished: %s", result);
        } catch (ElasticsearchError err) {
        }
    }

    @Test("Delete by index, type and id")
    unittest {
        auto client = new Client();
        try {
            auto result = client.deleteDocument("twitter", "tweet", "100500");
            log!(Level.trace)("'DeleteRequest' finished: %s", result);
        } catch (ElasticsearchError err) {
        }
    }
}
