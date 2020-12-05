const std = @import("std");
const File = std.fs.File;
const print = std.debug.print;

const Movement = struct { x: u32, y: u32 };

fn solveDay3(allocator: *std.mem.Allocator, movement: Movement) !usize {
    var input_file = try std.fs.cwd().openFile("day3.txt", .{ .read = true });
    defer input_file.close();
    const reader = input_file.reader();

    var counter: usize = 0;
    var x: u32 = 0;

    var line_no: u32 = 0;
    while (true) : ({
        if (line_no % movement.y == 0) {
            x += movement.x;
        }
        line_no += 1;
    }) {
        const line = reader.readUntilDelimiterAlloc(allocator, '\n', 1024) catch break;
        defer allocator.destroy(line.ptr);

        if ((line_no % movement.y) == 0) {
            x %= @intCast(u32, line.len);
            if (line[x] == '#') {
                counter += 1;
            }
        }
    }
    return counter;
}

fn solveDay3Extra(allocator: *std.mem.Allocator) !usize {
    const movements = [_]Movement{
        Movement{ .x = 1, .y = 1 },
        Movement{ .x = 3, .y = 1 },
        Movement{ .x = 5, .y = 1 },
        Movement{ .x = 7, .y = 1 },
        Movement{ .x = 1, .y = 2 },
    };

    var solution: usize = 1;
    for (movements) |movement| {
        print("{}\n", .{movement});
        const res = try solveDay3(allocator, movement);
        print("Result: {}\n", .{res});
        solution *= res;
    }
    return solution;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const solution = solveDay3(&gpa.allocator, Movement{ .x = 3, .y = 1 }) catch |err| {
        print("Error: {}", .{err});
        return;
    };
    print("{}\n", .{solution});

    const solution_extra = solveDay3Extra(&gpa.allocator) catch |err| {
        print("Error: {}", .{err});
        return;
    };
    print("{}\n", .{solution_extra});
}
