module elasticsearch.domain.response.base;

import elasticsearch.domain.request.method;
import elasticsearch.domain.request.base;

struct ElasticsearchResponse(ElasticsearchMethod Method) {
    bool success;   
    uint code;  
    string address;

    // string[] headers; Really need?
    string data;

    ElasticsearchRequest!Method request;
}

template Response(Request, R) {
    enum Method = Request.Method;
    alias Result = R;

    ElasticsearchResponse!Method response;  
    Result result;
}