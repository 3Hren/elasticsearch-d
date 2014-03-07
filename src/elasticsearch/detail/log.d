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

void log(Level level, Args...)(string message, Args args) {
    auto messageWriter = appender!string();
    formattedWrite(messageWriter, message, args);

    auto writer = appender!string();
    formattedWrite(writer, "[%s] [%s]: ", Clock.currTime(), level);
    writeln(writer.data ~ messageWriter.data);  
}

void log(Level level, T)(T value) if (!is(typeof(value) == string)) {
    auto writer = appender!string();
    formattedWrite(writer, "[%s] [%s]: ", Clock.currTime(), level);
    writeln(writer.data ~ to!string(value));
}