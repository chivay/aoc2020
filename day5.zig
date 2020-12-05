const std = @import("std");
const File = std.fs.File;
const print = std.debug.print;

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

fn solveDay5(allocator: *std.mem.Allocator) !usize {
    var input_file = try std.fs.cwd().openFile("day5.txt", .{ .read = true });
    const reader = input_file.reader();

    var max_id: u32 = 0;

    var id_map: [1024]bool = [_]bool{false} ** 1024;
    while (true) {
        const line = reader.readUntilDelimiterAlloc(allocator, '\n', 128) catch break;
        defer allocator.destroy(line.ptr);

        const row = line[0..7];
        _ = std.mem.replace(u8, row, "F", "0", row);
        _ = std.mem.replace(u8, row, "B", "1", row);

        const seat = line[7..];
        _ = std.mem.replace(u8, seat, "L", "0", seat);
        _ = std.mem.replace(u8, seat, "R", "1", seat);

        const seat_id = try std.fmt.parseInt(u32, line, 2);
        id_map[seat_id] = true;
        max_id = std.math.max(max_id, seat_id);
    }
    print("{}\n", .{max_id});
    for (id_map) |slot, i| {
        if (i == 0 or i == id_map.len - 1) continue;
        if (slot) continue;

        if (id_map[i - 1] and id_map[i + 1]) {
            print("Seat: {}\n", .{i});
        }
    }
    return max_id;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const solution = solveDay5(&gpa.allocator) catch |err| {
        print("Error: {}", .{err});
        return;
    };
}
