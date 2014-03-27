module elasticsearch.detail.string;

import std.regex;
import std.string;

import elasticsearch.testing;

string underscored(in string s) nothrow {
    enum PrepareRX = ctRegex!(`::`);
    enum FirstCapRX = ctRegex!(`([A-Z]+)([A-Z][a-z])`);
    enum AllCapRX = ctRegex!(`([a-z\d])([A-Z])`);

    try {
        return replaceAll(replaceAll(replaceAll(s, PrepareRX, "/"), FirstCapRX, "$1_$2"), AllCapRX, "$1_$2").tr("-", "_").toLower();
    } catch (Exception) {
        return s;
    }
}

struct Strings {
    static string join(const string[] array, string separator = ",") {
        if (array.length == 0) {
            return "";
        }

        string result;
        for (ulong i = 0; i < array.length - 1; i++) {
            if (array[i].length != 0) {
                result ~= array[i] ~ separator;
            }
        }

        result ~= array[$ - 1];
        if (result.endsWith(separator)) {
            return result[0 .. $ - separator.length];
        }
        return result;
    }
}

class StringsTestCase : BaseTestCase!StringsTestCase {
    @Test("Underscored")
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
}
