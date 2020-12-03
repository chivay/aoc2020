const std = @import("std");
const File = std.fs.File;
const print = std.debug.print;

const EntryType = i32;

fn readFile(allocator: *std.mem.Allocator) !std.ArrayList(EntryType) {
    var input_file = try std.fs.cwd().openFile("day1.txt", .{ .read = true });
    const reader = input_file.reader();

    var entries = std.ArrayList(EntryType).init(allocator);

    while (true) {
        var buffer: [0x20]u8 = undefined;
        const line = try reader.readUntilDelimiterOrEof(buffer[0..], '\n');
        if (line == null) break;
        const entry = try std.fmt.parseInt(EntryType, line.?, 10);
        try entries.append(entry);
    }

    return entries;
}

fn cmp(context: void, lhs: EntryType, rhs: EntryType) bool {
    return lhs < rhs;
}

fn cmp_ext(context: void, lhs: EntryType, rhs: EntryType) std.math.Order {
    return std.math.order(lhs, rhs);
}

fn findComplement(entries: []EntryType, value: EntryType) ?EntryType {
    for (entries) |entry| {
        const complement = value - entry;
        if (std.sort.binarySearch(
            EntryType,
            complement,
            entries,
            {},
            cmp_ext,
        )) |index| {
            return complement * entry;
        }
    }
    return null;
}

fn solveDay1(entries: []EntryType) ?EntryType {
    std.sort.sort(EntryType, entries, {}, cmp);
    return findComplement(entries, 2020);
}

fn solveDay1Extra(entries: []EntryType) ?EntryType {
    std.sort.sort(EntryType, entries, {}, cmp);
    for (entries) |fst, i| {
        const subslice = entries[i + 1 ..];
        // Assume we've chosen fst
        if (findComplement(subslice, 2020 - fst)) |solution| {
            return solution * fst;
        }
    }
    return null;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const entries = readFile(&gpa.allocator) catch {
        print("Failed to read file", .{});
        return;
    };
    defer entries.deinit();

    if (solveDay1(entries.items)) |solution| {
        print("Solution: {}\n", .{solution});
    } else {
        print("Failed to find a solution!", .{});
    }

    if (solveDay1Extra(entries.items)) |solution| {
        print("Extra solution: {}\n", .{solution});
    } else {
        print("Failed to find an extra solution!", .{});
    }
}
