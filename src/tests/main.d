import core.runtime;

import elasticsearch.testing;

shared static this() {
    Runtime.moduleUnitTester = {
        return TestRunner.run();
    };
}

void main() {}
