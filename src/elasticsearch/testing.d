module elasticsearch.testing;

import core.runtime;
import std.conv;
import std.datetime;
import std.stdio;
import std.typetuple;

struct Formatting {
    enum Color {
        RED,
        GREEN
    }
}

string colored(string text, Formatting.Color color) pure @safe {
    return "\033[1;" ~ to!string(31 + to!int(color)) ~ "m" ~ text ~ "\033[0m";
}

class AssertError : Exception {
    this(string reason) {
        super(reason);
    }
}

struct Assert {
    static void equals(T)(T expected, T actual) {
        if (expected != actual) {
            throw new AssertError(`assertion failed - expected: "` ~ to!string(expected) ~ `", actual: "` ~ to!string(actual) ~ `"`);
        }
    }
}

template Tuple(T...) {
    alias Tuple = T;
}

struct Test {
    string name;
}

struct TestFactory {
    static TestCase[] testCases;
}

interface TestCase {
    uint count() const;
    uint run() const;
}

class BaseTestCase(T) : TestCase {
    static this() {
        TestFactory.testCases ~= new T;
    }

    public override uint count() const {
        alias tests = Tuple!(__traits(getUnitTests, T));
        return tests.length;
    }

    public override uint run() const {
        enum RUN    = "[ RUN      ]";
        enum OK     = "[       OK ]";
        enum FAIL   = "[     FAIL ]";
        enum TC_SEP = "[----------]";
        enum TestCaseStart = "%s %d tests from '%s'";
        enum TestStart = "%s %s '%s' ...";
        enum TestPassed = "%s %s '%s' (%d us)";
        enum TestFailed = "%s %s '%s' - %s";
        enum TestCaseFinished = "%s %d tests from '%s' (%d us total)\n";

        alias tests = Tuple!(__traits(getUnitTests, T));

        writefln(TestCaseStart, colored(TC_SEP, Formatting.Color.GREEN), tests.length, T.stringof);

        uint failed;
        StopWatch caseWatch;
        caseWatch.start();
        foreach (test; tests) {
            alias attributes = Tuple!(__traits(getAttributes, test));
            static assert(attributes.length > 0 && staticIndexOf!(Test, typeof(attributes)) != -1,
                          "your tests must be marked with '@Test' attribute for readability");

            string name = attributes[0].name;
            try {
                StopWatch watch;
                writefln(TestStart, colored(RUN, Formatting.Color.GREEN), T.stringof, name);
                watch.start();
                test();
                watch.stop();
                writefln(TestPassed, colored(OK, Formatting.Color.GREEN), T.stringof, name, watch.peek.usecs);
            } catch (Exception err) {
                failed++;
                writefln(TestFailed, colored(FAIL, Formatting.Color.RED), T.stringof, name, err.msg);
            }
        }

        caseWatch.stop();
        writefln(TestCaseFinished, colored(TC_SEP, Formatting.Color.GREEN), tests.length,
                 T.stringof,
                 caseWatch.peek.usecs);
        return failed;
    }
}

struct TestRunner {
    static bool run() {
        TestCase[] testCases = TestFactory.testCases;
        StopWatch watch;
        uint total = 0;
        foreach (testCase; testCases) {
            total += testCase.count();
        }

        writefln("%s Running %d tests from %d test cases.",
                 colored("[==========]", Formatting.Color.GREEN),
                 total,
                 testCases.length);

        writefln("%s Global test environment set-up.\n",
                 colored("[----------]", Formatting.Color.GREEN));

        watch.start();
        uint failed = 0;
        foreach (testCase; testCases) {
            failed += testCase.run();
        }
        watch.stop();

        writefln("%s Global test environment tear-down.",
                 colored("[----------]", Formatting.Color.GREEN));

        writefln("%s %d tests from %d test cases ran. (%d us total)",
                 colored("[==========]", Formatting.Color.GREEN),
                 total,
                 testCases.length,
                 watch.peek.usecs);

        writefln("%s %d tests.",
                 colored("[  PASSED  ]", Formatting.Color.GREEN), total - failed);
        if (failed != 0) {
            writefln("%s %d tests.",
                     colored("[  FAILED  ]", Formatting.Color.RED), failed);
        }

        return failed == 0;
    }
}

shared static this() {
    Runtime.moduleUnitTester = {
        return TestRunner.run();
    };
}
