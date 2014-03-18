module elasticsearch.domain.action.response.cluster.node.stats;

import vibe.data.json;

import elasticsearch.domain.action.response.base;
import elasticsearch.domain.action.request.cluster.node.stats;

struct NodeStats {
}

struct NodesStats {
    @name("cluster_name") string clusterName;
    NodeStats[string] nodes;
}

struct NodesStatsResponse {
    mixin Response!(NodesStatsRequest, NodesStats);
}