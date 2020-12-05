const std = @import("std");
const File = std.fs.File;
const print = std.debug.print;

const DocFlags = struct {
    byr: bool = false,
    iyr: bool = false,
    eyr: bool = false,
    hgt: bool = false,
    hcl: bool = false,
    ecl: bool = false,
    pid: bool = false,
    cid: bool = false,

    pub fn reset(self: *@This()) void {
        self.* = DocFlags{};
    }

    pub fn valid(self: *@This()) bool {
        const fields = @typeInfo(DocFlags).Struct.fields;
        const nflags = init: {
            var result: u32 = 0;
            inline for (fields) |field| {
                if (@field(self, field.name)) {
                    result += 1;
                }
            }
            break :init result;
        };
        const have_all_flags = fields.len == nflags;
        return have_all_flags or (nflags == fields.len - 1 and !self.cid);
    }
};

fn isFourDigits(value: []const u8) bool {
    if (value.len != 4) return false;
    for (value) |c| {
        if (!std.ascii.isDigit(c)) return false;
    }
    return true;
}

fn inRange(comptime T: type, low: T, high: T) type {
    std.debug.assert(low <= high);
    return struct {
        pub fn check(value: T) bool {
            return value >= low and value <= high;
        }
    };
}

fn check(comptime field: []const u8, value: []const u8) bool {
    const eql = std.mem.eql;
    if (eql(u8, field, "byr")) {
        if (!isFourDigits(value)) return false;
        const year = std.fmt.parseInt(u32, value, 10) catch return false;
        return inRange(u32, 1920, 2002).check(year);
    }
    if (eql(u8, field, "iyr")) {
        if (!isFourDigits(value)) return false;
        const year = std.fmt.parseInt(u32, value, 10) catch return false;
        return inRange(u32, 2010, 2020).check(year);
    }
    if (eql(u8, field, "eyr")) {
        if (!isFourDigits(value)) return false;
        const year = std.fmt.parseInt(u32, value, 10) catch return false;
        return inRange(u32, 2020, 2030).check(year);
    }
    if (eql(u8, field, "hgt")) {
        if (std.mem.endsWith(u8, value, "cm")) {
            const trimmed = value[0 .. value.len - "cm".len];
            const height = std.fmt.parseInt(u32, trimmed, 10) catch return false;
            return inRange(u32, 150, 193).check(height);
        } else if (std.mem.endsWith(u8, value, "in")) {
            const trimmed = value[0 .. value.len - "in".len];
            const height = std.fmt.parseInt(u32, trimmed, 10) catch return false;
            return inRange(u32, 59, 76).check(height);
        }
        return false;
    }
    if (eql(u8, field, "hcl")) {
        if (!std.mem.startsWith(u8, value, "#")) return false;
        const suffix = value[1..];
        if (suffix.len != 6) return false;
        for (suffix) |c| {
            if (!inRange(u8, '0', '9').check(c) and !inRange(u8, 'a', 'f').check(c)) return false;
        }
        return true;
    }
    if (eql(u8, field, "ecl")) {
        const colors = &[_][]const u8{
            "amb", "blu", "brn", "gry", "grn", "hzl", "oth",
        };
        for (colors) |color| {
            if (std.mem.eql(u8, color, value)) return true;
        }
        return false;
    }
    if (eql(u8, field, "pid")) {
        if (value.len != 9) return false;
        for (value) |c| {
            if (!std.ascii.isDigit(c)) return false;
        }
        return true;
    }
    if (eql(u8, field, "cid")) {
        return true;
    }
    unreachable;
}

fn parseKv(flags: *DocFlags, buffer: []const u8, validate_values: bool) void {
    var key_iterator = std.mem.split(buffer, ":");
    var key = key_iterator.next().?;
    var value = key_iterator.next().?;

    inline for (@typeInfo(DocFlags).Struct.fields) |field| {
        if (std.mem.eql(u8, field.name, key)) {
            if (validate_values) {
                @field(flags, field.name) = check(field.name, value);
            } else {
                @field(flags, field.name) = true;
            }
        }
    }
}

fn parseLine(flags: *DocFlags, buffer: []const u8, validate_values: bool) void {
    var key_iterator = std.mem.split(buffer, " ");
    var kv = key_iterator.next();
    while (kv != null) : (kv = key_iterator.next()) {
        parseKv(flags, kv.?, validate_values);
    }
}

fn solveDay4(allocator: *std.mem.Allocator, validate_values: bool) !usize {
    var input_file = try std.fs.cwd().openFile("day4.txt", .{ .read = true });
    defer input_file.close();

    const reader = input_file.reader();
    var flags = DocFlags{};
    var counter: usize = 0;
    while (true) {
        const line = reader.readUntilDelimiterAlloc(allocator, '\n', 1024) catch break;
        if (line.len == 0) {
            // End of passport
            if (flags.valid()) {
                counter += 1;
            }
            flags.reset();
            continue;
        }
        parseLine(&flags, line, validate_values);
        defer allocator.destroy(line.ptr);
    }
    if (flags.valid()) {
        counter += 1;
    }
    return counter;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const solution = solveDay4(&gpa.allocator, false) catch |err| {
        print("Error: {}", .{err});
        return;
    };
    print("{}\n", .{solution});

    const solution_extra = solveDay4(&gpa.allocator, true) catch |err| {
        print("Error: {}", .{err});
        return;
    };
    print("{}\n", .{solution_extra});
}
