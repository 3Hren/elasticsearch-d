module elasticsearch.domain.action.request.cluster.node.stats;

import vibe.http.common;

struct NodesStatsRequest {
    enum method = HTTPMethod.GET;
}
