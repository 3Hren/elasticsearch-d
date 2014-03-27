module elasticsearch.domain.action.request.base;

import std.algorithm;
import std.array;
import std.conv;
import std.string;
import std.traits;
import std.typecons;
import std.typetuple;

import vibe.http.common;
import vibe.inet.path;
import vibe.internal.meta.uda;

import elasticsearch.detail.string;
import elasticsearch.testing;

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

    public void addParameter(bool encode = true)(string name, string value) {
        if (value.length == 0) {
            return;
        }

        static if (encode) {
            parameters[name] = std.uri.encodeComponent(value);
        } else {
            parameters[name] = value;
        }
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

/**
    [Member fields]:
    version_ -> version
    blahBlah -> blah_blah
    @Required -> if null - throw
    @Default -> if default - do not substitute
    arrays -> join(array, ",");
    @NotEncoded -> do not encode uri

    @Path ... -> /blah/blah/blah
    @Query -> name=value

    enums:
    VERSION  -> version
    OMG_TYPE -> omg_type
*/

struct PathAttribute {}

PathAttribute Path() @property {
    return PathAttribute();
}

struct DefaultAttribute(T, U) {
    T value;
    U condition;
}

DefaultAttribute!(T, T) IfDefault(T)(T value) @property {
    return DefaultAttribute!(T, T)(value, T.init);
}

DefaultAttribute!(T, U) IfDefault(T, U)(T value, U condition) @property {
    return DefaultAttribute!(T, U)(value, condition);
}

struct BitmaskAttribute {}

BitmaskAttribute Bitmask() @property {
    return BitmaskAttribute();
}

mixin template UriBasedRequest(T) {
    public string uri() @property const {
        UriBuilder builder = new UriBuilder();
        (cast(const T)(this)).buildUri(builder);
        return builder.uri;
    }
}

template hasAttribute(alias symbol, T) {
    enum hasAttribute = findFirstUDA!(T, symbol).found;
}

template getAttribute(alias symbol, T) {
    enum getAttribute = findFirstUDA!(T, symbol).value;
}

string bitmaskEnumToString(T)(T type) {
    auto stream = appender!string;
    foreach (immutable flag; EnumMembers!T) {
        if ((type & flag) == flag) {
            if (!stream.data.empty()) {
                stream.put(",");
            }
            stream.put(to!string(flag).underscored);
        }
    }

    return stream.data;
}

template ArrayElementType(T : T[]) {
    alias T ArrayElementType;
}

mixin template UriBasedRequestV2(U) {
    final public string uri() @property const {
        UriBuilder builder = new UriBuilder();

        alias Unqual!U T;

        foreach (memberName; __traits(allMembers, T)) {
        }

        import std.stdio;
        import std.typetuple : TypeTuple, staticIndexOf;

        string[] paths;
        foreach (i, FieldType; FieldTypeTuple!T) {
            pragma(msg, "I: " ~ to!string(i) ~ "\n");
            enum fieldName = T.tupleof[i].stringof;
            alias Field = TypeTuple!(__traits(getMember, T, fieldName))[0];
            alias Attributes = TypeTuple!(__traits(getAttributes, Field));
            pragma(msg, "[" ~ FieldType.stringof ~ "] " ~ fieldName);
            pragma(msg, "@Attributes: " ~ Attributes.stringof);
            static if (hasAttribute!(Field, PathAttribute)) {
                pragma(msg, "We have path attribute for: " ~ fieldName);
                writeln(Field);
                static if (isArray!(FieldType) && !is(FieldType : string)) {
                    pragma(msg, "AT " ~ (ArrayElementType!FieldType).stringof);
                    enum idx = staticIndexOf!(DefaultAttribute!(string, ArrayElementType!FieldType), typeof(Attributes));
                    pragma(msg, "Attribute: " ~ typeof(Attributes).stringof);
                    pragma(msg, "Index: " ~ to!string(idx));
                    static if (idx != -1) {
                        enum attribute = Attributes[idx];
                        if (Field.empty) {
                            paths ~= attribute.value;
                        } else {
                            paths ~= Strings.join(Field);
                        }
                    } else {
                        paths ~= Strings.join(Field);
                    }
                } else {
                    enum idx = staticIndexOf!(DefaultAttribute!(string, FieldType), typeof(Attributes));
                    pragma(msg, "Attribute: " ~ typeof(Attributes).stringof);
                    pragma(msg, "Index: " ~ to!string(idx));
                    static if (idx != -1) {
                        enum attribute = Attributes[idx];
                        if (Field == attribute.condition) {
                            paths ~= attribute.value;
                        } else {
                            static if (hasAttribute!(Field, BitmaskAttribute)) {
                                paths ~= bitmaskEnumToString(Field);
                            }
                        }
                    } else static if (hasAttribute!(Field, BitmaskAttribute)) {
                        paths ~= bitmaskEnumToString(Field);
                    } else {
                        import std.string;
                        paths ~= to!string(Field).toLower;
                    }
                }
            }
        }

        builder.setPath(paths);

        return builder.uri;
    }
}

bool check(const string[] n) pure {
    return n.empty;
}

class ReflectionTestCase : BaseTestCase!ReflectionTestCase {
    @Test("Path with single item")
    unittest {
        struct Omg {
            mixin UriBasedRequestV2!(Omg);

            @Path
            string index = "twitter";
        }

        Assert.equals("/twitter", Omg().uri);
    }

    @Test("Path with multiple items")
    unittest {
        struct Omg {
            mixin UriBasedRequestV2!(Omg);

            @Path
            private string index = "twitter";

            @Path
            private string type = "tweet";

            @Path
            private string id = "1";
        }

        Assert.equals("/twitter/tweet/1", Omg().uri);
    }

    @Test("Path with multiple items united")
    unittest {
        struct Omg {
            mixin UriBasedRequestV2!(Omg);

            @Path {
                private string index = "twitter";
                private string type = "tweet";
                private string id = "1";
            }
        }

        Assert.equals("/twitter/tweet/1", Omg().uri);
    }

    @Test("Path with array field")
    unittest {
        struct Omg {
            mixin UriBasedRequestV2!(Omg);

            @Path
            private string[] nodes = ["node1", "node2", "node3"];
        }

        Assert.equals("/node1,node2,node3", Omg().uri);
    }

    @Test("Path with array field with default value")
    unittest {
        final struct Omg {
            mixin UriBasedRequestV2!(Omg);

            @Path
            @IfDefault("_all")
            private string[] nodes = [];
        }

        Assert.equals("/_all", Omg().uri);
    }

    @Test("Path with enum field")
    unittest {
        final struct Omg {
            mixin UriBasedRequestV2!(Omg);

            enum Type {
                ONE
            }

            @Path
            private Type type = Type.ONE;
        }

        Assert.equals("/one", Omg().uri);
    }

    @Test("Path with enum field with bitmask")
    unittest {
        final struct Omg {
            mixin UriBasedRequestV2!(Omg);

            enum Type {
                NONE        = 1 << 0,
                SETTINGS    = 1 << 1,
                JVM         = 1 << 2
            }

            @Path
            @Bitmask
            Type type = Type.NONE;
        }

        Omg omg = Omg();
        Assert.equals("/none", omg.uri);

        omg.type = Omg.Type.SETTINGS;
        Assert.equals("/settings", omg.uri);

        omg.type = Omg.Type.NONE | Omg.Type.JVM;
        Assert.equals("/none,jvm", omg.uri);
    }
}
