module elasticsearch.domain.action.request.base;

import std.algorithm;
import std.conv;
import std.typecons;

import vibe.http.common;
import vibe.inet.path;

import elasticsearch.detail.string;

struct ElasticsearchRequest {
    string uri;
    HTTPMethod method;
    string data;
}

class UriBuilder {
    private string path;
    private string[string] parameters;

    public void setPath(string path) {
        this.path = "/" ~ path;
    }

    public void setPath(string[] entries...) {
        setPath(Strings.join(entries, "/"));
    }

    public void addParameter(string name, string value) {
        if (value.length == 0) {
            return;
        }

        parameters[name] = std.uri.encodeComponent(value);
    }

    public void addParameter(T)(string name, Nullable!T value) {
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

        return path ~ "?" ~ Strings.join(queries, "&");
    }
}

mixin template UriBasedRequest(T) {
    public string uri() @property const {
        UriBuilder builder = new UriBuilder();
        (cast(const T)(this)).buildUri(builder);
        return builder.uri;
    }
}
