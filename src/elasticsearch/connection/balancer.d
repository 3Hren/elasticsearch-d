module elasticsearch.connection.balancer;

import std.range;
import std.stdio;

interface Balancer(R) if (isRandomAccessRange!R) {
	alias Client = ElementType!R;

	Client next(R range);
}

class RoundRobinBalancer(R) : Balancer!R {
	private int current;

	public override Client next(R range) {
		if (current + 1 >= range.length) {
			current = 0;
		}

		Client client = range[current++];
		debug { writeln("Balancing at ", client.getAddress()); }
		return client;
	}	
}