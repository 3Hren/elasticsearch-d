module elasticsearch.connection.pool;

import std.container;
import std.stdio;

import elasticsearch.detail.log;
import elasticsearch.connection.balancer;

struct ClientPool(Client) {
	private alias Pool = Array!Client;
	private alias PoolRange = Pool.Range;

	private Pool pool;
	private Balancer!PoolRange balancer = new RoundRobinBalancer!PoolRange();

	public bool empty() {
		return pool.empty();
	}

	public bool contains(Client client) {
		foreach (Client c; pool) {
			if (c.getAddress() == client.getAddress()) {
				return true;
			}
		}

		return false;
	}

	public void add(Client client) {
		if (contains(client)) {
			log!(Level.trace)("client %s already exists in pool", client);
			return;
		}

		pool.insert(client);
	}

	// TODO: void remove(Address address);
	
	void remove(Client client) {
		bool found = false;
		ulong pos = 0;
		for (ulong i = 0; i < pool.length; i++) {
			Client c = pool[i];
			if (c.getAddress() == client.getAddress()) {
				found = true;
				pos = i;
				break;
			}
		}
		if (!found) {
			log!(Level.trace)("can not remove client %s: not found", client);
		} else {
			pool.linearRemove(pool[pos .. pos + 1]);
		}
	}

	public Client next() {
		return balancer.next(pool[]);
	}	
}