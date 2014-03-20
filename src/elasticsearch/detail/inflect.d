module elasticsearch.detail.inflect;

import std.string;

import elasticsearch.testing;

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

    public static string make(in string word) {
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

class PluralizerTestCase : BaseTestCase!PluralizerTestCase {
    @Test("Base suffix")
    unittest {
        assert("types", Pluralizer.make("type"));
    }
}
