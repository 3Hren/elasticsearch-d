import core.runtime;

import elasticsearch.detail.log;
import elasticsearch.testing;

shared static this() {
    Runtime.moduleUnitTester = {
        Logger.level = Level.trace;
        return TestRunner.run();
    };
}

void main() {}
