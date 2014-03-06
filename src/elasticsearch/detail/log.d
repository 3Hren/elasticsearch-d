module elasticsearch.detail.log;

import std.array;
import std.datetime;
import std.c.stdio;
import std.format;
import std.stdio;

enum Level {
	trace,
	info,
	warning,
	error
}

void log(Level level, Args...)(string message, Args args) {
	static if (level == Level.trace) {
		auto messageWriter = appender!string();		
		formattedWrite(messageWriter, message, args);

		auto writer = appender!string();
		formattedWrite(writer, "[%s] [%s]: ", Clock.currTime(), level);
		debug writeln(writer.data ~ messageWriter.data);
	} else {		
	}
}