module elasticsearch.domain.response.cluster.node.stats;

import vibe.data.json;

import elasticsearch.domain.response.base;
import elasticsearch.domain.request.cluster.node.stats;

struct NodeStats {
}

struct NodesStats {
	@name("cluster_name") string clusterName;
	NodeStats[string] nodes;
}

struct NodesStatsResponse {
	mixin Response!(NodesStatsRequest, NodesStats);
}