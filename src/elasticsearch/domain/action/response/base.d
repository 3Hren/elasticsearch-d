module elasticsearch.domain.action.response.base;

import elasticsearch.domain.action.request.method;
import elasticsearch.domain.action.request.base;

struct ElasticsearchResponse {
    uint code;
    string address;

    // string[] headers; Really need?
    string data;

    ElasticsearchRequest request;

    public bool success() const @property @safe {
        return code / 100 == 2;
    }
}

template Response(Request, R) {
    alias Result = R;

    ElasticsearchResponse response;
    Result result;
}
