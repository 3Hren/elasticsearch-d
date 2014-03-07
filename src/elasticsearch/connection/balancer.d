module elasticsearch.connection.balancer;

import std.range;
import std.stdio;

import elasticsearch.detail.log;

interface Balancer(R) if (isRandomAccessRange!R) {
    alias Client = ElementType!R;

    Client next(R range);
}

class RoundRobinBalancer(R) : Balancer!R {
    private int current;

    public override Client next(R range) {
        if (current >= range.length) {
            current = 0;
        }

        Client client = range[current++];
        log!(Level.trace)("balancing at %s", client.getAddress());
        return client;
    }   
}