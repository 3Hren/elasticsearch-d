module elasticsearch.domain.action.request.base;

import elasticsearch.domain.action.request.method;

struct ElasticsearchRequest(ElasticsearchMethod Method) {
    string uri;

    static if (Method == ElasticsearchMethod.put || Method == ElasticsearchMethod.post) {
        string data;
    }
}

mixin template UriBasedRequest() {
    private string path;
    private string[string] parameters;

    public this() @disable;

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

    private void setPath(string path) {
        this.path = path;
    }

    private void setPath(Path path) {
        setPath(path.toString);
    }

    private void setPath(immutable(PathEntry)[] entries) {
        setPath(Path(entries, true));
    }

    private void setPath(string[] entries...) {
        immutable(PathEntry)[] e;
        foreach (entry; entries) {
            e ~= PathEntry(entry);
        }
        setPath(e);
    }

    private void addParameter(string name, string value) {
        parameters[name] = std.uri.encodeComponent(value);
    }
}