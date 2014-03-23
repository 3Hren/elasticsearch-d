module elasticsearch.domain.action.request.document.del;

import elasticsearch.domain.action.request.base;
import elasticsearch.testing;

struct DeleteRequest {
    mixin UriBasedRequest!DeleteRequest;

    string index;
    string type;
    string id;

    private void buildUri(UriBuilder builder) const {
        builder.setPath(index, type, id);
    }
}

class DeleteRequestTestCase : BaseTestCase!DeleteRequestTestCase {
    @Test("Basic uri")
    unittest {
        auto request = DeleteRequest("twitter", "tweet", "1");
        Assert.equals("/twitter/tweet/1", request.uri);
    }
}
