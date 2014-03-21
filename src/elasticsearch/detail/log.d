module elasticsearch.detail.log;

import std.array;
import std.c.stdio;
import std.conv;
import std.datetime;
import std.format;
import std.stdio;

enum Level {
    trace,
    info,
    warning,
    error
}

class Logger {
    static Level level_ = Level.info;

    static void level(Level level) @property {
        this.level_ = level;
    }

    static void log(Level level, T, Args...)(string message, T arg, Args args) {
        if (level < level_) {
            return;
        }

        auto stream = appender!string();
        formattedWrite(stream, message, arg, args);
        log!(level)(stream.data);
    }

    static void log(Level level)(string message) {
        if (level < level_) {
            return;
        }

        auto stream = appender!string();
        formattedWrite(stream, "[%-27s] [%-7s]: ", to!string(Clock.currTime()), level);
        writeln(stream.data ~ message);
    }
}

void log(Level level, Args...)(string message, Args args) {
    Logger.log!(level)(message, args);
}
