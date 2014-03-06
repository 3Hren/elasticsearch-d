module elasticsearch.domain.request.cluster.node.stats;

import elasticsearch.domain.request.method;

struct NodesStatsRequest {
	enum Method = ElasticsearchMethod.get;
}