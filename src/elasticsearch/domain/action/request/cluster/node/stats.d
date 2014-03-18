module elasticsearch.domain.action.request.cluster.node.stats;

import elasticsearch.domain.action.request.method;

struct NodesStatsRequest {
    enum Method = ElasticsearchMethod.GET;
}
