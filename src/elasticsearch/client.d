module elasticsearch.client;

import std.string;

import vibe.data.serialization;
import vibe.data.json;

import elasticsearch.detail.log;
import elasticsearch.domain.response.base;
import elasticsearch.domain.response.cluster.node.info;
import elasticsearch.domain.response.document.index;
import elasticsearch.domain.request.base;
import elasticsearch.domain.request.method;
import elasticsearch.domain.request.cluster.node.info;
import elasticsearch.domain.request.document.index;
import elasticsearch.domain.transport;

struct ClientSettings {
    string index;
}

struct ReplacementRule {
    std.regex.Regex!char rx;
    string replacement;

    public string apply(in string word) @safe nothrow {
        try {
            return std.regex.replaceAll(word, rx, replacement);
        } catch (Exception) {
            return word;
        }
    }
}

struct Pluralizer {
    private static string[string] cache; 
    private static ReplacementRule[] rules;

    static this() {
        rules = [
            ReplacementRule(std.regex.regex(`$`), `s`)
        ];
    }

    public static string makePlural(in string word) {
        if (word !in cache) {
            cache[word] = apply(word);
        }
        return cache[word];
    }

    private static string apply(in string word) {
        string result = word;

        foreach (rule; rules.reverse) {   
            result = rule.apply(word);         
            if (result != word) {
                return result;
            }
        }

        return result;
    }
}

unittest {
    assert("types", Pluralizer.makePlural("type"));
    assert("types", Pluralizer.makePlural("type"));
}

class Client {
    private ClientSettings clientSettings = ClientSettings("default");
    private Transport transport;

    public this() {
        transport = new Transport();
    }

    // Index will be default from settings. Type will be T type name with 's' suffix. Id will be generated automatically.
    //public IndexResponse index(T)(T post) {}  

    public IndexResponse!ManualIndexRequest index(T)(string index, string type, string id, T post) {
        return this.index(ManualIndexRequest(index, type, id), post);
    }

    public IndexResponse!AutomaticIndexRequest index(T)(string index, string type, T post) {
        return this.index(AutomaticIndexRequest(index, type), post);        
    }

    public IndexResponse!AutomaticIndexRequest index(T)(string index, T post) {
        immutable string typename = T.stringof.toLower;
        immutable string type = Pluralizer.makePlural(typename);
        return this.index(AutomaticIndexRequest(index, type), post);
    }

    public IndexResponse!Request index(Request, T)(in Request action, T post) {
        alias Method = Request.Method;        

        immutable string uri = action.uri();          
        immutable string data = serializeToJson(post).toString();       
        ElasticsearchRequest!Method request = ElasticsearchRequest!Method(uri, data);
        ElasticsearchResponse!Method response = transport.perform(request);
        IndexResponse!Request.Result result = deserializeJson!(IndexResponse!Request.Result)(response.data);
        return IndexResponse!Request(response, result);
    }

    public NodesInfoResponse.Result nodesInfo(NodesInfoRequest action) {
        alias Method = NodesInfoRequest.Method;

        immutable string uri = action.uri();
        ElasticsearchRequest!Method request = ElasticsearchRequest!Method(uri);
        ElasticsearchResponse!Method response = transport.perform(request);
        NodesInfoResponse.Result result = deserializeJson!(NodesInfoResponse.Result)(response.data);
        return result;
    }
}