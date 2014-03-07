module elasticsearch.domain.request.base;

import elasticsearch.domain.request.method;

struct ElasticsearchRequest(ElasticsearchMethod Method) {
    string path;

    static if (Method == ElasticsearchMethod.put || Method == ElasticsearchMethod.post) {
        string data;
    }
}