module elasticsearch.exception;

import elasticsearch.domain.action.response.base;

class ElasticsearchError : Error {
    ElasticsearchResponse response;

    public this(string reason, ElasticsearchResponse response) {
        super(reason);
        this.response = response;
    }
}

class PoolIsEmptyError : Error {
    public this() {
        super("pool is empty");
    }
}
