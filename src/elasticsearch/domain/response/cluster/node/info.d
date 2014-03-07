module elasticsearch.domain.response.cluster.node.info;

import vibe.data.json : Name = name;

import elasticsearch.domain.response.base;
import elasticsearch.domain.request.cluster.node.info;

struct NodeInfo {
    @Name("name")
    string name;

    @Name("transport_address") 
    string transportAddress;

    @Name("host")
    string host;

    @Name("ip")
    string ip;

    @Name("version")
    string version_;

    @Name("build")
    string build;

    @Name("http_address") 
    string httpAddress;
}

struct NodesInfo {
    @Name("cluster_name")
    string clusterName;

    @Name("nodes")
    NodeInfo[string] nodes;
}

struct NodesInfoResponse {
    mixin Response!(NodesInfoRequest, NodesInfo);
}