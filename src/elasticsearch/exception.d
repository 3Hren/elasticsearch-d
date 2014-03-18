module elasticsearch.exception;

import elasticsearch.domain.action.response.base;
import elasticsearch.domain.action.request.method;

class ElasticsearchError(ElasticsearchMethod Method) : Error {
    ElasticsearchResponse!Method response;

    public this(string reason, ElasticsearchResponse!Method response) {
        super(reason);
        this.response = response;
    }
}

class PoolIsEmptyError : Error {
    public this() {
        super("pool is empty");
    }   
}