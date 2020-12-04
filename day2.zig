const std = @import("std");
const File = std.fs.File;
const print = std.debug.print;

const Entry = struct {
    from: usize,
    to: usize,
    letter: u8,
    password: []const u8,
};

fn parseEntry(line: []u8) !Entry {
    var iter = std.mem.split(line, ": ");
    const prefix = iter.next().?;
    const password = iter.next().?;

    var prefix_iter = std.mem.split(prefix, " ");
    const range = prefix_iter.next().?;
    const letter = prefix_iter.next().?;

    var range_iter = std.mem.split(range, "-");
    const from_str = range_iter.next().?;
    const to_str = range_iter.next().?;

    const from = try std.fmt.parseInt(u32, from_str, 10);
    const to = try std.fmt.parseInt(u32, to_str, 10);

    const char = letter[0];
    return Entry{ .from = from, .to = to, .letter = letter[0], .password = password };
}

fn solveDay2(allocator: *std.mem.Allocator) !usize {
    var input_file = try std.fs.cwd().openFile("day2.txt", .{ .read = true });
    const reader = input_file.reader();

    var counter: usize = 0;
    while (true) {
        const line = reader.readUntilDelimiterAlloc(allocator, '\n', 128) catch break;
        defer allocator.destroy(line.ptr);
        const entry: Entry = try parseEntry(line);
        var letter_cnt: usize = 0;
        for (entry.password) |c| {
            if (entry.letter == c) {
                letter_cnt += 1;
            }
        }
        if (letter_cnt >= entry.from and letter_cnt <= entry.to) {
            counter += 1;
        }
    }
    return counter;
}

fn solveDay2Extra(allocator: *std.mem.Allocator) !usize {
    var input_file = try std.fs.cwd().openFile("day2.txt", .{ .read = true });
    const reader = input_file.reader();

    var counter: usize = 0;
    while (true) {
        const line = reader.readUntilDelimiterAlloc(allocator, '\n', 128) catch break;
        defer allocator.destroy(line.ptr);
        const entry: Entry = try parseEntry(line);
        const first_match = entry.password[entry.from - 1] == entry.letter;
        const second_match = entry.password[entry.to - 1] == entry.letter;
        if (first_match != second_match) {
            counter += 1;
        }
    }
    return counter;
}
pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const solution = solveDay2(&gpa.allocator) catch |err| {
        print("Error: {}", .{err});
        return;
    };
    print("{}\n", .{solution});

    const solution_extra = solveDay2Extra(&gpa.allocator) catch |err| {
        print("Error: {}", .{err});
        return;
    };
    print("{}\n", .{solution_extra});
}
