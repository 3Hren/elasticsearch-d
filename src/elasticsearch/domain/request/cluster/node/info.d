module elasticsearch.domain.request.cluster.node.info;

import std.array;
import std.conv;
import std.regex;
import std.stdio;
import std.string;
import std.traits;
import std.uni;

import elasticsearch.domain.request.method;

string underscored(in string s) nothrow {
    enum PrepareRE = ctRegex!(`::`);
    enum FirstCapRX = ctRegex!(`([A-Z]+)([A-Z][a-z])`);
    enum AllCapRX = ctRegex!(`([a-z\d])([A-Z])`);

    try {
        return replaceAll(replaceAll(replaceAll(s, PrepareRE, "/"), FirstCapRX, "$1_$2"), AllCapRX, "$1_$2").tr("-", "_").toLower();    
    } catch (Exception) {
        return s;
    }
}

unittest {
    assert("" == "".underscored);
    assert("camel" == "camel".underscored);
    assert("camel" == "Camel".underscored);
    assert("camel_case" == "camelCase".underscored);
    assert("camel_case" == "CamelCase".underscored);

    assert("camel42" == "camel42".underscored);
    assert("camel42" == "Camel42".underscored);
    assert("camel42_case" == "camel42Case".underscored);
    assert("camel42_case" == "Camel42Case".underscored);

    assert("html" == "HTML".underscored);
    assert("html5" == "HTML5".underscored);
    assert("html_editor" == "HTMLEditor".underscored);
    assert("html5_editor" == "HTML5Editor".underscored);
    assert("editor_toc" == "editorTOC".underscored);
    assert("editor_toc" == "EditorTOC".underscored);
    assert("editor42_toc" == "Editor42TOC".underscored);    
}

struct NodesInfoRequest {
    enum Method = ElasticsearchMethod.get;

    enum Type {
        none        = 1 << 0,
        settings    = 1 << 1,
        os          = 1 << 2,
        process     = 1 << 3,
        jvm         = 1 << 4,
        threadPool  = 1 << 5,
        network     = 1 << 6,
        transport   = 1 << 7,
        http        = 1 << 8,
        plugins     = 1 << 9,
        all = settings | os | process | jvm | threadPool | network | transport | http | plugins
    }

    Type type;

    public string path() {              
        return "/_nodes/_all/" ~ mapType(type);
    }

    private pure bool hasFlag(in Type type) {        
        return (this.type & type) == type;
    }

    private string mapType(in Type type) {
        if (type == Type.none || type == Type.all) {
            return to!string(type);
        }

        auto writer = appender!string;
        foreach (immutable flag; EnumMembers!Type) {
            if (hasFlag(flag)) {
                if (!writer.data.empty()) {
                    writer.put(",");
                }
                writer.put(to!string(flag).underscored);
            }
        }     
        
        return writer.data;
    }
}

unittest {
    assert("/_nodes/_all/none" == NodesInfoRequest(NodesInfoRequest.Type.none).path);
    assert("/_nodes/_all/all" == NodesInfoRequest(NodesInfoRequest.Type.all).path);
    assert("/_nodes/_all/settings,os" == NodesInfoRequest(NodesInfoRequest.Type.settings | NodesInfoRequest.Type.os).path);
}