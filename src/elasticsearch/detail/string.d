module elasticsearch.detail.string;

import std.regex;
import std.string;

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
