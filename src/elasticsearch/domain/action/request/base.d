module elasticsearch.domain.action.request.base;

import std.algorithm;
import std.conv;
import std.typecons;

import vibe.inet.path;

import elasticsearch.domain.action.request.method;

struct ElasticsearchRequest(ElasticsearchMethod Method) {
    string uri;

    static if (Method == ElasticsearchMethod.put || Method == ElasticsearchMethod.post) {
        string data;
    }
}

class UriBuilder {
    private string path;
    private string[string] parameters;

    public void setPath(string path) {
        this.path = path;
    }

    public void setPath(Path path) {
        setPath(path.toString);
    }

    public void setPath(immutable(PathEntry)[] entries) {
        setPath(Path(entries, true));
    }

    public void setPath(string[] entries...) {
        immutable(PathEntry)[] e;
        foreach (entry; entries) {
            e ~= PathEntry(entry);
        }
        setPath(e);
    }

    public void addParameter(string name, string value) {
        if (value.length == 0) {
            return;
        }

        parameters[name] = std.uri.encodeComponent(value);
    }

    public void addParameter(string name, Nullable!ulong value) {
        if (value.isNull) {
            return;
        }

        addParameter(name, to!string(value.get));
    }

    public string uri() @property const {
        if (parameters.length == 0) {
            return path;
        }

        string[] queries;
        foreach (name, value; parameters) {
            queries ~= name ~ "=" ~ value;
        }

        return path ~ "?" ~ to!string(joiner(queries, "&"));
    }
}

mixin template UriBasedRequest(T) {
    public string uri() @property const {
        UriBuilder builder = new UriBuilder();
        (cast(const T)(this)).buildUri(builder);
        return builder.uri;
    }
}
