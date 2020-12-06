const std = @import("std");
const File = std.fs.File;
const print = std.debug.print;

fn solveDay6(allocator: *std.mem.Allocator) !usize {
    var input_file = try std.fs.cwd().openFile("day6.txt", .{ .read = true });
    const reader = input_file.reader();

    var answers: ['z' - 'a' + 1]bool = undefined;
    answers = [_]bool{false} ** answers.len;
    var total: u32 = 0;
    while (true) {
        const line = reader.readUntilDelimiterAlloc(allocator, '\n', 128) catch break;
        if (line.len == 0) {
            // empty line
            var count: u32 = 0;
            for (answers) |v| {
                if (v) count += 1;
            }
            total += count;
            answers = [_]bool{false} ** answers.len;
            continue;
        }

        for (line) |v| {
            answers[v - 'a'] = true;
        }
        defer allocator.destroy(line.ptr);
    }

    var count: u32 = 0;
    for (answers) |v| {
        if (v) count += 1;
    }
    total += count;

    return total;
}

fn solveDay6Extra(allocator: *std.mem.Allocator) !usize {
    var input_file = try std.fs.cwd().openFile("day6.txt", .{ .read = true });
    const reader = input_file.reader();

    var total: u32 = 0;

    var current: u26 = std.math.maxInt(u26);
    while (true) {
        const line = reader.readUntilDelimiterAlloc(allocator, '\n', 128) catch break;
        if (line.len == 0) {
            // empty line
            total += @popCount(u26, current);
            current = std.math.maxInt(u26);
            continue;
        }

        var entry: u26 = 0;
        for (line) |c| {
            const one: u26 = 1;
            const bit = one << @intCast(u5, (c - 'a'));
            entry |= bit;
        }
        current &= entry;

        defer allocator.destroy(line.ptr);
    }

    total += @popCount(u26, current);

    return total;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const solution = solveDay6(&gpa.allocator) catch |err| {
        print("Error: {}", .{err});
        return;
    };
    print("{}\n", .{solution});

    const solution_extra = solveDay6Extra(&gpa.allocator) catch |err| {
        print("Error: {}", .{err});
        return;
    };
    print("{}\n", .{solution_extra});
}
