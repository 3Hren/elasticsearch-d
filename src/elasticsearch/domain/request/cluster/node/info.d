module elasticsearch.domain.request.cluster.node.info;

import elasticsearch.domain.request.method;

struct NodesInfoRequest {
	enum Method = ElasticsearchMethod.get;
}