module elasticsearch.domain.action.response.cluster.node.info;

import std.variant;

import vibe.data.json : Name = name, Optional = optional, Json;

import elasticsearch.domain.action.response.base;
import elasticsearch.domain.action.request.cluster.node.info;

struct NodeInfoOSCPU {
    @Name("vendor")
    string vendor;

    @Name("model")
    string model;

    @Name("mhz")
    int mhz;

    @Name("total_cores")
    int totalCores;

    @Name("total_sockets")
    int totalSockets;

    @Name("cores_per_socket")
    int coresPerSocket;

    @Name("cache_size_in_bytes")
    int cacheSizeInBytes;
}

struct NodeInfoMemory {
    @Name("total_in_bytes")
    long totalInBytes;
}

struct NodeInfoOS {
    @Name("refresh_interval")
    int refreshInterval;

    @Name("available_processors")
    int availableProcessors;

    @Name("cpu")
    NodeInfoOSCPU cpu;

    @Name("mem")
    NodeInfoMemory memory;

    @Name("swap")
    NodeInfoMemory swap;
}

struct NodeInfoProcess {
    @Name("refresh_interval")
    int refreshInterval;

    @Name("id")
    int id;

    @Name("max_file_descriptors")
    int maxFileDescriptors;
    
    @Name("mlockall")
    @Optional
    bool mlockall;
}

struct NodeInfoJVMMemory {
    @Name("heap_init_in_bytes")
    long heapInitInBytes;

    @Name("heap_max_in_bytes")
    long heapMaxInBytes;

    @Name("non_heap_init_in_bytes")
    long nonHeapInitInBytes;

    @Name("non_heap_max_in_bytes")
    long nonHeapMaxInBytes;

    @Name("direct_max_in_bytes")
    long directMaxInBytes;    
}

struct NodeInfoJVM {
    @Name("pid")
    int pid;

    @Name("version")
    string version_;

    @Name("vm_name")
    string vmName;

    @Name("vm_version")
    string vmVersion;

    @Name("vm_vendor")
    string vmVendor;

    @Name("start_time")
    long startTime;

    @Name("mem")
    NodeInfoJVMMemory memory;

    @Name("gc_collectors")
    string[] gcCollectors;

    @Name("memory_pools")
    string[] memoryPools;
}

struct NodeInfoThreadInfo {
    @Name("type")
    string type;

    @Name("min")
    @Optional
    int min;

    @Name("max")
    @Optional
    int max;

    @Name("queue_size")
    @Optional
    string queueSize;

    @Name("keep_alive")
    @Optional
    string keepAlive;
}

struct NodeInfoNetworkInterface {
    @Name("address")
    string address;

    @Name("name")
    string name;

    @Name("mac_address")
    string macAddress;
}

struct NodeInfoNetwork {
    @Name("refresh_interval")
    int refreshInterval;

    @Name("primary_interface")
    NodeInfoNetworkInterface primaryInterface;
}

struct NodeInfoHTTP {
    @Name("bound_address")
    string boundAddress;

    @Name("publish_address")
    string publishAddress;

    @Name("max_content_length_in_bytes")
    long maxContentLengthInBytes;
}

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

    @Name("settings")
    @Optional
    Json settings;

    @Name("os")
    @Optional
    NodeInfoOS os;

    @Name("process")
    @Optional
    NodeInfoProcess process;

    @Name("jvm")
    @Optional
    NodeInfoJVM jvm; 

    @Name("thread_pool")
    @Optional
    NodeInfoThreadInfo[string] threadPool;

    @Name("network")
    @Optional
    NodeInfoNetwork network;

    @Name("http")
    @Optional
    NodeInfoHTTP http;

    @Name("plugins")
    @Optional
    Json plugins;
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