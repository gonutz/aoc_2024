const std = @import("std");

pub fn main() !void {
    try day1();
    try day2();
    day3();
    day4();
    try day5();
    day6();
    day7();
    day8();
    day9();
    day10();
}

fn day1() !void {
    var col0: [1000]i32 = undefined;
    var col1: [1000]i32 = undefined;
    var line_index: usize = 0;
    var lines = std.mem.splitSequence(u8, day1input, "\n");
    while (lines.next()) |line| : (line_index += 1) {
        col0[line_index] = try std.fmt.parseInt(i32, line[0..5], 10);
        col1[line_index] = try std.fmt.parseInt(i32, line[8..13], 10);
    }
    std.mem.sort(i32, &col0, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, &col1, {}, comptime std.sort.asc(i32));
    var sum: u32 = 0;
    for (0..1000) |i| {
        const diff = @abs(col0[i] - col1[i]);
        sum += diff;
    }
    std.debug.print("day 1, part 1) {any}, right answer: 1319616\n", .{sum});

    var counts: [1000]u32 = [_]u32{0} ** 1000;
    for (0..1000) |i| {
        for (0..1000) |j| {
            if (col0[i] == col1[j]) {
                counts[i] += 1;
            }
        }
    }
    var similarity: i64 = 0;
    for (0..1000) |i| {
        similarity += @as(i64, col0[i]) * @as(i64, counts[i]);
    }
    std.debug.print("day 1, part 2) {any}, right answer: 27267728\n", .{similarity});
}

fn day2() !void {
    var safe_count_part_1: i32 = 0;
    var safe_count_part_2: i32 = 0;
    var lines = std.mem.splitSequence(u8, day2input, "\n");
    while (lines.next()) |line| {
        var nums: [20]i32 = undefined;
        var num_count: usize = 0;
        var cols = std.mem.splitSequence(u8, line, " ");
        while (cols.next()) |col| {
            const n = try std.fmt.parseInt(i32, col, 10);
            nums[num_count] = n;
            num_count += 1;
        }

        if (is_increasing_or_decreasing(nums, num_count)) {
            safe_count_part_1 += 1;
            safe_count_part_2 += 1;
        } else {
            var any_safe = false;
            var skip: usize = 0;
            while (skip < num_count) {
                const skipped = without(nums, num_count, skip);
                any_safe = any_safe or is_increasing_or_decreasing(skipped, num_count - 1);
                skip += 1;
            }
            if (any_safe) {
                safe_count_part_2 += 1;
            }
        }
    }
    std.debug.print("day 2, part 1) {any}, right answer: 246\n", .{safe_count_part_1});
    std.debug.print("day 2, part 2) {any}, right answer: 318\n", .{safe_count_part_2});
}

fn is_increasing_or_decreasing(nums: [20]i32, n: usize) bool {
    var all_increasing = true;
    var all_decreasing = true;
    var i: usize = 1;
    while (i < n) : (i += 1) {
        const diff = nums[i] - nums[i - 1];
        all_increasing = all_increasing and 1 <= diff and diff <= 3;
        all_decreasing = all_decreasing and -3 <= diff and diff <= -1;
    }
    return all_increasing or all_decreasing;
}

fn without(nums: [20]i32, n: usize, skip: usize) [20]i32 {
    var copy: [20]i32 = undefined;
    var i: usize = 0;
    var cur: usize = 0;
    while (i < n) {
        if (i != skip) {
            copy[cur] = nums[i];
            cur += 1;
        }
        i += 1;
    }
    return copy;
}

fn day3() void {
    var all_sum: i64 = 0;
    var do_sum: i64 = 0;
    var enabled = true;
    var i: usize = 0;
    while (i < day3input.len) {
        const n = parseMul(day3input, i) catch 0;
        const is_do = parseDo(day3input, i) catch false;
        const is_dont = parseDont(day3input, i) catch false;

        all_sum += n;

        enabled = (enabled or is_do) and !is_dont;
        if (enabled) {
            do_sum += n;
        }

        i += 1;
    }
    std.debug.print("day 3, part 1) {any}, right answer: 166357705\n", .{all_sum});
    std.debug.print("day 3, part 2) {any}, right answer: 88811886\n", .{do_sum});
}

fn parseMul(s: []const u8, at: usize) !i64 {
    var p = parser{
        .s = s,
        .i = at,
    };

    try p.eat('m');
    try p.eat('u');
    try p.eat('l');
    try p.eat('(');

    if (!isDigit(p.peek())) {
        return 0;
    }
    var a: i64 = p.next() - '0';
    if (isDigit(p.peek())) {
        a = 10 * a + (p.next() - '0');
    }
    if (isDigit(p.peek())) {
        a = 10 * a + p.next() - '0';
    }

    try p.eat(',');

    if (!isDigit(p.peek())) {
        return 0;
    }
    var b: i64 = p.next() - '0';
    if (isDigit(p.peek())) {
        b = 10 * b + p.next() - '0';
    }
    if (isDigit(p.peek())) {
        b = 10 * b + p.next() - '0';
    }

    try p.eat(')');

    return a * b;
}

fn parseDo(s: []const u8, at: usize) !bool {
    var p = parser{
        .s = s,
        .i = at,
    };

    try p.eat('d');
    try p.eat('o');
    try p.eat('(');
    try p.eat(')');

    return true;
}

fn parseDont(s: []const u8, at: usize) !bool {
    var p = parser{
        .s = s,
        .i = at,
    };

    try p.eat('d');
    try p.eat('o');
    try p.eat('n');
    try p.eat('\'');
    try p.eat('t');
    try p.eat('(');
    try p.eat(')');

    return true;
}

const mulParseError = error{NotEaten};

const parser = struct {
    s: []const u8,
    i: usize,

    fn eat(self: *parser, c: u8) !void {
        if (self.next() != c) {
            return mulParseError.NotEaten;
        }
    }

    fn next(self: *parser) u8 {
        if (self.i >= self.s.len) {
            return 0;
        }
        self.i += 1;
        return self.s[self.i - 1];
    }

    fn peek(self: *parser) u8 {
        if (self.i >= self.s.len) {
            return 0;
        }
        return self.s[self.i];
    }
};

fn isDigit(c: u8) bool {
    return '0' <= c and c <= '9';
}

fn day4() void {
    var lines: [1000][]const u8 = undefined;
    var line_iter = std.mem.splitSequence(u8, day4input, "\n");
    var line_count: usize = 0;
    while (line_iter.next()) |line| {
        lines[line_count] = line;
        line_count += 1;
    }
    const f = charField{
        .lines = lines[0..line_count],
    };
    var xmas_count: i32 = 0;
    var mas_cross_count: i32 = 0;
    var y: i32 = 0;
    while (y < f.height()) {
        var x: i32 = 0;
        while (x < f.width()) {
            xmas_count += xmasCountAt(&f, x, y);
            if (crossesMasAt(&f, x, y)) {
                mas_cross_count += 1;
            }
            x += 1;
        }
        y += 1;
    }
    std.debug.print("day 4, part 1) {any}, right answer: 2599\n", .{xmas_count});
    std.debug.print("day 4, part 2) {any}, right answer: 1948\n", .{mas_cross_count});
}

const charField = struct {
    lines: [][]const u8,

    fn at(self: *const charField, x: i32, y: i32) u8 {
        if (y >= 0 and y < self.height() and x >= 0 and x < self.width()) {
            const xx: usize = @intCast(x);
            const yy: usize = @intCast(y);
            return self.lines[yy][xx];
        }
        return 0;
    }

    fn width(self: *const charField) i32 {
        return @intCast(self.lines[0].len);
    }

    fn height(self: *const charField) i32 {
        return @intCast(self.lines.len);
    }
};

fn xmasCountAt(f: *const charField, x: i32, y: i32) i32 {
    var n: i32 = 0;
    if (f.at(x, y) == 'X' and f.at(x + 1, y) == 'M' and f.at(x + 2, y) == 'A' and f.at(x + 3, y) == 'S') {
        n += 1;
    }
    if (f.at(x, y) == 'X' and f.at(x - 1, y) == 'M' and f.at(x - 2, y) == 'A' and f.at(x - 3, y) == 'S') {
        n += 1;
    }
    if (f.at(x, y) == 'X' and f.at(x, y + 1) == 'M' and f.at(x, y + 2) == 'A' and f.at(x, y + 3) == 'S') {
        n += 1;
    }
    if (f.at(x, y) == 'X' and f.at(x, y - 1) == 'M' and f.at(x, y - 2) == 'A' and f.at(x, y - 3) == 'S') {
        n += 1;
    }
    if (f.at(x, y) == 'X' and f.at(x + 1, y + 1) == 'M' and f.at(x + 2, y + 2) == 'A' and f.at(x + 3, y + 3) == 'S') {
        n += 1;
    }
    if (f.at(x, y) == 'X' and f.at(x + 1, y - 1) == 'M' and f.at(x + 2, y - 2) == 'A' and f.at(x + 3, y - 3) == 'S') {
        n += 1;
    }
    if (f.at(x, y) == 'X' and f.at(x - 1, y + 1) == 'M' and f.at(x - 2, y + 2) == 'A' and f.at(x - 3, y + 3) == 'S') {
        n += 1;
    }
    if (f.at(x, y) == 'X' and f.at(x - 1, y - 1) == 'M' and f.at(x - 2, y - 2) == 'A' and f.at(x - 3, y - 3) == 'S') {
        n += 1;
    }
    return n;
}

fn crossesMasAt(f: *const charField, x: i32, y: i32) bool {
    return f.at(x, y) == 'A' and
        (false or
        f.at(x - 1, y - 1) == 'M' and f.at(x + 1, y + 1) == 'S' and f.at(x + 1, y - 1) == 'M' and f.at(x - 1, y + 1) == 'S' or
        f.at(x - 1, y - 1) == 'S' and f.at(x + 1, y + 1) == 'M' and f.at(x + 1, y - 1) == 'M' and f.at(x - 1, y + 1) == 'S' or
        f.at(x - 1, y - 1) == 'M' and f.at(x + 1, y + 1) == 'S' and f.at(x + 1, y - 1) == 'S' and f.at(x - 1, y + 1) == 'M' or
        f.at(x - 1, y - 1) == 'S' and f.at(x + 1, y + 1) == 'M' and f.at(x + 1, y - 1) == 'S' and f.at(x - 1, y + 1) == 'M' or
        false);
}

fn day5() !void {
    var top_bottom = std.mem.splitSequence(u8, day5input, "\n\n");
    const top = top_bottom.next() orelse "";
    const bottom = top_bottom.next() orelse "";
    var rules: [2000]day5rule = undefined;
    var rule_count: usize = 0;
    var rule_iter = std.mem.splitSequence(u8, top, "\n");
    while (rule_iter.next()) |rule| {
        var numbers = std.mem.splitSequence(u8, rule, "|");
        const left = numbers.next() orelse "0";
        const right = numbers.next() orelse "0";
        rules[rule_count].left = try std.fmt.parseInt(i32, left, 10);
        rules[rule_count].right = try std.fmt.parseInt(i32, right, 10);
        rule_count += 1;
    }

    var sum_part_1: i32 = 0;
    var sum_part_2: i32 = 0;

    var list_iter = std.mem.splitSequence(u8, bottom, "\n");
    while (list_iter.next()) |list| {
        var numbers: [100]i32 = undefined;
        var num_count: usize = 0;
        var num_iter = std.mem.splitSequence(u8, list, ",");
        while (num_iter.next()) |num| {
            numbers[num_count] = try std.fmt.parseInt(i32, num, 10);
            num_count += 1;
        }

        if (inRightOrder(numbers[0..num_count], rules[0..rule_count])) {
            sum_part_1 += middleNumber(numbers[0..num_count]);
        } else {
            applyRules(numbers[0..num_count], rules[0..rule_count]);
            sum_part_2 += middleNumber(numbers[0..num_count]);
        }
    }

    std.debug.print("day 5, part 1) {any}, right answer: 4996\n", .{sum_part_1});
    std.debug.print("day 5, part 2) {any}, right answer: 6311\n", .{sum_part_2});
}

const day5rule = struct {
    left: i32,
    right: i32,
};

fn inRightOrder(nums: []i32, rules: []day5rule) bool {
    for (rules) |rule| {
        var left_index: usize = nums.len;
        var right_index: usize = nums.len;
        for (nums, 0..) |n, i| {
            if (n == rule.left) {
                left_index = i;
            }
            if (n == rule.right) {
                right_index = i;
            }
        }
        if (left_index < nums.len and right_index < nums.len and left_index > right_index) {
            return false;
        }
    }
    return true; // All rules have passed.
}

fn applyRules(nums: []i32, rules: []day5rule) void {
    var swapped = true;
    while (swapped) {
        swapped = false;
        for (rules) |rule| {
            var left_index: usize = nums.len;
            var right_index: usize = nums.len;
            for (nums, 0..) |n, i| {
                if (n == rule.left) {
                    left_index = i;
                }
                if (n == rule.right) {
                    right_index = i;
                }
            }
            if (left_index < nums.len and right_index < nums.len and left_index > right_index) {
                swapLeftRight(nums, right_index, left_index);
                swapped = true;
            }
        }
    }
}

fn swapLeftRight(nums: []i32, left: usize, right: usize) void {
    const right_value = nums[right];
    var i: usize = right;
    while (i > left) : (i -= 1) {
        nums[i] = nums[i - 1];
    }
    nums[left] = right_value;
}

fn middleNumber(nums: []i32) i32 {
    return nums[nums.len / 2];
}

fn day6() void {
    var start_x: i32 = 0;
    var start_y: i32 = 0;
    var world: [1000][1000]u8 = undefined;
    var world_w: usize = 0;
    var world_h: usize = 0;

    // Find the start position.
    var lines = std.mem.splitSequence(u8, day6input, "\n");
    var cur_y: usize = 0;
    while (lines.next()) |line| {
        world_w = @intCast(line.len);
        for (line, 0..) |c, cur_x| {
            world[cur_x][cur_y] = c;
            if (c == '^') {
                start_x = @intCast(cur_x);
                start_y = @intCast(cur_y);
            }
        }
        cur_y += 1;
        world_h = @intCast(cur_y);
    }

    var x = start_x;
    var y = start_y;
    var dx: i32 = 0;
    var dy: i32 = -1;
    var steps: usize = 1;
    world[@intCast(x)][@intCast(y)] = 'X';
    while (x >= 0 and x < world_w and y >= 0 and y < world_h) {
        const new_x = x + dx;
        const new_y = y + dy;
        if (new_x < 0 or new_x >= world_w or new_y < 0 or new_y >= world_h) {
            x = new_x;
            y = new_y;
        } else {
            const tile = world[@intCast(new_x)][@intCast(new_y)];
            if (tile == '#') {
                const new_dx = -dy;
                const new_dy = dx;
                dx = new_dx;
                dy = new_dy;
            } else {
                x = new_x;
                y = new_y;
                if (tile != 'X') {
                    world[@intCast(new_x)][@intCast(new_y)] = 'X';
                    steps += 1;
                }
            }
        }
    }
    std.debug.print("day 6, part 1) {}, right answer 4988\n", .{steps});

    var obstacles: i32 = 0;
    for (0..world_w) |obstacle_x| {
        for (0..world_h) |obstacle_y| {
            if (world[obstacle_x][obstacle_y] != 'X') {
                continue;
            }

            world[obstacle_x][obstacle_y] = '#';
            if (walksInCircle(world, world_w, world_h, start_x, start_y)) {
                obstacles += 1;
            }
            world[obstacle_x][obstacle_y] = 'X';
        }
    }
    std.debug.print("day 6, part 2) {}, right answer 1697\n", .{obstacles});
}

fn walksInCircle(world: [1000][1000]u8, world_w: usize, world_h: usize, start_x: i32, start_y: i32) bool {
    var x = start_x;
    var y = start_y;
    var dx: i32 = 0;
    var dy: i32 = -1;
    var steps: i32 = 0;
    while (x >= 0 and x < world_w and y >= 0 and y < world_h) {
        steps += 1;
        if (steps > world_w * world_h) {
            return true;
        }

        const new_x = x + dx;
        const new_y = y + dy;
        if (new_x < 0 or new_x >= world_w or new_y < 0 or new_y >= world_h) {
            return false;
        } else {
            const tile = world[@intCast(new_x)][@intCast(new_y)];
            if (tile == '#') {
                const new_dx = -dy;
                const new_dy = dx;
                dx = new_dx;
                dy = new_dy;
            } else {
                x = new_x;
                y = new_y;
            }
        }
    }

    return false;
}

fn day7() void {
    var sum_part_1: i128 = 0;
    var sum_part_2: i128 = 0;

    const Parsing = enum {
        Result,
        Colon,
        Numbers,
    };
    var lines = std.mem.splitSequence(u8, day7input, "\n");
    while (lines.next()) |line| {
        var result: i128 = 0;
        var nums: [100]i128 = .{0} ** 100;
        var num_count: usize = 0;
        var state = Parsing.Result;
        for (line) |c| {
            if ('0' <= c and c <= '9') {
                if (state == Parsing.Result) {
                    result = result * 10 + (c - '0');
                } else if (state == Parsing.Numbers) {
                    nums[num_count] = nums[num_count] * 10 + (c - '0');
                }
            } else if (c == ':') {
                state = Parsing.Colon;
            } else if (c == ' ') {
                if (state == Parsing.Colon) {
                    state = Parsing.Numbers;
                } else if (state == Parsing.Numbers) {
                    num_count += 1;
                }
            }
        }
        num_count += 1;

        if (canBeCalculated(result, nums[0..num_count], false)) {
            sum_part_1 += result;
        }
        if (canBeCalculated(result, nums[0..num_count], true)) {
            sum_part_2 += result;
        }
    }

    std.debug.print("day 7, part 1) {}, right answer 20281182715321\n", .{sum_part_1});
    std.debug.print("day 7, part 2) {}, right answer 159490400628354\n", .{sum_part_2});
}

fn canBeCalculated(result: i128, nums: []i128, use_concat: bool) bool {
    if (nums.len == 0) {
        return false;
    }
    if (nums.len == 1) {
        return result == nums[0];
    }

    const a = nums[0];
    const b = nums[1];

    if (a > result or b > result) {
        return false;
    }

    nums[1] = a + b;
    if (canBeCalculated(result, nums[1..nums.len], use_concat)) {
        nums[0] = a;
        nums[1] = b;
        return true;
    }

    nums[1] = a * b;
    if (canBeCalculated(result, nums[1..nums.len], use_concat)) {
        nums[0] = a;
        nums[1] = b;
        return true;
    }

    if (use_concat) {
        nums[1] = concat(a, b);
        if (canBeCalculated(result, nums[1..nums.len], use_concat)) {
            nums[0] = a;
            nums[1] = b;
            return true;
        }
    }

    nums[0] = a;
    nums[1] = b;
    return false;
}

fn concat(a: i128, b: i128) i128 {
    var aa = a;
    var bb = b;
    while (bb > 0) {
        aa *= 10;
        bb = @divTrunc(bb, 10);
    }
    return aa + b;
}

fn day8() void {
    var world: [200][200]u8 = undefined;
    var world_w: usize = 0;
    var world_h: usize = 0;
    var antennas: [256][20]Point = undefined;
    var antenna_count: [256]usize = .{0} ** 256;
    var lines = std.mem.splitSequence(u8, day8input, "\n");
    while (lines.next()) |line| {
        for (line, 0..) |c, x| {
            world[x][world_h] = c;
            if (c != '.') {
                const n = antenna_count[c];
                antennas[c][n] = Point{ .x = @intCast(x), .y = @intCast(world_h) };
                antenna_count[c] += 1;
            }
        }
        world_w = line.len;
        world_h += 1;
    }

    var seen_part_1: [200][200]bool = undefined;
    var seen_part_2: [200][200]bool = undefined;
    for (0..world_w) |x| {
        for (0..world_h) |y| {
            seen_part_1[x][y] = false;
            seen_part_2[x][y] = false;
        }
    }

    var positions_part_1: usize = 0;
    var positions_part_2: usize = 0;
    for (0..255) |a| {
        if (antenna_count[a] < 2) {
            continue;
        }
        for (0..antenna_count[a] - 1) |i_0| {
            for (i_0 + 1..antenna_count[a]) |i_1| {
                const dx = antennas[a][i_0].x - antennas[a][i_1].x;
                const dy = antennas[a][i_0].y - antennas[a][i_1].y;

                // Part 1.
                const x1 = antennas[a][i_0].x + dx;
                const y1 = antennas[a][i_0].y + dy;
                if (0 <= x1 and x1 < world_w and 0 <= y1 and y1 < world_h and !seen_part_1[@intCast(x1)][@intCast(y1)]) {
                    positions_part_1 += 1;
                    seen_part_1[@intCast(x1)][@intCast(y1)] = true;
                }

                const x2 = antennas[a][i_1].x - dx;
                const y2 = antennas[a][i_1].y - dy;
                if (0 <= x2 and x2 < world_w and 0 <= y2 and y2 < world_h and !seen_part_1[@intCast(x2)][@intCast(y2)]) {
                    positions_part_1 += 1;
                    seen_part_1[@intCast(x2)][@intCast(y2)] = true;
                }

                // Part 2.
                var step: i32 = 0;
                while (step < 200) {
                    const x3 = antennas[a][i_0].x + step * dx;
                    const y3 = antennas[a][i_0].y + step * dy;
                    const in_bounds_3 = 0 <= x3 and x3 < world_w and 0 <= y3 and y3 < world_h;

                    const x4 = antennas[a][i_0].x - step * dx;
                    const y4 = antennas[a][i_0].y - step * dy;
                    const in_bounds_4 = 0 <= x4 and x4 < world_w and 0 <= y4 and y4 < world_h;

                    if (!in_bounds_3 and !in_bounds_4) {
                        break;
                    }

                    if (in_bounds_3 and !seen_part_2[@intCast(x3)][@intCast(y3)]) {
                        seen_part_2[@intCast(x3)][@intCast(y3)] = true;
                        positions_part_2 += 1;
                    }

                    if (in_bounds_4 and !seen_part_2[@intCast(x4)][@intCast(y4)]) {
                        seen_part_2[@intCast(x4)][@intCast(y4)] = true;
                        positions_part_2 += 1;
                    }

                    step += 1;
                }
            }
        }
    }

    std.debug.print("day 8, part 1) {}, right answer 357\n", .{positions_part_1});
    std.debug.print("day 8, part 2) {}, right answer 1266\n", .{positions_part_2});
}

const Point = struct {
    x: i32,
    y: i32,
};

fn day9() void {
    day9part1();
    day9part2();
}

fn day9part1() void {
    const cap = 100000;
    var blocks: [cap]i32 = .{-1} ** cap;
    var block_pos: usize = 0;
    var is_file = true;
    var file_id: i32 = 0;
    for (day9input) |c| {
        if (is_file) {
            for ('0'..c) |i| {
                _ = i;
                blocks[block_pos] = file_id;
                block_pos += 1;
            }
            file_id += 1;
        } else {
            block_pos += (c - '0');
        }
        is_file = !is_file;
    }

    var left: usize = 0;
    var right: usize = block_pos - 1;
    while (left < right) {
        if (blocks[right] == -1) {
            right -= 1;
        } else if (blocks[left] != -1) {
            left += 1;
        } else {
            blocks[left] = blocks[right];
            blocks[right] = -1;
            right -= 1;
        }
    }

    var sum: i64 = 0;
    for (blocks, 0..) |id, i| {
        if (id != -1) {
            const ii: i32 = @intCast(i);
            sum += id * ii;
        }
    }

    std.debug.print("day 9, part 1) {}, right answer 6395800119709\n", .{sum});
}

fn day9part2() void {
    const cap = 100000;
    var blocks: [cap]i32 = .{-1} ** cap;
    var block_pos: usize = 0;
    var is_file = true;
    var file_id: i32 = 0;
    for (day9input) |c| {
        if (is_file) {
            for ('0'..c) |i| {
                _ = i;
                blocks[block_pos] = file_id;
                block_pos += 1;
            }
            file_id += 1;
        } else {
            block_pos += (c - '0');
        }
        is_file = !is_file;
    }

    var file_end = block_pos - 1;
    while (file_end > 0) {
        // Find the file bounds.
        var file_start = file_end;
        while (file_start > 0 and blocks[file_start - 1] == blocks[file_end]) {
            file_start -= 1;
        }

        // Traverse the free spaces.
        var free_start: usize = 0;
        while (free_start < file_start) {
            while (blocks[free_start] != -1) {
                free_start += 1;
            }
            var free_end = free_start;
            while (free_end < block_pos and blocks[free_end + 1] == blocks[free_start]) {
                free_end += 1;
            }

            // If the free space is left of the file and large enough to hold
            // it, move the file there.
            if (free_end < file_start and free_end - free_start >= file_end - file_start) {
                const n = file_end - file_start + 1;
                for (0..n) |i| {
                    blocks[free_start + i] = blocks[file_start + i];
                    blocks[file_start + i] = -1;
                }
                break;
            }

            free_start = free_end + 1;
        }

        // Go to previous file.
        if (file_start == 0) {
            break;
        }
        file_end = file_start - 1;
        while (file_end > 0 and blocks[file_end] == -1) {
            file_end -= 1;
        }
    }

    var sum: i64 = 0;
    for (blocks, 0..) |id, i| {
        if (id != -1) {
            const ii: i32 = @intCast(i);
            sum += id * ii;
        }
    }

    std.debug.print("day 9, part 2) {}, right answer 6418529470362\n", .{sum});
}

fn day10() void {
    var world: [100][]const u8 = undefined;
    var world_w: usize = 0;
    var world_h: usize = 0;
    var lines = std.mem.splitSequence(u8, day10input, "\n");
    while (lines.next()) |line| {
        world[world_h] = line;
        world_w = line.len;
        world_h += 1;
    }

    var sum_part_1: usize = 0;
    var sum_part_2: usize = 0;
    for (world[0..world_h], 0..) |row, y| {
        for (row, 0..) |tile, x| {
            if (tile == '0') {
                var trail = Trail{
                    .buffer = undefined,
                    .count = 0,
                    .all = 0,
                };
                followTrail(world[0..world_h], x, y, &trail);
                sum_part_1 += trail.count;
                sum_part_2 += trail.all;
            }
        }
    }

    std.debug.print("day 10, part 1) {}, right answer 760\n", .{sum_part_1});
    std.debug.print("day 10, part 2) {}, right answer 1764\n", .{sum_part_2});
}

const Trail = struct {
    buffer: [10]Point,
    count: usize,
    all: usize,

    fn addUnique(self: *Trail, x: usize, y: usize) void {
        self.all += 1;

        for (self.buffer[0..self.count]) |p| {
            if (p.x == x and p.y == y) {
                return;
            }
        }
        self.buffer[self.count].x = @intCast(x);
        self.buffer[self.count].y = @intCast(y);
        self.count += 1;
    }
};

fn followTrail(world: [][]const u8, x: usize, y: usize, trail: *Trail) void {
    if (world[y][x] == '9') {
        trail.addUnique(x, y);
    } else {
        const next = world[y][x] + 1;

        if (x > 0 and world[y][x - 1] == next) {
            followTrail(world, x - 1, y, trail);
        }

        if (x < world[0].len - 1 and world[y][x + 1] == next) {
            followTrail(world, x + 1, y, trail);
        }

        if (y > 0 and world[y - 1][x] == world[y][x] + 1) {
            followTrail(world, x, y - 1, trail);
        }

        if (y < world.len - 1 and world[y + 1][x] == next) {
            followTrail(world, x, y + 1, trail);
        }
    }
}

const day1input =
    \\85215   94333
    \\24582   34558
    \\98037   94333
    \\75786   66247
    \\45656   85863
    \\70998   87003
    \\30367   62007
    \\81780   23161
    \\90260   65786
    \\24710   86514
    \\14018   34310
    \\43565   47888
    \\59781   79173
    \\47761   71538
    \\85892   22181
    \\25701   61839
    \\18264   33438
    \\33747   43258
    \\39697   94333
    \\61838   37358
    \\70437   22496
    \\23562   26799
    \\11216   34419
    \\63191   11393
    \\88615   31544
    \\93481   62720
    \\29534   40919
    \\29935   18758
    \\95190   87857
    \\51306   33515
    \\30938   29652
    \\77253   30646
    \\66807   67041
    \\75203   67041
    \\15696   61800
    \\73541   29496
    \\52063   51002
    \\55826   40919
    \\79183   35633
    \\77348   44025
    \\65423   33750
    \\65816   10624
    \\52110   89611
    \\18201   22051
    \\27748   66807
    \\92259   42784
    \\14988   33500
    \\58623   64359
    \\88260   90432
    \\62079   77685
    \\45698   40919
    \\91705   64359
    \\53661   73356
    \\93541   28465
    \\76689   96938
    \\60498   93056
    \\25784   65786
    \\32811   24732
    \\62264   72520
    \\41995   43258
    \\38545   84426
    \\19555   72520
    \\73703   78074
    \\86068   72520
    \\25850   87009
    \\49433   10684
    \\74291   61839
    \\40711   10516
    \\37728   82526
    \\80842   40919
    \\24677   23062
    \\29575   52605
    \\20692   77673
    \\82910   68845
    \\33830   62419
    \\68434   73604
    \\62401   84426
    \\82646   70854
    \\38398   56339
    \\79408   51171
    \\63734   27770
    \\13556   24577
    \\75123   37015
    \\61363   69734
    \\95609   86251
    \\88545   27770
    \\50893   74026
    \\14882   87009
    \\91379   33438
    \\60224   52605
    \\72679   47888
    \\75505   59781
    \\10186   62720
    \\88379   64359
    \\90496   67041
    \\73586   93056
    \\95670   63191
    \\87141   59781
    \\13919   74934
    \\98555   74846
    \\87897   32687
    \\21880   62687
    \\29658   50213
    \\96248   83521
    \\15492   86906
    \\29496   53112
    \\25334   27594
    \\20643   86251
    \\56611   39477
    \\29416   24577
    \\74832   63164
    \\43193   43258
    \\81875   75725
    \\61800   61927
    \\24065   94333
    \\83853   31467
    \\17180   10130
    \\43720   37354
    \\65647   45425
    \\51476   10461
    \\57574   93056
    \\31072   83739
    \\75113   19490
    \\79797   26799
    \\72214   11294
    \\13116   48228
    \\93787   33438
    \\46134   19254
    \\40985   28931
    \\25988   11393
    \\23062   59151
    \\79383   11393
    \\75339   89198
    \\79708   29496
    \\13058   61839
    \\16278   45698
    \\80414   14142
    \\16351   40919
    \\54813   43258
    \\81250   87434
    \\50921   61839
    \\53645   43258
    \\70432   22523
    \\81070   32306
    \\38985   31359
    \\19798   99501
    \\92509   43258
    \\25063   66000
    \\44665   33438
    \\64806   93056
    \\74946   26300
    \\48029   30646
    \\77560   83292
    \\82468   95064
    \\29223   71914
    \\87584   63191
    \\93056   26799
    \\55648   29949
    \\14352   48844
    \\49873   34111
    \\56227   45698
    \\67703   63191
    \\68135   30646
    \\44722   90812
    \\65476   78955
    \\82704   47888
    \\50424   23079
    \\51796   70111
    \\85079   22013
    \\61910   66098
    \\84132   89544
    \\47927   62720
    \\61766   78856
    \\38484   42757
    \\57255   93056
    \\48855   78836
    \\73127   78836
    \\21236   61839
    \\15138   94333
    \\26829   65786
    \\48823   93140
    \\28401   63191
    \\75082   42757
    \\41215   26799
    \\67176   19254
    \\13673   78836
    \\53842   26386
    \\41964   59781
    \\46737   21097
    \\52719   29652
    \\20212   76559
    \\89201   82291
    \\98568   63191
    \\55425   93322
    \\69878   63283
    \\36501   27429
    \\16724   47888
    \\61592   81085
    \\41114   93056
    \\44198   47888
    \\47061   86251
    \\45289   56992
    \\47597   15576
    \\18834   66807
    \\31018   40919
    \\40775   78266
    \\25185   76021
    \\48462   64359
    \\26799   32811
    \\37199   19555
    \\94411   77560
    \\45846   48696
    \\16862   77508
    \\77988   94333
    \\89121   66807
    \\41240   94333
    \\88088   59151
    \\52125   29652
    \\12932   13054
    \\61211   28578
    \\26024   87009
    \\26312   55718
    \\14585   45698
    \\65939   91730
    \\68138   59781
    \\70317   78836
    \\83217   78836
    \\22036   26799
    \\63215   66807
    \\54110   21264
    \\12981   33069
    \\61857   29652
    \\54637   94333
    \\15241   93056
    \\19897   33438
    \\77229   86251
    \\55685   37316
    \\30161   66807
    \\61780   14101
    \\19289   17661
    \\48121   51324
    \\99355   72435
    \\62767   32811
    \\98670   19490
    \\85332   31012
    \\92588   18461
    \\67574   94379
    \\90643   66607
    \\95487   66807
    \\33530   46429
    \\87009   23062
    \\61978   27770
    \\53891   19254
    \\64426   58297
    \\70651   61800
    \\40653   40474
    \\45888   33438
    \\55241   44527
    \\11126   42398
    \\92609   93056
    \\21760   22129
    \\72079   51542
    \\41177   26196
    \\67610   68036
    \\62720   45698
    \\38295   64359
    \\69482   93056
    \\24219   66807
    \\69511   45698
    \\30242   24577
    \\46626   18573
    \\36316   80909
    \\40214   72520
    \\16785   10921
    \\27770   11393
    \\70571   43258
    \\50406   30875
    \\76411   98707
    \\75186   77560
    \\80536   11587
    \\74209   78836
    \\20188   72520
    \\30587   57435
    \\44135   58144
    \\29251   46185
    \\73362   45698
    \\52443   53860
    \\61094   46357
    \\12167   47231
    \\51846   62720
    \\75168   23761
    \\97509   65786
    \\29546   42330
    \\83531   35185
    \\67737   19555
    \\85592   61105
    \\11431   29868
    \\38480   45698
    \\42360   17615
    \\14648   34009
    \\32741   52605
    \\97324   51113
    \\79881   77560
    \\71771   32811
    \\18334   52605
    \\68130   61839
    \\61546   47888
    \\14960   52980
    \\18988   99079
    \\30289   23062
    \\75930   29652
    \\21257   44357
    \\36448   47888
    \\86654   93056
    \\11876   43258
    \\66255   40252
    \\92074   36869
    \\29648   32811
    \\17522   72850
    \\52479   93056
    \\95416   73490
    \\69033   62720
    \\60062   92471
    \\67751   61800
    \\32285   41674
    \\14164   61800
    \\84112   78836
    \\28620   16338
    \\93425   19490
    \\25079   43258
    \\63507   30646
    \\25390   43258
    \\32858   23009
    \\95361   16283
    \\94333   74724
    \\40395   72462
    \\43206   62720
    \\92330   29652
    \\84078   24447
    \\72161   64359
    \\63204   75725
    \\16143   33438
    \\71756   69784
    \\27041   11228
    \\84087   94333
    \\17409   59151
    \\51792   14329
    \\52746   17484
    \\74015   23504
    \\59054   67041
    \\29297   19555
    \\84657   86854
    \\32609   23062
    \\17060   44956
    \\25874   78836
    \\58302   54942
    \\80865   36577
    \\26487   84426
    \\66212   63915
    \\15758   94333
    \\89851   47888
    \\76509   18449
    \\82093   86251
    \\59990   86771
    \\10461   26799
    \\63653   10461
    \\61308   26799
    \\89327   86251
    \\14989   22847
    \\17367   33851
    \\86991   51588
    \\41601   19490
    \\44063   92877
    \\65372   61839
    \\64013   61800
    \\53989   52845
    \\87917   19555
    \\54951   77327
    \\49657   40919
    \\37242   69223
    \\10122   67041
    \\20118   86251
    \\94367   70551
    \\23209   24123
    \\55363   19555
    \\65064   52605
    \\12293   61429
    \\90625   71173
    \\75864   59052
    \\75980   74726
    \\82806   77560
    \\50840   17142
    \\22139   64359
    \\56146   10907
    \\68559   63191
    \\15717   32811
    \\18446   64359
    \\32393   85038
    \\38555   78836
    \\92877   27770
    \\52476   51588
    \\22255   79119
    \\57023   75570
    \\89712   52605
    \\47141   10226
    \\98051   77560
    \\69509   53053
    \\51468   15072
    \\83074   61800
    \\78836   34010
    \\32010   77560
    \\82768   59151
    \\80962   17192
    \\37056   61800
    \\55438   60664
    \\24160   67041
    \\79310   59781
    \\36425   63941
    \\41091   19348
    \\47905   12402
    \\41536   44084
    \\29509   27770
    \\54028   18938
    \\20625   28465
    \\71827   20910
    \\47338   26799
    \\10967   33904
    \\75725   27770
    \\95800   59781
    \\64759   75725
    \\37476   63745
    \\78412   65786
    \\28130   33021
    \\83725   99593
    \\53024   29496
    \\45967   45698
    \\56671   26688
    \\41707   55835
    \\77665   64081
    \\48546   27175
    \\16309   17752
    \\16089   81097
    \\76903   57741
    \\31304   65786
    \\45381   47888
    \\61640   21302
    \\55671   38075
    \\91121   39769
    \\48837   84153
    \\68378   92214
    \\77462   59495
    \\36188   31985
    \\60269   25406
    \\78335   19555
    \\74685   98007
    \\16866   98832
    \\72995   52118
    \\26388   66807
    \\36575   45698
    \\46928   70337
    \\65265   88675
    \\84605   93056
    \\42658   49345
    \\56818   78302
    \\51576   61800
    \\95552   52605
    \\84846   84426
    \\52027   32811
    \\28477   19490
    \\64359   81028
    \\47203   15754
    \\52605   20196
    \\95437   70612
    \\72068   51272
    \\59641   67041
    \\24867   29652
    \\32292   21462
    \\67584   23062
    \\35182   57668
    \\19538   30815
    \\32007   12078
    \\92975   32366
    \\30032   66807
    \\41113   19555
    \\73576   24441
    \\26722   61839
    \\54882   40919
    \\99164   94333
    \\24703   55316
    \\68050   35855
    \\60454   22975
    \\27190   47888
    \\49592   33438
    \\56765   94333
    \\49584   40919
    \\40545   51588
    \\13088   65786
    \\92702   19555
    \\25522   98561
    \\70502   49926
    \\92893   40919
    \\11623   94333
    \\84426   72520
    \\12731   67041
    \\92300   66281
    \\21625   93056
    \\26632   86251
    \\28475   77846
    \\75712   50243
    \\75879   65786
    \\69842   32598
    \\95243   90308
    \\44031   63191
    \\63456   62720
    \\47057   90323
    \\32649   80072
    \\30244   85267
    \\18656   11393
    \\70657   89691
    \\59827   54749
    \\21580   17319
    \\34612   19555
    \\71392   19254
    \\66944   33438
    \\75302   38740
    \\35677   61839
    \\66839   28758
    \\43839   86251
    \\33590   11393
    \\70339   43258
    \\73961   84251
    \\39874   75536
    \\83280   13458
    \\76702   23062
    \\38544   19490
    \\50441   53429
    \\42757   61839
    \\67041   78836
    \\12497   25094
    \\42768   65593
    \\12205   19555
    \\95448   94430
    \\32384   40613
    \\21279   78836
    \\17428   65786
    \\10614   62720
    \\61245   59781
    \\17235   93810
    \\16999   31069
    \\63526   86251
    \\39490   65786
    \\95242   25169
    \\66925   87755
    \\22315   55633
    \\56338   64359
    \\20318   17296
    \\87536   71404
    \\76054   14998
    \\51588   61800
    \\13119   27770
    \\34345   10279
    \\20023   81145
    \\37131   19490
    \\42337   47888
    \\89951   61839
    \\79435   65253
    \\13465   45698
    \\29793   92877
    \\27722   15909
    \\86832   11477
    \\81965   78836
    \\20918   11393
    \\75215   96512
    \\85783   19555
    \\90525   59151
    \\15127   56714
    \\76419   66807
    \\45429   63191
    \\40503   51588
    \\77472   66807
    \\24459   64359
    \\39273   52605
    \\65912   29652
    \\41919   27969
    \\38024   62720
    \\79322   87432
    \\43054   33081
    \\23682   19254
    \\12316   67030
    \\34222   45698
    \\98966   78166
    \\34564   64359
    \\32039   19295
    \\39662   45698
    \\77296   62861
    \\11982   65786
    \\85184   27770
    \\23308   48241
    \\87694   79043
    \\65053   65212
    \\95042   94333
    \\63925   27924
    \\61794   47888
    \\46414   12815
    \\74588   34197
    \\29733   59781
    \\32203   95057
    \\82698   70210
    \\16989   92877
    \\79186   51588
    \\47914   52605
    \\49915   10461
    \\18124   37893
    \\12186   68323
    \\80439   26799
    \\91196   78836
    \\65806   66807
    \\64937   77371
    \\39013   97072
    \\35793   78836
    \\86223   67041
    \\68919   86251
    \\16242   61839
    \\26757   69116
    \\62000   65786
    \\91400   30878
    \\43258   66741
    \\74293   19490
    \\36472   17183
    \\72537   29652
    \\79963   73712
    \\89591   42757
    \\46045   59313
    \\55267   83489
    \\11274   29652
    \\46293   59781
    \\13186   63191
    \\31736   47888
    \\17707   51784
    \\11755   96140
    \\43161   51588
    \\16657   19490
    \\13779   86544
    \\77770   78265
    \\43502   61800
    \\26568   53664
    \\16788   47888
    \\92875   91405
    \\99320   66415
    \\19490   78836
    \\38003   28554
    \\12296   77560
    \\98989   40919
    \\90146   21633
    \\11563   97245
    \\52578   66743
    \\65786   44135
    \\68704   19490
    \\69963   19555
    \\16787   45698
    \\38189   14942
    \\79734   63191
    \\40154   35300
    \\57993   51909
    \\56091   64832
    \\28153   63191
    \\88207   15883
    \\57286   63191
    \\72520   26705
    \\50122   62720
    \\95885   14865
    \\25183   75725
    \\28985   52605
    \\81747   84420
    \\50078   35018
    \\76112   98498
    \\27757   75725
    \\56391   87304
    \\58234   61800
    \\90999   19597
    \\25733   19254
    \\65607   19490
    \\62203   99203
    \\59085   19490
    \\20052   72751
    \\28344   19008
    \\58344   93056
    \\34019   33438
    \\24970   43258
    \\72586   14704
    \\12892   11393
    \\67070   19555
    \\38881   43258
    \\16457   17416
    \\15116   59120
    \\91678   75725
    \\80586   19555
    \\33881   42757
    \\61688   71092
    \\69315   56598
    \\53321   93224
    \\59151   28716
    \\87226   19254
    \\73486   94333
    \\27149   79695
    \\44397   63191
    \\86370   66807
    \\28465   70737
    \\67420   94333
    \\97544   33438
    \\11326   32811
    \\65808   52518
    \\51991   51637
    \\38955   38228
    \\40299   86251
    \\98792   59151
    \\98158   27770
    \\15911   64175
    \\33107   29652
    \\91713   47922
    \\53452   81046
    \\31259   30646
    \\61299   62720
    \\68294   65343
    \\30551   93056
    \\35457   66807
    \\73631   11393
    \\30456   28781
    \\30406   27172
    \\61078   10461
    \\72853   63191
    \\11693   23540
    \\56942   43258
    \\36376   11728
    \\45741   65210
    \\37009   63191
    \\87300   23062
    \\61087   75044
    \\47331   46996
    \\47888   86249
    \\91532   29496
    \\70212   65786
    \\24577   94333
    \\26505   67442
    \\93930   20914
    \\21051   94088
    \\56106   33438
    \\47059   52605
    \\39701   27851
    \\76753   98828
    \\80218   65786
    \\15008   60952
    \\20406   30646
    \\19425   61800
    \\41697   59781
    \\77797   85385
    \\86369   60589
    \\15816   12411
    \\12414   75725
    \\91988   58454
    \\15219   43258
    \\92982   45698
    \\71767   21358
    \\78447   30646
    \\42788   19254
    \\19254   56308
    \\54247   27770
    \\64860   48561
    \\25737   75409
    \\13014   51764
    \\68315   75543
    \\89552   51588
    \\92384   77560
    \\12292   94277
    \\55549   54939
    \\90489   26402
    \\23051   47888
    \\87275   77315
    \\90750   49201
    \\19383   75055
    \\26480   52605
    \\11456   90963
    \\24861   66890
    \\45105   51719
    \\88412   93056
    \\41192   51588
    \\10159   24577
    \\22941   19555
    \\47473   93056
    \\38267   93056
    \\24304   10531
    \\86270   44766
    \\91359   33763
    \\35745   19254
    \\35994   32620
    \\35989   59781
    \\24968   73146
    \\33438   78836
    \\84317   59781
    \\16694   84697
    \\50035   43258
    \\46849   36981
    \\21158   10033
    \\38659   59151
    \\66814   99698
    \\62569   29496
    \\26374   85324
    \\17282   10461
    \\58720   69625
    \\67926   19490
    \\32437   47132
    \\87668   25151
    \\39798   36163
    \\65779   63191
    \\36260   41236
    \\80381   34952
    \\90225   94977
    \\66679   47888
    \\88157   47888
    \\13264   26799
    \\64409   51715
    \\93067   19254
    \\30142   52910
    \\42595   27572
    \\85722   93056
    \\30646   99178
    \\53833   17578
    \\38303   64359
    \\44152   61839
    \\91913   29652
    \\73350   31975
    \\99275   71900
    \\15131   25667
    \\61889   45155
    \\18935   66807
    \\41834   29496
    \\18515   26799
    \\31759   87780
    \\40919   64359
    \\20301   66807
    \\32312   51588
    \\73708   60185
    \\95227   93335
    \\92281   83328
    \\30610   76311
    \\74684   58155
    \\59712   72520
    \\65683   13851
    \\30738   36443
    \\31859   34438
    \\82346   86251
    \\46263   65786
    \\13554   19555
    \\67042   52605
    \\61839   29496
    \\75364   19490
    \\58929   59151
    \\66416   31691
    \\88263   79906
    \\78356   61800
    \\57336   19486
    \\53785   72520
    \\16902   45698
    \\61032   38568
    \\48258   19254
    \\73802   43258
    \\94584   74739
    \\40440   30646
    \\30176   66807
    \\70136   19254
    \\25421   64359
    \\57645   66829
    \\16176   33438
    \\20419   96424
    \\51694   66807
    \\42302   61839
    \\68569   45698
    \\93917   77560
    \\69691   20005
    \\53629   91608
    \\57088   67261
    \\71814   67923
    \\93253   86251
    \\17098   42479
    \\47293   19490
    \\81492   33438
    \\12600   53176
    \\22912   20117
    \\76064   42701
    \\44694   57113
    \\96409   19490
    \\61518   29936
    \\41719   56821
    \\80558   63191
    \\29918   61800
    \\51778   86034
    \\21399   64587
    \\84781   95919
    \\13131   53727
    \\17389   59781
    \\45549   97315
    \\85797   11393
    \\87747   96380
    \\32160   44227
    \\17589   63044
    \\15753   67638
    \\75220   40577
    \\40166   43258
    \\94668   65786
    \\59922   92500
    \\10582   52605
    \\79962   67041
    \\86178   45698
    \\74569   61475
    \\94528   38255
    \\59272   59781
    \\60494   81215
    \\60692   68282
    \\37369   71278
    \\26980   83758
    \\51039   35517
    \\75162   63191
    \\81331   65786
    \\29652   27770
    \\98663   19490
    \\43026   60359
    \\14599   58212
    \\13011   27770
    \\50257   94333
    \\13018   47888
    \\40970   29652
    \\46679   71924
    \\32462   75725
    \\81209   37345
    \\64600   43258
    \\96685   92198
    \\14635   24577
    \\66344   23062
    \\93459   11393
    \\49013   11393
    \\15256   97630
    \\52161   47888
    \\66454   19490
    \\78139   47888
    \\73936   19254
    \\43733   19555
    \\35548   94333
    \\11626   85812
    \\11393   15495
    \\58006   52605
    \\92271   56010
    \\31512   98555
    \\11545   62220
    \\66798   22932
    \\13234   29652
    \\70506   72520
    \\36041   79205
    \\78007   10461
    \\59850   67041
    \\77378   67041
    \\34128   94333
    \\31147   33438
    \\45913   33438
    \\97727   61839
    \\25073   25778
    \\86251   43258
    \\58420   55502
    \\43354   78836
    \\68038   86251
    \\67290   33438
    \\90859   59151
    \\67710   66807
    \\48934   16778
    \\22667   86065
    \\72666   22924
    \\77601   64359
    \\20458   10777
    \\99233   89451
    \\54526   13900
    \\79270   75407
    \\51276   23062
    \\54733   98555
    \\60594   40919
    \\61152   92938
    \\74123   42757
    \\13243   19555
    \\55324   20819
    \\55894   23062
    \\16368   34399
    \\16600   74703
    \\59353   72520
    \\19565   11393
    \\71782   87009
    \\31511   86251
    \\83349   96101
    \\23853   40439
    \\53938   19555
    \\18254   32811
    \\86817   33438
    \\78957   74568
;

const day2input =
    \\69 72 75 78 80 79
    \\40 42 43 46 47 48 49 49
    \\57 58 59 60 64
    \\29 32 35 37 43
    \\16 17 18 19 20 17 19 20
    \\42 45 43 45 48 49 46
    \\58 59 62 65 63 66 66
    \\28 31 34 31 35
    \\37 39 41 38 40 43 45 50
    \\64 66 68 68 71
    \\50 51 53 53 55 53
    \\44 45 48 48 51 54 55 55
    \\20 22 22 23 25 29
    \\38 40 41 41 43 46 49 54
    \\24 27 28 30 33 37 38 40
    \\82 83 86 88 92 89
    \\68 69 71 74 76 80 80
    \\3 6 9 13 16 20
    \\62 65 67 71 74 81
    \\68 69 72 78 81
    \\74 77 79 85 82
    \\61 64 67 69 70 77 80 80
    \\46 48 53 56 58 61 65
    \\65 67 70 77 82
    \\61 60 62 64 65 66 69
    \\13 11 14 15 18 15
    \\57 56 59 62 65 66 69 69
    \\45 44 46 47 48 49 52 56
    \\38 36 39 42 45 52
    \\69 67 69 66 69
    \\89 86 84 87 84
    \\10 8 7 9 11 12 12
    \\97 94 91 92 94 98
    \\2 1 4 3 5 6 9 16
    \\63 62 65 68 68 71 73
    \\54 51 51 54 55 52
    \\21 20 21 21 23 26 26
    \\33 32 35 35 39
    \\70 69 69 72 73 74 76 82
    \\4 1 4 7 8 12 15
    \\8 5 8 9 13 14 16 15
    \\16 15 18 20 24 25 27 27
    \\54 53 56 60 62 66
    \\62 60 64 65 70
    \\26 23 28 30 31
    \\53 51 53 54 57 62 64 61
    \\9 6 13 16 18 19 20 20
    \\75 72 78 80 82 85 87 91
    \\8 7 10 11 16 18 25
    \\84 84 86 89 92 95 96
    \\36 36 39 41 42 41
    \\21 21 22 24 25 26 26
    \\72 72 74 77 81
    \\3 3 6 8 15
    \\9 9 12 11 14
    \\75 75 76 75 77 75
    \\7 7 8 10 12 10 10
    \\52 52 51 54 58
    \\76 76 77 80 79 84
    \\41 41 42 42 44 45
    \\85 85 87 87 90 89
    \\4 4 7 9 9 9
    \\23 23 24 27 30 31 31 35
    \\48 48 51 51 56
    \\1 1 3 7 10 13 16 19
    \\19 19 21 25 26 28 29 26
    \\73 73 75 76 80 80
    \\40 40 44 47 51
    \\74 74 78 81 84 87 93
    \\9 9 11 12 15 22 25
    \\1 1 3 10 11 14 16 15
    \\50 50 52 58 60 60
    \\59 59 60 65 69
    \\34 34 40 42 47
    \\30 34 36 39 42
    \\2 6 7 9 12 13 10
    \\15 19 21 23 24 24
    \\30 34 35 38 41 44 46 50
    \\47 51 52 55 60
    \\90 94 92 94 97
    \\68 72 70 72 75 77 80 79
    \\53 57 59 60 57 59 60 60
    \\88 92 95 96 93 97
    \\26 30 31 29 36
    \\82 86 87 88 88 90 92 94
    \\71 75 76 79 79 80 82 79
    \\42 46 46 49 50 51 54 54
    \\14 18 18 19 20 24
    \\75 79 80 80 81 87
    \\61 65 69 71 74 76
    \\69 73 75 78 80 84 85 83
    \\34 38 42 43 46 47 47
    \\35 39 41 43 47 51
    \\2 6 7 10 14 20
    \\17 21 24 30 31 34 36 38
    \\12 16 21 23 24 23
    \\87 91 93 99 99
    \\22 26 32 35 36 37 39 43
    \\46 50 57 59 62 65 67 73
    \\46 52 54 55 56
    \\27 33 35 38 40 43 46 45
    \\17 24 25 27 27
    \\19 24 25 28 30 32 36
    \\36 42 45 47 54
    \\35 42 43 44 42 45 47
    \\50 56 58 55 52
    \\32 37 38 35 38 38
    \\49 54 57 54 56 58 60 64
    \\53 58 57 58 61 64 71
    \\74 80 80 83 86 87 90 92
    \\36 42 43 45 45 48 49 48
    \\82 87 87 89 89
    \\31 38 41 41 43 45 46 50
    \\40 47 49 50 50 51 58
    \\59 64 68 69 71 73 74 76
    \\59 66 69 73 71
    \\75 81 84 88 90 92 92
    \\13 19 21 24 27 31 32 36
    \\23 30 32 35 39 45
    \\16 22 25 27 29 31 36 38
    \\3 10 12 13 19 21 23 22
    \\4 10 11 14 16 22 22
    \\4 11 14 16 23 25 29
    \\3 8 9 10 16 21
    \\64 63 60 57 55 57
    \\81 80 77 75 74 74
    \\34 33 31 30 28 24
    \\23 21 20 19 16 13 10 4
    \\56 54 51 52 49
    \\44 43 41 38 35 37 35 37
    \\82 81 84 81 79 79
    \\77 75 74 77 74 70
    \\12 11 13 10 7 2
    \\32 31 28 28 25 23 20
    \\6 3 2 2 1 3
    \\77 76 73 71 68 68 68
    \\25 22 19 17 15 15 13 9
    \\87 85 84 84 83 78
    \\42 39 37 33 32 30
    \\88 87 86 83 81 77 75 76
    \\15 12 8 6 4 4
    \\96 94 92 88 86 84 80
    \\84 81 78 76 72 69 67 62
    \\51 50 49 46 44 38 37
    \\54 53 52 49 43 42 41 43
    \\99 97 92 90 89 86 86
    \\97 95 88 85 81
    \\35 32 30 25 22 19 14
    \\73 76 75 74 73 71 68 65
    \\79 81 80 79 78 77 76 78
    \\5 8 6 4 1 1
    \\84 87 86 83 82 81 77
    \\21 23 20 18 16 15 8
    \\13 14 16 15 14 12 11 9
    \\29 30 29 31 34
    \\58 60 63 62 59 58 57 57
    \\30 32 33 32 28
    \\86 87 85 88 85 84 77
    \\36 37 37 36 35 32 31 30
    \\4 6 6 3 6
    \\27 29 29 26 26
    \\65 67 66 66 64 60
    \\90 91 89 89 83
    \\74 76 72 71 68 66
    \\74 76 74 73 69 68 70
    \\23 25 24 22 18 18
    \\59 61 57 55 53 51 47
    \\87 88 87 83 82 81 80 74
    \\55 58 57 54 51 50 44 42
    \\92 95 92 91 90 87 80 83
    \\69 70 64 63 61 58 58
    \\34 37 36 33 32 26 24 20
    \\36 37 35 34 31 24 21 16
    \\27 27 26 25 24
    \\41 41 38 35 34 35
    \\31 31 28 27 27
    \\37 37 36 34 31 28 24
    \\49 49 47 46 43 41 38 33
    \\63 63 62 59 62 59 58
    \\9 9 11 10 13
    \\23 23 21 19 22 21 21
    \\37 37 40 39 35
    \\13 13 10 11 5
    \\78 78 78 75 72 71 70
    \\73 73 73 70 71
    \\10 10 8 5 5 4 4
    \\22 22 21 21 20 16
    \\96 96 96 95 89
    \\41 41 40 36 33 32 29 28
    \\57 57 53 51 54
    \\58 58 57 56 55 51 51
    \\46 46 42 39 35
    \\21 21 18 14 12 11 5
    \\40 40 38 36 29 27 25
    \\97 97 94 89 91
    \\36 36 34 29 27 25 22 22
    \\87 87 84 79 75
    \\35 35 32 26 24 21 16
    \\52 48 45 42 40 37
    \\49 45 42 40 42
    \\95 91 88 86 86
    \\88 84 82 81 80 78 75 71
    \\83 79 78 76 70
    \\17 13 11 10 9 10 7
    \\45 41 43 41 42
    \\97 93 90 89 92 89 89
    \\17 13 15 14 12 8
    \\36 32 29 27 29 27 22
    \\50 46 45 44 41 41 40 39
    \\93 89 87 84 84 87
    \\23 19 17 16 16 16
    \\29 25 24 22 22 20 18 14
    \\14 10 9 9 8 3
    \\20 16 13 9 6
    \\22 18 16 13 9 11
    \\73 69 66 62 62
    \\16 12 8 5 1
    \\58 54 50 47 45 40
    \\46 42 40 33 30
    \\65 61 54 51 54
    \\25 21 20 19 17 15 9 9
    \\38 34 31 25 24 20
    \\71 67 66 64 58 56 51
    \\78 73 70 69 68 65
    \\32 26 24 22 21 19 22
    \\92 86 84 83 81 78 78
    \\67 62 59 56 53 49
    \\64 58 56 55 54 52 51 46
    \\82 76 74 72 74 71 69 66
    \\37 32 30 32 29 32
    \\65 58 57 59 56 55 52 52
    \\94 87 84 87 83
    \\54 47 49 48 45 39
    \\74 68 65 62 62 60 59
    \\53 47 44 43 43 46
    \\96 89 86 86 85 85
    \\62 55 53 52 52 51 47
    \\34 28 28 25 20
    \\25 20 16 13 11 9
    \\58 52 49 45 42 39 40
    \\56 49 45 43 40 37 37
    \\32 26 22 20 16
    \\94 88 84 82 75
    \\65 59 58 52 50 49 47
    \\68 61 55 53 55
    \\53 47 45 40 40
    \\73 66 61 59 57 53
    \\66 60 57 56 51 46
    \\32 34 37 38 40 43 44 42
    \\9 11 14 17 19 20 20
    \\18 19 21 24 26 27 30 34
    \\68 71 73 75 77 79 80 85
    \\75 76 79 81 80 81 84
    \\40 43 44 41 40
    \\17 20 23 25 22 23 23
    \\89 91 94 93 97
    \\20 23 26 25 28 30 37
    \\28 30 30 31 32 33
    \\23 25 25 26 25
    \\70 73 75 76 78 78 81 81
    \\18 19 19 21 22 23 27
    \\78 80 82 83 86 86 91
    \\7 10 11 12 14 18 19
    \\92 93 97 98 95
    \\33 36 40 41 41
    \\77 78 79 83 87
    \\49 50 54 57 60 63 65 72
    \\75 78 79 80 83 90 92
    \\82 84 85 92 94 91
    \\47 50 53 55 61 63 63
    \\47 48 49 50 56 59 63
    \\23 24 26 28 31 36 41
    \\28 26 27 28 31
    \\5 2 5 6 3
    \\82 81 83 85 87 88 91 91
    \\30 28 29 31 32 36
    \\39 37 38 40 42 45 51
    \\16 14 13 16 19
    \\40 37 38 40 39 41 39
    \\62 59 62 64 62 62
    \\72 70 71 68 71 74 76 80
    \\27 26 25 28 29 31 37
    \\30 28 31 34 34 35
    \\50 47 47 48 50 52 51
    \\41 40 41 44 44 46 47 47
    \\48 47 48 51 52 52 56
    \\6 3 5 7 10 10 15
    \\3 2 4 5 6 8 12 15
    \\88 85 86 87 91 94 91
    \\59 56 59 63 65 65
    \\44 43 45 49 53
    \\47 46 49 53 55 56 62
    \\32 30 36 38 39 41
    \\27 24 27 30 31 38 39 38
    \\64 61 68 70 70
    \\54 52 55 60 61 63 67
    \\23 20 27 30 37
    \\21 21 23 26 27 28 30 33
    \\22 22 23 24 23
    \\36 36 39 42 44 44
    \\48 48 51 53 57
    \\19 19 21 24 27 29 30 35
    \\35 35 33 34 35 38 39
    \\74 74 73 75 72
    \\75 75 77 74 75 76 76
    \\24 24 27 28 25 28 30 34
    \\67 67 65 67 70 72 79
    \\44 44 45 46 49 49 51 52
    \\69 69 72 72 69
    \\28 28 28 31 34 36 36
    \\53 53 53 55 56 60
    \\51 51 51 52 54 59
    \\82 82 84 88 89
    \\66 66 67 70 71 75 73
    \\82 82 85 89 91 91
    \\32 32 35 37 40 44 48
    \\27 27 30 33 37 42
    \\77 77 80 86 89 92 95
    \\65 65 68 70 77 79 77
    \\86 86 87 89 91 97 99 99
    \\31 31 36 39 41 45
    \\6 6 9 14 17 18 25
    \\27 31 32 34 36
    \\55 59 62 65 67 70 71 69
    \\4 8 11 14 15 16 16
    \\3 7 8 11 13 17
    \\73 77 80 82 85 87 89 96
    \\85 89 91 94 93 94 96 97
    \\8 12 13 12 15 18 17
    \\51 55 52 53 53
    \\21 25 28 30 29 31 34 38
    \\48 52 55 52 57
    \\1 5 6 6 8 9
    \\37 41 44 45 47 47 45
    \\44 48 50 50 50
    \\72 76 76 77 78 79 83
    \\54 58 59 60 63 64 64 70
    \\18 22 24 27 31 32
    \\33 37 40 44 45 43
    \\13 17 21 22 24 26 26
    \\24 28 31 33 37 39 42 46
    \\19 23 24 28 30 35
    \\39 43 45 52 53
    \\57 61 62 68 70 68
    \\40 44 51 54 54
    \\60 64 69 70 71 75
    \\40 44 46 53 56 59 66
    \\25 32 35 37 40 43
    \\63 68 70 72 73 74 73
    \\34 41 42 43 43
    \\1 6 7 10 11 15
    \\23 28 31 34 39
    \\91 96 95 96 98
    \\81 88 85 88 86
    \\54 60 62 59 60 60
    \\30 37 36 39 43
    \\44 51 53 51 57
    \\25 30 31 33 33 36 37 39
    \\85 92 94 94 93
    \\2 8 9 11 11 11
    \\41 46 49 49 51 54 58
    \\58 63 65 67 67 68 69 74
    \\45 50 52 56 57 60 63
    \\29 34 38 40 37
    \\67 74 76 80 80
    \\57 64 68 70 71 75
    \\6 13 16 19 23 26 29 36
    \\26 31 32 37 39 41 44 47
    \\67 72 77 80 78
    \\76 81 86 88 90 90
    \\65 72 75 78 80 85 86 90
    \\32 38 43 44 45 47 52
    \\61 60 58 57 56 54 51 53
    \\92 90 89 86 86
    \\70 68 67 65 61
    \\87 84 81 80 79 78 75 68
    \\41 38 37 40 38 35 34
    \\99 96 95 96 98
    \\53 51 50 52 50 50
    \\17 15 14 13 14 10
    \\16 15 17 14 13 6
    \\31 30 30 27 24 23
    \\43 42 39 39 38 41
    \\58 55 52 49 47 46 46 46
    \\61 59 58 58 55 51
    \\58 55 55 54 52 49 46 39
    \\43 42 38 37 35
    \\96 93 89 88 87 90
    \\80 79 76 75 74 70 70
    \\53 50 49 47 46 42 38
    \\38 35 31 29 28 22
    \\87 84 81 79 74 73 71
    \\23 22 20 19 12 11 8 10
    \\20 17 16 9 9
    \\20 18 16 10 7 3
    \\21 19 17 11 8 7 2
    \\64 65 62 61 60 59 57
    \\17 18 17 14 12 15
    \\61 64 63 60 59 57 57
    \\88 91 88 86 83 79
    \\97 99 97 94 88
    \\69 70 72 69 66
    \\23 24 23 24 25
    \\43 46 44 42 44 43 41 41
    \\19 20 19 21 19 15
    \\62 63 64 63 61 59 57 51
    \\90 91 89 86 86 83 81 78
    \\73 74 72 71 71 68 66 69
    \\37 40 38 36 36 33 31 31
    \\35 38 38 35 31
    \\76 77 77 74 68
    \\76 78 75 73 69 66
    \\67 68 64 61 58 55 53 55
    \\53 55 51 49 46 44 44
    \\47 48 44 43 39
    \\89 92 89 86 82 76
    \\26 29 27 21 20
    \\78 80 74 73 70 69 70
    \\75 78 72 70 70
    \\16 18 15 9 5
    \\73 76 70 67 65 63 58
    \\37 37 35 32 29 26 23
    \\41 41 39 36 33 32 30 33
    \\75 75 72 70 67 66 65 65
    \\26 26 24 23 22 21 17
    \\98 98 97 94 93 91 88 82
    \\14 14 15 13 10 8 5 3
    \\33 33 31 29 26 28 29
    \\31 31 29 26 28 28
    \\91 91 88 86 87 85 81
    \\72 72 70 73 70 67 64 57
    \\22 22 22 20 19 17
    \\74 74 74 71 69 66 63 64
    \\25 25 22 22 22
    \\33 33 32 30 28 28 24
    \\84 84 81 78 78 76 71
    \\19 19 15 12 9 8 7
    \\74 74 71 70 66 63 65
    \\46 46 45 41 41
    \\38 38 34 33 29
    \\44 44 43 39 32
    \\17 17 10 8 5
    \\89 89 87 85 84 79 78 80
    \\21 21 18 17 12 12
    \\66 66 65 62 60 54 50
    \\81 81 78 76 69 66 63 57
    \\40 36 34 33 30 29
    \\30 26 25 23 22 20 21
    \\24 20 17 14 13 11 10 10
    \\84 80 77 75 72 71 67
    \\64 60 58 55 53 48
    \\88 84 83 85 82
    \\33 29 32 30 31
    \\73 69 67 70 70
    \\95 91 88 87 85 84 85 81
    \\34 30 29 26 27 22
    \\61 57 57 55 52 49 47
    \\48 44 43 43 46
    \\75 71 70 68 68 65 64 64
    \\46 42 42 40 36
    \\79 75 72 72 69 64
    \\96 92 91 87 85 83 82 80
    \\80 76 75 71 69 67 70
    \\61 57 53 51 51
    \\21 17 15 13 11 7 3
    \\26 22 19 15 12 6
    \\73 69 67 60 58 57 56
    \\57 53 47 46 48
    \\65 61 59 56 51 48 48
    \\35 31 28 22 21 17
    \\49 45 43 36 34 33 30 24
    \\46 41 40 37 34 32
    \\79 73 70 67 65 63 60 63
    \\37 32 31 30 30
    \\66 59 58 56 55 54 50
    \\42 36 34 32 26
    \\74 67 66 68 65 64 62
    \\34 27 24 22 25 23 21 23
    \\24 19 16 17 15 15
    \\40 33 32 30 33 31 30 26
    \\73 66 65 66 60
    \\23 16 14 14 12 9 6
    \\74 69 67 64 64 65
    \\47 40 37 35 32 29 29 29
    \\37 31 28 25 22 20 20 16
    \\60 53 51 49 48 48 46 39
    \\76 70 66 63 60
    \\59 52 48 47 50
    \\49 43 42 38 38
    \\84 79 75 73 72 71 67
    \\75 69 68 64 62 60 55
    \\71 66 60 57 56
    \\70 64 57 54 53 51 48 51
    \\89 83 77 75 72 69 69
    \\50 45 44 42 40 38 31 27
    \\40 33 27 26 23 20 13
    \\12 13 16 19 22 24 23
    \\45 48 51 52 53 54 56 56
    \\30 31 33 35 38 42
    \\81 82 84 87 93
    \\10 13 14 15 13 16
    \\46 49 51 52 53 54 51 49
    \\13 14 17 16 16
    \\36 39 42 39 42 45 47 51
    \\11 13 15 12 19
    \\54 55 55 57 60
    \\30 33 33 36 39 37
    \\42 44 45 45 46 48 48
    \\34 35 35 36 39 43
    \\32 34 37 37 40 43 48
    \\22 25 29 32 33
    \\6 9 10 11 15 14
    \\77 78 82 84 87 87
    \\24 26 30 33 34 35 37 41
    \\45 48 51 52 56 63
    \\18 21 22 23 28 29 31 33
    \\9 10 13 16 22 21
    \\31 32 38 41 43 43
    \\72 74 77 84 85 88 89 93
    \\37 39 42 49 51 52 59
    \\73 72 73 76 77 79
    \\6 3 6 7 10 11 9
    \\67 66 69 72 74 76 78 78
    \\8 5 6 9 10 11 12 16
    \\60 57 59 60 63 64 70
    \\35 32 30 33 36 39 41 42
    \\29 28 26 28 31 32 29
    \\94 92 90 91 92 92
    \\23 20 18 20 22 23 27
    \\10 9 11 8 14
    \\38 35 38 38 41 42
    \\23 20 23 23 26 29 26
    \\61 58 58 61 63 63
    \\64 61 62 65 65 68 72
    \\7 5 6 6 13
    \\12 9 13 15 18 19 22 23
    \\16 14 17 21 24 23
    \\71 68 72 73 75 75
    \\12 11 14 16 20 22 23 27
    \\10 8 11 15 16 22
    \\54 53 55 58 63 64
    \\89 87 90 95 92
    \\17 15 17 19 21 22 29 29
    \\46 43 50 51 55
    \\48 45 48 49 54 59
    \\82 82 85 88 89 91
    \\11 11 12 13 14 17 14
    \\77 77 78 79 80 81 84 84
    \\74 74 77 79 80 81 85
    \\22 22 23 24 31
    \\82 82 81 83 85 88 89 92
    \\26 26 29 30 27 30 29
    \\56 56 57 60 63 65 62 62
    \\72 72 71 74 78
    \\5 5 8 6 11
    \\74 74 77 78 78 80 83
    \\27 27 30 30 33 31
    \\16 16 16 19 20 22 22
    \\77 77 79 81 81 85
    \\37 37 39 40 41 41 43 48
    \\67 67 68 69 73 74 76 79
    \\3 3 6 8 12 15 14
    \\83 83 87 88 89 92 92
    \\22 22 26 29 30 31 34 38
    \\2 2 5 8 10 13 17 23
    \\68 68 71 78 81
    \\15 15 17 22 24 21
    \\10 10 13 16 23 23
    \\16 16 17 18 24 27 31
    \\25 25 27 29 32 39 46
    \\23 27 28 31 33 36 37
    \\83 87 89 91 88
    \\44 48 49 50 53 53
    \\46 50 52 54 57 61
    \\9 13 16 17 19 22 29
    \\31 35 36 33 35
    \\81 85 84 86 85
    \\3 7 9 12 15 18 15 15
    \\50 54 53 55 59
    \\46 50 51 54 52 58
    \\58 62 63 66 66 67 70
    \\35 39 39 41 43 41
    \\29 33 36 37 37 37
    \\13 17 17 20 24
    \\71 75 75 76 79 81 84 89
    \\21 25 29 31 32 33 35
    \\33 37 40 44 46 48 47
    \\5 9 12 13 15 19 19
    \\23 27 30 34 37 38 42
    \\51 55 56 60 63 64 70
    \\50 54 57 60 62 63 68 69
    \\24 28 31 32 33 36 43 40
    \\24 28 29 30 36 37 38 38
    \\52 56 61 63 66 70
    \\15 19 25 27 29 34
    \\26 33 36 38 41
    \\23 30 33 34 32
    \\65 70 72 74 75 75
    \\13 18 20 22 26
    \\43 50 53 55 58 59 66
    \\12 17 19 18 21 24
    \\27 33 36 37 38 37 40 38
    \\74 81 82 84 85 84 86 86
    \\19 26 23 25 26 28 32
    \\77 83 84 81 88
    \\48 55 58 61 64 64 65
    \\40 45 47 47 48 49 47
    \\58 63 65 67 70 71 71 71
    \\30 35 36 39 39 42 46
    \\74 81 83 86 86 92
    \\67 72 74 76 79 83 84 85
    \\49 54 56 60 61 62 61
    \\62 67 71 73 74 74
    \\38 43 47 48 51 54 57 61
    \\19 26 27 30 34 40
    \\41 46 52 54 55 56
    \\36 42 44 50 51 50
    \\11 17 20 21 26 29 30 30
    \\24 30 33 39 41 42 46
    \\3 8 11 17 19 25
    \\85 84 81 80 79 76 79
    \\17 14 12 10 10
    \\30 27 25 23 19
    \\23 20 18 15 14 7
    \\38 36 35 33 34 32
    \\59 58 56 57 56 54 56
    \\45 44 46 44 41 41
    \\24 21 19 16 18 16 13 9
    \\79 77 75 73 72 74 72 66
    \\43 42 39 39 37
    \\33 30 28 28 25 24 22 24
    \\15 13 11 10 10 9 6 6
    \\94 93 91 91 88 84
    \\52 50 50 47 42
    \\59 57 54 50 47 46 44 42
    \\16 14 12 8 6 8
    \\91 88 84 82 82
    \\34 31 30 26 24 23 19
    \\85 84 81 79 78 74 68
    \\94 93 91 90 87 82 79 78
    \\28 25 18 16 17
    \\78 75 69 68 67 64 61 61
    \\37 34 28 26 22
    \\98 96 95 90 83
    \\48 51 50 47 46
    \\38 39 37 36 38
    \\49 51 49 47 45 44 44
    \\61 64 63 60 58 54
    \\18 19 18 16 11
    \\88 89 88 90 87 85 84 82
    \\6 8 11 10 11
    \\91 93 90 87 84 87 85 85
    \\77 80 78 81 80 78 74
    \\21 24 25 22 17
    \\86 88 85 82 82 80
    \\51 53 51 51 50 48 49
    \\53 55 55 52 50 49 49
    \\27 30 29 29 25
    \\54 55 52 50 50 47 41
    \\59 61 60 56 53 50 48
    \\82 85 81 79 78 75 77
    \\59 61 59 55 53 53
    \\27 29 26 22 20 19 18 14
    \\51 52 49 45 38
    \\39 40 38 37 36 35 29 26
    \\65 66 65 59 57 56 54 56
    \\93 94 92 87 86 86
    \\39 41 40 37 31 28 24
    \\43 46 39 36 30
    \\46 46 44 43 40
    \\42 42 41 38 36 34 37
    \\45 45 44 42 39 37 34 34
    \\81 81 80 78 75 71
    \\29 29 28 26 25 22 16
    \\83 83 82 85 84
    \\70 70 67 66 69 67 70
    \\31 31 29 32 32
    \\47 47 44 46 42
    \\11 11 12 11 10 3
    \\81 81 79 77 77 76
    \\79 79 79 76 78
    \\28 28 25 25 25
    \\66 66 63 60 60 58 55 51
    \\18 18 18 15 14 12 5
    \\35 35 33 31 30 26 24
    \\7 7 3 2 5
    \\76 76 74 73 69 67 66 66
    \\30 30 28 24 23 22 18
    \\92 92 89 85 84 82 75
    \\42 42 41 38 36 30 29 26
    \\74 74 73 70 68 61 58 60
    \\74 74 72 67 67
    \\76 76 69 66 63 59
    \\66 66 63 62 61 55 54 49
    \\97 93 91 88 85 82 79 76
    \\58 54 52 49 46 43 46
    \\92 88 85 82 80 79 79
    \\86 82 80 79 76 74 70
    \\32 28 25 22 20 13
    \\68 64 61 59 57 54 55 53
    \\72 68 70 67 64 67
    \\96 92 95 94 92 92
    \\58 54 52 54 51 47
    \\39 35 33 32 34 32 26
    \\87 83 81 79 76 76 73 70
    \\54 50 49 49 50
    \\78 74 74 73 73
    \\53 49 49 47 45 41
    \\64 60 60 59 57 55 52 46
    \\64 60 59 55 54
    \\13 9 5 4 7
    \\23 19 17 15 11 11
    \\86 82 80 79 75 72 69 65
    \\88 84 80 77 76 70
    \\89 85 83 82 75 73 70
    \\86 82 77 76 74 72 69 70
    \\32 28 25 23 22 21 14 14
    \\77 73 70 68 61 59 57 53
    \\58 54 48 47 46 45 39
    \\16 11 9 7 4 1
    \\24 17 14 13 14
    \\71 65 63 61 58 56 53 53
    \\85 80 79 77 76 75 71
    \\83 77 76 74 73 70 67 60
    \\88 83 80 81 79 77 75
    \\72 67 69 67 65 63 61 64
    \\18 12 9 12 12
    \\89 83 81 78 75 76 74 70
    \\46 41 39 36 37 32
    \\83 78 75 74 71 71 69 67
    \\47 40 40 39 38 35 32 35
    \\46 41 39 37 37 37
    \\58 51 48 48 47 45 41
    \\65 60 60 59 53
    \\26 19 15 13 12
    \\17 11 9 8 4 5
    \\89 83 82 80 76 75 73 73
    \\71 66 63 62 59 55 51
    \\78 73 69 67 60
    \\39 32 26 24 23 22 19
    \\70 64 59 57 54 51 50 51
    \\30 23 18 15 15
    \\79 72 69 64 60
    \\25 19 16 11 8 2
    \\48 44 42 39 39
    \\4 8 14 17 17
    \\92 91 90 89 86 86
    \\16 19 15 13 12 6
    \\39 36 29 28 31
    \\78 75 77 78 79 79
    \\20 24 26 29 33 37
    \\81 78 82 85 86
    \\41 37 30 29 28 26 24 24
    \\68 73 80 82 81
    \\90 88 87 84 81 78 76
    \\86 84 83 80 77 76 75 73
    \\69 67 65 62 60
    \\22 24 26 29 32 34
    \\14 12 10 7 4
    \\69 71 73 75 78 81
    \\51 48 45 42 40 38 37 36
    \\50 51 53 56 58
    \\96 94 93 92 89
    \\59 58 55 54 53 51
    \\43 42 41 38 35
    \\61 63 65 67 70
    \\97 96 95 94 93 91 89 88
    \\17 16 15 12 11 8 5
    \\17 19 20 23 26
    \\44 47 48 49 52 53 54 57
    \\53 52 51 49 48 47 44
    \\84 83 81 80 77 74 73 71
    \\24 22 21 18 15 12
    \\71 74 75 76 77 79 82 85
    \\5 8 11 12 14 15 18 21
    \\35 37 39 41 43 46
    \\41 44 47 48 50 51 53
    \\46 43 40 37 35 34 31
    \\30 27 24 22 19 16 13
    \\54 57 58 61 63 66
    \\77 80 82 85 86
    \\60 63 65 68 70 71
    \\83 85 86 88 89 90 91 94
    \\72 71 68 65 64 63 60
    \\59 60 63 64 66
    \\60 57 56 55 53 50
    \\54 57 60 61 62
    \\56 59 60 61 63 66 68 71
    \\57 58 61 64 66
    \\61 62 63 65 68 69
    \\32 30 27 26 23 22
    \\54 52 49 48 46 43 41
    \\20 22 23 24 25
    \\28 27 24 21 20 18 15
    \\75 73 70 67 65
    \\80 78 75 74 73 72
    \\37 36 34 31 28 26 25 24
    \\24 26 29 32 34
    \\86 89 91 93 94 95 97
    \\57 54 52 49 46 44 42 41
    \\75 72 70 69 68 65 62 61
    \\27 29 30 31 34 35 38 41
    \\17 20 23 25 28
    \\38 36 33 31 29 26
    \\98 95 92 91 89
    \\14 13 10 9 6 4 2
    \\24 26 29 31 33
    \\44 46 48 50 52 54 55
    \\46 45 43 40 39 38 36
    \\16 17 18 20 22 24 27
    \\89 90 93 96 97
    \\55 56 58 59 60 61 64 65
    \\68 69 72 75 77
    \\75 74 72 69 68
    \\63 65 68 69 70 73
    \\65 67 70 73 75 76
    \\72 71 68 65 62 60 58 56
    \\19 22 23 25 27 29
    \\35 37 38 40 41 43 46
    \\22 24 25 26 28 29 31
    \\54 52 49 47 45 42
    \\8 9 12 13 14 17 18
    \\55 53 52 51 48
    \\27 24 23 20 17 16 13
    \\65 67 70 73 76 77 80 83
    \\9 11 12 14 16 18 20 22
    \\18 20 21 23 25 28 31 32
    \\65 67 68 70 72 74 76
    \\17 20 23 26 28 31
    \\38 39 41 43 45 46
    \\69 71 73 76 77 79
    \\89 90 91 94 96 97 98
    \\87 89 92 94 96 98 99
    \\34 36 37 38 40 42 45
    \\13 15 18 21 24 26 28
    \\81 80 79 77 74 73 72 69
    \\51 50 49 46 45
    \\68 65 64 61 58
    \\56 55 54 52 51 50
    \\14 13 11 10 8 7 5
    \\9 12 15 16 17 18 21
    \\86 87 90 91 94
    \\87 86 83 82 80 77 75 74
    \\16 17 18 21 22 24 27 30
    \\38 40 42 45 48 49
    \\69 67 66 65 62 59 56 54
    \\60 58 55 54 52 50
    \\48 46 44 41 38
    \\96 94 92 90 89
    \\77 79 81 82 84
    \\99 97 94 93 92 89 87
    \\82 81 78 76 73 70 67
    \\75 72 71 70 68 65 63
    \\17 16 15 12 11
    \\41 43 45 48 51 54 56
    \\36 34 31 30 29 28 26 23
    \\69 68 67 65 62
    \\83 81 80 77 76 73 70 68
    \\44 41 38 36 35 32 30
    \\77 78 79 80 83 86 89
    \\45 46 48 51 53 55
    \\12 14 17 18 21 23 25 27
    \\39 40 42 43 44 45 47
    \\7 9 11 14 15 17 20 22
    \\65 64 63 61 58 55
    \\35 32 30 28 25 24
    \\7 8 10 12 14 17 18
    \\54 53 51 49 46
    \\39 38 37 36 33
    \\83 84 85 86 89 92
    \\23 20 17 14 13 11 9 6
    \\31 30 29 28 26 23 21
    \\37 39 41 42 43 45
    \\90 87 86 85 83 80 77 75
    \\55 54 52 50 49 47
    \\10 12 13 16 19 21
    \\51 53 54 56 58 59 61
    \\46 49 51 53 55
    \\83 85 88 90 93 96 97 99
    \\25 27 28 31 32
    \\34 35 38 41 44 47 49 51
    \\16 15 12 10 8 5
    \\52 50 47 44 41 39
    \\80 83 85 86 88 89 92
    \\34 37 38 39 40 41 42
    \\54 56 58 61 62 63 65
    \\23 26 28 30 32 33
    \\28 26 23 22 19 16 15 13
    \\52 55 57 59 62
    \\76 73 71 70 69 66 64 62
    \\73 75 78 81 83 86 87 90
    \\57 55 52 50 49 47 44
    \\74 76 79 82 84 85 87
    \\27 25 24 23 20
    \\91 92 93 96 98 99
    \\40 41 44 46 48 50
    \\45 48 50 53 54 56
    \\91 89 88 87 86
    \\13 16 18 20 22 24 26
    \\87 89 90 91 94
    \\81 82 84 86 89 90
    \\59 61 62 64 67 69
    \\32 29 28 25 24 22 20
    \\34 32 30 28 27 26
    \\21 22 25 27 28 31 34 35
    \\59 56 53 50 49 48 47
    \\74 71 69 67 65 64 63 61
    \\48 45 42 41 38 35 32
    \\51 50 47 44 43 42
    \\35 34 33 32 31 30 29 26
    \\83 80 77 75 74 72 69
    \\32 29 28 27 26 24 21
    \\68 70 71 74 75 78 80
    \\23 25 27 30 33 36 39 42
    \\35 36 38 40 41 42 43 45
    \\58 60 61 62 63
    \\35 37 40 42 45 47 50
    \\87 86 84 82 81
    \\33 36 39 40 42 44
    \\8 5 4 2 1
    \\68 66 63 61 58
    \\34 32 31 29 26 25 22
    \\3 6 7 9 10 11 12
    \\42 41 39 37 35 33 32
    \\54 56 59 61 64 67 68 71
    \\28 30 32 35 37 38 39
    \\23 21 20 19 17
    \\78 77 74 71 69 68
    \\38 36 34 33 30 27 24
    \\65 68 71 73 74 76
    \\41 38 37 35 32
    \\53 54 55 57 58 59 62 65
    \\59 62 65 67 70 71 72
    \\70 73 74 77 80 81 83
    \\97 96 94 91 90 89 88
    \\47 44 41 38 37 36
    \\62 61 59 56 55
    \\95 92 90 89 88 87 85
    \\14 11 8 7 6 3 2 1
    \\75 78 81 84 86 88 90
    \\37 35 33 30 29 28 26 24
    \\75 76 79 81 84 86 88 90
    \\78 76 74 72 69 66
    \\59 57 56 55 52 51 48
    \\50 53 54 56 59
    \\45 43 40 38 37
    \\12 14 16 18 21 23 26
    \\80 81 84 87 88 91 93
    \\59 58 56 54 53 50
    \\16 14 13 12 9 7 5 2
    \\18 21 24 25 26 29
    \\14 16 17 19 22 23 26
    \\92 89 86 85 82 81
    \\60 63 66 69 71 72 74 75
    \\62 64 65 68 71 74 75 78
    \\48 49 51 53 55
    \\78 75 74 72 71
    \\67 68 69 70 72 73
    \\21 23 24 27 29 30 32
    \\2 5 8 10 12 14
    \\30 28 25 23 21 18 15
    \\66 65 64 62 59 56
    \\48 49 52 54 55
    \\80 83 85 86 87 89 91
    \\52 50 48 47 44 42 40
    \\54 53 50 49 47
    \\86 89 91 92 95 98
    \\27 30 31 33 36
    \\32 35 38 41 43 46 49 50
    \\24 23 21 20 18 16
    \\89 86 83 80 77 76 75 74
    \\26 29 30 31 34 35
    \\45 44 41 39 37
    \\32 33 36 38 40 43 45
    \\74 76 79 82 85
    \\16 17 20 22 25 27 28
    \\28 30 32 33 36 37 38 39
    \\76 73 71 70 67 66 64 63
    \\16 13 12 9 6 5
    \\27 24 22 20 19 16 14 11
    \\24 26 27 29 31 33
    \\44 47 49 50 52 54 55 58
    \\29 27 25 22 20 17 16 14
    \\31 32 34 35 36 39 41 43
    \\44 41 38 35 32 29 28
    \\27 29 31 33 35 36 39
    \\89 88 85 84 83 81 78 76
    \\70 71 72 75 76 77 80
    \\69 67 66 63 60 57 56
    \\20 22 24 26 28 30
    \\86 83 81 80 77 75 72 69
    \\18 17 14 11 9 8 5 4
    \\53 54 56 59 60 61 63 65
    \\13 16 19 20 22 23 24 25
    \\42 45 47 50 51
    \\35 32 29 27 26
    \\28 29 32 35 37 39 40 43
    \\82 79 77 74 72 70 69 67
    \\66 63 60 57 54
    \\20 23 26 28 30 31 34 35
;

const day3input =
    \\%why();how()*-],+!mul(696,865)why()from()how():,;{where()mul(170,685)who()how()*from(881,957)?&select()mul(894,569):mul(648,114);[:from(657,891)how()mul(740,402)what()&/,do()~^why()who(762,850)mul(80,670)what()^mul(627,741),[?<'when()?-{/mul(609,307)mul(432,475)why()>/mul(325,720)how(555,834)-]~]who()from()mul(823,923)<mul(884,851)/?<;-#!*mul(696,404)[from()]from()%<mul(93,418) ?why()'mul(187,144):-/,where()'&mul(280,602)><##how()how()*mul(716,717)'[!:mul(694,196)mul(721,78),*mul(239,457)^who()%~who(),:mul(490,688)(select(140,964)~) where()mul(478,704)when()mul(707,387)?*from()[mul(867,836)how()from()%+?mul(574,230);select()&where()&(&!,mul(817,18)~@mul(995,936){:~#}[{what()how(933,435)%mul(698,758)-mul(155,15)^'who();{;when(538,128)what()([mul(987,654)/>@'mul(547,334)#who()who()mul(481,545)[select()}<*@what()@where()mul(297,163)>~;?mul(569,963) who()%;$?)mul(829,771)'^;<how()!mul(278,922):when()['+/mul(853,126)select()<#what()^where()^mul(592,699)@-when()@who()-from()]$what()mul(516,92)mul(595,56)select()[;who()#{mul(677,424)/how()where()select()*mul(372,577)why(151,413)&~<'how()when()why(576,783)mul(103,253),&#(&what()({<)mul(877,948)select()  what()when()mul(591,830)' mul(680,751)select()&~%when(342,703)-(do()mul(33,531)#mul(751,44)}!select(290,10)*why()where(926,27)mul(998,521)+ ;(when()mul(88,951)mul(138,676){ mul(124,751)<!mul(390,250) )?#%from()}who()+@mul(190,100)@*,~*what()]mul(875,335){~)?%;![,mul(798,35)*($!&where(421,181)mul(164,359)mul(243,559) &,-''+mul(946,934)]['mul(473,611)(mul(436,844)&don't()$'[:)*mul(323,105)(from()+<mul(403,154)mul(404,75)what(),:'<&from()-'when(951,634)don't()}<>^$$<}when()mul(551,298)-![>#%mul(269,961);;$%(select()don't()<where();(mul(986,541)^$#~what()':[<do() ?from()++,]mul(294,595)how()mul(140,343)&?when(645,695)select();who()mul(722,871),{when()from()%(]^@don't()@~](mul(892,4)[mul(27,39)$[from(880,299)<]mul(183,314)[how(275,880)-mul(377,858):who()*select()@-mul(214,884)#<mul(783,441)?!&mul(414,821),,mul(333,787){+-]+-$(*#do():@% where()-'why()?mul(239,3)mul(899,369)*-[>how()+(mul(490,391)why()where()}}]<])-mul(665,733)* ;select()% ;what()who()!mul(651,691)':mul(972,924)mul(898,314)'/when()><}$)select(196,43)when()mul(622,9)mul(790,299<]~>*from()mul(898,775)mul(433,345)?+mul(936,855)>who()@what()mul(110,344)%mul(375,719)?}'{&where(279,765)mul(846,455)^,{~#<{^;mul(266,935how())~:]-? who()mul(516,281)$~mul(443,485){(mul(798,807)%mul(289,360):*why()~{$!*?'do()?how()mul(316,376)*what()where()[mul(829,9)%$!what()$ &mul(140,439)[why() don't()where(451,986)%]from()mul(335,971),where()^,+mul(109,542);]-when()how()*~mul(209,405)who()$mul(132,427)when()#/>$]mul(773,709)]select()@<^mul(976,853)@where()mul(999,764)who()?^@mul(117,681)/{mul(940,729);})}mul(892,189)why()>,how() &mul(22,503)%+#mul(740,5)mul(848,467),where()>~#^[mul(827,812)!#?'what()$why()what()mul(365,268)$select()+mul(208,463)mul(676,938)
    \\;select()why()^mul(356,375)where()mul(644,829)select()+(&what()&]do()mul(371,455)#}when() select()$mul(652,219)how()/%; >#,'+mul(512,393)where()(+@do()!#where(387,495)select()} why(),where();mul(239,141)+where(){$<;*select()+,mul(96,709)#[how()* +mul(912,58)/,how()mul(683,735)$from()]mul(373,231)from()[why()*how()}%when()+mul(136,796){>don't() ;}<>mul(259,152)mul(263,197)select()where()~(}[:&[mul(77,351)^from()from()who(241,994)select()}&mul(171,570)%mul(468,387)[:when()@>what()^who()[mul(985,798)>&when(578,541):*select()?;mul(686,290)~mul(37,211)?/}*-from()>mul(783,730)({]@why()from()when()&mul(419,383]#%why()where()$who())<~#mul(577,971)*;$& !what() ^<mul(259,377)mul(143,141)*'#;)do()#?@*mulselect(970,242)>mul(912,199)how()don't();when()#mul(294,64)select()where(),'mul(928,320)!+mul(356,471)!where()~]%?]@;mul(118,693)$(mul(300,429)%<[mul(921,437)>how()where(){when()(mul(954,689);how()+$mul(339-,,:mul(368,675)mul~how(81,849)from()?%where();;}where()do(){),>:(#{@where()mul(210,692)!{when(386,55)? mul(930,193) '?mul(346,981)&+-mul(118,871)when()who())when(356,533)mul(953,458)[}why()[{<&<mul(456,691)/[)[select()),%from()who()mul(387,855)^}how()mul(836,825)[why()/mul(749,848)}>where()where()when()@&>where()mul(20,206)#when()select()from()why()$mul(900,802)~(;+(what()mul(995,20)$>'mul(652,338)>mul(363,197)', *?mul(574,101)(when()mul(49,923),;[@:)<mul(443,90),'when()do()~who()}/why(){ ,$?mul(530,543):from()%when(){mul(146,746)^/+]mul(228,661)/who()what()select()} select()mul(407,315)(?>$select()from()when()@mul(228,113)<from()when(455,516)&&don't()?mul(742,490)%&(why()'%mul(576,926))*&what()~don't()@?{'%mul(744,327)#from()where()^how();from()?mul(55,161)~!where();mul(97,213~from(),[mul(990,277)$&,why()what()#mul(424,256)who():]mul(92,211)%>,when();&~/!from()mul(8,372)'}mul(994,769(:@from()<}#why()mul(143,743)>^:!who()$%~?mul(117,918)/@from(),$why()(mul(93,84) mul(672,287)*mul(37,58){^when()~!do()when()!:who(100,513)what()-when()}mul(882,415)-why()~>where()'what()from(838,518)]what()do()@who()]~&mul(29,312)when()why()mul(510[^{*how(663,533)~[*&%mul(664,861)?;$*%+{/mulwho(),what()from()who()!,:where();mul(302,326)when()mul(83,497from()mul(35,835)[mul(429,210){#mul(481,597)+how()&++^+mul(945,205)%don't()^mul(687,611)from()~>why() ,when(140,559)mul(164,17)]~}}-who() mul(520,959)select()select() select()*:mul(575,641)how()mul(842,465)mul(322,73)/&'mul(110,310)>why()from()why(498,7)mul(571,479&from()]%%mul(438,202)who(364,547)from()&; mul(248,502)~{what(),[- select()mul(914,662*{%<~<mul(695,24)from()+{<mul(178,80)/>when()mul(508,814)do()%*how()who()from()why(640,284) mul(373,756)'>from()when(904,81)}mul(377,402)mul(352,617)where()select(668,44)+$!mul(977,96)mul(925,147)% select()mul(757,594)mul(667,169) when()who()who()who()mul(12,935)where())%what()what()$from(964,723)mul(84,767)^from() @mul(137^mul(543,4)who()how()};>/do()+select()@}&:+}mul(604,839)from()when()~why()~what()}mul(351,200)where()<)what()}mul(433,87)/$ how()-}mul(666,797)#@+who()how()why()?from()mul(772,579),why()why()from()-{;-}mul(602,921)^>mul(471,330)what()};%when()';:*&mul(438,87)^{( where()!$*from()mul(130,21)from()-[mul(797,649)'{from()/when()mul(897,988) ;when()%!'mulwhy(596,766)$'?how()mul(582,139)} ^><;how(171,166)mul(893,362)where()-'from()how(),mul(371,80):'who(808,795)$mul(72,103)[mul(492,476)(when()~select()~[who()#why()mul(21,185),'?/mul(801,258))mul(548,942)
    \\?-$mul(975 &+#select(489,349)*who())who();)mul(124,21)#from()where()+)/*~ -mul(632,17)%$ don't()mul(939,610)from()(!when()^!^mul(154,101)select()#;mul(338,243)~what()how()&; mul(691,416)*who()@what()mul~where()$<]mul(709,640)? ,/^%where()#*mul(36,427)-where()><#select()mul(457,45)@,*who()when()mul(468,642)where(),how()#'mul(209,501)^;@<+mul(598,391){)(>*mul(760,765)!#}who(894,980)when()what()'%[mul(259,651)^]:mul(955,578)from();({>what()select()*;when()mul(145,399){~what()from()where()who()?-]do();%mul(123,308)mul(488,897)?>';$;where()/mul(249,145)>;select()select()}!]^?mul(204,865)$mul(80,588)-] ;(who()how()*mul(434,798)##)mul(44,74)-mul(520,141)/?(^>+/( who()mul(371,961)#who() ?mul(254,744)-who()*mul(499,955)how()from() >?mul(553,995)<mul(12;select()},;/!(]when()}mul(490,481)><when()&]mul(225,864)from()mul(262,958)~*;?*what();;do()select()%}mul(225,558)+how()>>)&-select()>mul(625,699)-,;mul(488,493)?mul(315,42)from()/,:$,,*when()mul(887,391)(#%{ mul(613,520)/'?where()<mul(608,359)@/how()@}mul(224,137:/]!?{#mul(766,604))}% {;!&[do()<'who())select()+:/>why()mul(709,981)~' how())[mul(460,872) when()%@/?mul(319,730)*) #mul(819,598):; #%mul(186,374)%+{mul(252,553)+}*;]:select()[how()mul(54,460)('mul(767,516)what()!&@[- /~-mul(420,721)where(167,817)}mul(393,198)/what()~^:from()'mul(776,849)<{:/ {?:what()select()mul(503,698)(>~when()what()[,mul(325,23)mul(650,340))mul(206,125)*<when(){~),#when():mul(663,717)!:from(311,319)~-^~from(300,345)mul(817,238) ~*]where()(]&&mul(666,75)( from()what()[^select()(!do()^when()>~%^[&how()<mul(16,177)#,mul(337,520)why(377,223)mul(243,60)^[mul(929,385)[;select()when()?/:?where()who()mul(144,182)<+(<@;select()#;mul(53,296)mul(430,787){mul(59,615)select()why(),mul(167,41)mul(679,808)who()?from(711,550)]?mul(60,619)select()!@why()!}don't(),;select() '@$'^mul(552,246)who()how();?!mul(152,694)(@( 'select()'what():mul(91,836)]*/&mul(545,997)<how()(select()),;what()~mul(448,450);*}mul(477,760) %do()@how(203,89)[mul(252,511)><;]/^when()%@(mul(793,635)-*~%how()how()where()<mul(611,932)+select()mul(50,375)]who(371,188)'why(990,8)mul(938,757);[from()how()mul(530,20)*what()<-):[*when()-mul(298,502)[%select()& (*from()how()mul(85,261)select()~>:mul(91,355)how()[mul(816,280)who(847,273)mul(456,335)%^}#+[mul(111,198)/^mul(104,459))when()%/]{[;why()!mul(915,477)$where()#>where()why()what()what()))mul(842,405)@^$who(){'mul(84,674){&} mul(146,155)mul(833,727);{/;@what()<when()select()^mul(224,512)how():~~%select()mul(624,262)^)^from()}*&mul(598,8))when()don't()/who()why()^)from()!(%%mul(42,477)-')?%from()mul(403,902)who()^[~})!mul(435,571)from()why()select()who(505,867)}do()how()? ,why()'{where()mul(767,186)>mul(532,66)select()[<mul/[+*mul(220,744)~how()mul(92,404)(%+mul(36,189)from()do()mul(340,87)~select()select()where();)!}?mul(174,947)where(203,500)%:$mul(621!#?what()<+)* mul(52,254)why()?>'-]!who()what()'mul(415,148)~<-!{^mul(14,736)where()do()@who()%@>'<?%,mul(601,388)+[mul(128,458)who();;where()+[)<]%mul(585,532)%$when()!;what():mul(515,714) {]mul(473,405)>mul(935,316)how()[<;where()@why()>)what()mul(476,701)?~select()': ^from(639,569);mul(797&+>(%];@};+#!/usr/bin/perl[*/>mul(36,243)
    \\/select()->)*how(386,454)from()mul(300,315)from()#!select()- @-<;mul(363,667)@!<*#*/(^mul(834,851)$ where()@mul(872{{#>$']&how()mul(198,844)'%&# )~;'mul(99,189)!why()when()select()where();mul(834,111)who()mul(679,451):mul(39,313)%{mul(173,934))';'mul(798,4)&?select()who()[select()-mul(311,962)mul(698,905);/{>)?select()where()?mul(803,359)}*'[when())('don't()/<{{)mul(43,610)select()(why(267,624)!'mul(151,244@how()+!>?+who()-%don't()#%,<{what()}from()mul(146,224)mul(863,863):{>where()'+&mul(882,828) what(324,690)from()mul(774,186),+]}:where(824,437)!how()~when()mul(871,259)~(?/],mul(114,251)who()) ?%/when()mul(840@mul(198,246)/};{mul(500,813)/(,@[why()?mul(565,846),&&,#mul(148where()who()where()),?%~'$mul(189,297)&} ['}?}<mul(890,916)mul(849,76)#]>what(),mul(248,226)how()mul(945,791)']*mul(820,292)[>/]<when()select()^-!mul(768,942)]why()~&)]select()(<why()mul(588,28))>do()}what()@why()$^what()-?mulwhere()mul(143,508)do())<$&$'mul(717,939)where() ?mul~<mul(571,633)mul(240,325)why()/who(881,208)~select(),mul(493,499)-@/+why()(!mul(209,846)-don't()#$when()why()++mul(273,472)}>@mul?$/!@-~mul(271,138)why()-mul(335,285)when()mul(726,957)select()how():select();mul(231,539)-<select()-where()^^~mul(515,33)mul(116,95)}{/?<mul(62,346)(^%select())mul(195,5)what()!,'?don't()*$$*mul(745,961){who()*[,,how(589,383)}from()'mul(309,463)} ]'(when()do();:;+)how() mul(805,851)mul(176,123)when()!:who()mul(311,38) select()?)?@[>$ mul(726,673){}mul(78,339)mul@<:mul(119,156)[how()@from()!!$select()mul(828,590)mul(182,837)from()mul(683,176)mul(892{!% who()+!^!mul(403,141)}(}{&mul(324,188)%how()mul(97,443)do()how() [mul(292,615)mul(32,672)<(>)^?$##mul(552,878)mul(190~[select(31,208)how(488,878),mul(803,157)from()]how()&mul(126,470+(*&mul(684,992)when()^[mul(292,454)<}}& ]%# mul(628,183){where()why()!where()where(637,929)^+]do()<from()^from()>[mul(673,37)mul(26,197)why()^where()where()>who()when()[-mul(732,481)<why()''(?mul(739,60)mul(735 ~why(305,335)/don't()?:<*,,how()mul(934,463)what()+~&{mul(192,421)when(753,498)$>%/how()~:mul(920,980)'>@)select()[when()mul(832,2)^select()>,*!@where()#(mul(806,526),#}'-/~how()mul(373,273)%why()/mul(948,279)  %/$mul(673,973){>?&how()?[(mul(93,63) [select()mul(9,899)]mul(348,281)who()mul(703,726)who()%}/!)select():*%mul(638,192):~who()mul(344,465)~+%where()mul(505,323)[); <[(don't()from(930,874)where()^' %where()mul(860,614)mul(970,547)where()mul(856,910)$^}who()/{-<]mul(685,705-[{when():why()why()%^>mul(133,409)where())-mul(494,959)-where())(mul(391,829) why()['-from(),:mul(773,546)^mul(209,866)'>!who()/~ *[mul(96,420):!where()when()>@]mul(963,114) mul(19,791)<>[what()/[(}mul(514,90)!who())from(){why()mul(421,374)']{$}?(when(){mul(290,986)mul(761,102)[where()*what(72,427)&do()@?'where()mul(14,42)!{select(286,515)#why()mul(229,685)who(){&[mul(395,229)where(254,749)]where()~mul(180,611)-[don't()select()<'where()where()*/mul(854,240)how(565,94)(@}@#select()!mul(369,579)(-when()-from()*mul(878,354)from()why()%%>select(315,631)!(mul(44,680)''&~mul(755,993)}?< (mul(164,540)&?(;mul(49,686)how()[mul(892%*why(),-mul(499,202)mul(802,67)@why()how()?>*]-$mul(754,607)why()how()'from()how()<how()who()mul(530,571)
    \\why()mul(894,702)*how()?-mul(931,273)[-/from()(; mul(334,459)mul(988,980)[<why()<mul(845,3)why(),where(57,517)how()where()]{,&mul(159,943),:~what()mul(788,895)mul(431,498)&({:when()?!&>}mul(316,411),where()mul(160,695)#from()who()!](^'!mul(72,797)^^how();where())mul(117,420)mul(222,643)what()+*&,^#-who();mul(582,187)^'(what()/mul(762,337)why()[)%:&^'mul(200,220)#<why(4,955)[how()?,:mul(421,283) :^select() !mul(830,148)?how()*!mul(345,995)+{:mul(189,815)'$:#],:why()mul(449,429)when()mul(862,683)'mul(654,799);mul(608,309)mul(844,424):>what()[~(mul(869,922)-~mul(174,220)[)#how()+when()>'mul(336,741){[^]+!{^]?mul(72,869)why()mul(968,607)([~!-[/how()%when()mul(315,514)/*<#/?mul(287,442)< ;)*:~?why()mul(932,398); mul(339,6)what()what()%'!$-mul(541,481)*:%mul(278,722) '/mul(221,745)when()?why()'how()&select()mul(863,756)why())?mul(853,974)'~#*when()mul[^},mul(426,383);mul(363,22)+mul(48,755)'[?!+,}select()+mul(450,379) from()where()@![-#mul(504,685)what()!({how()/where()select()select(75,232)(mul(57,262)select()(mul(101,248)$~what()select()who() /!mul(963,497)*where()!~%how()>where()%select(185,346)mul(656,42)@?)$-mul(685,559)how(){^how()from()):]+mul(20,248)'-don't()mul(795,333)^}when();?!)#~+mul(391,920)select()why(998,378)when()((why()why()mul(270,352)[-&>/:why()~,mul(152,35):select()select()select(781,981)mul(262,158)@&%{mul(34,360)where()from(),what()mul(187what()mul(729,608)%mul(339,440)*<why()~+mul(675,500)]{from()(who()mul(613,606)!mul(621,365){,/where()when()mul(946,473)when()@#^@]~mul(364,628),mul(13,896)who()mul(160,959)who()don't()~><how()<:select()/(mul(72,995)$@{mul(664,129)%#select()^]/#where()mul(45,384)where()why():select()how()mul(187,461): how()~>*'!!mul(979,318)''+mul(836,175),<^:(!%{:~mul(829,318)*&?-/[/why()why()~do()~select();(-[mul(558,465)from()who()who()//)-mul(339,776)';}what()from(837,48)how()don't()]<why()^;mul(640,857)why():mul(619,391))where(){?who()(why()from()>where()mul(154,719)<?!@mul(218,636)mul(130,979#select()%!mul(618,663)mul(530,889)(mul(67,223)!-{$^>#{{mul(308,919)@~*)mul(354,252)select(481,19)who()from(447,581)&%what()>when()mul(261,491)mul(148,283)select()mul(891,12)!$mul(705,454)<$)how()~mul(569,693why()mul(66,218)<^mul(31,825):*what()why()[;#mul(436,424)%how()>[how(727,535)%!do(),~~/mul(269,856)mul(857,460)>%?]/mul(792,512)&},*#mul(744,858);+[#!)(%-?mul(330,415)do()where()mul(527,833):where()+>-!mul(223,83)#![ how()!/mul(549,333),mul(595,422)~mul(980,75)<%^<^~%$mul(403,977)who()![<~what()])/from()mul(862,856)#^&?select()>  &+mul^)<^-{when()~{%mul(245,795))who())mul(998,777):@%how()mul(855,136where()<(]@what()#:how()>!mul(385,193)~-what()^why(){mul(844,123)what()#)&?mul(268,192)~&;how()when()>([)mul(316,777)mul(517,887)>(+,what(){mul(488,952)^?- mul(910,954)!%%mul(489,386)mul(665,70)%~when(620,413)/-{%mul(359-?+where()select()~mul(280,485)select()^:mul(821,371)who()}, why()<?[}mul(798,25)
    \\{select(){+-]:&when()mul(745,698)!&}:<from()}mul(139,392)where()>{what(698,375)##^#?}mul(49,637)where()/+[^@)$?mul(60,27)-:>why()#;$do()what(),&@-mul(197,825)when(177,701)-[@^why()#mul(113,357)#}why()/mul(779,647)/why()%from()mul(475,558)@?}who()what()~#; @mul(449,48)why();)[]#,>mul(909,644)%~>don't():##[:mul(203,56)[who()mul(5,956)~select()mul(542,429)!'mul(334,58)@:']/:^mul(315,673)mul(266,818)where():why()'do()-}why()?>when()''$#mul(356,845): mul(75,208)*'*mul(197,931)from()>)&#+]mul(773,636)why()where()^}where()mul(895,801)from()(/^who()}why()[~don't()>!,why():,@where()}mul(630,443):~}$-':<;mul(200,170'[where()how()+};where()mul(79,420)[+@#/select()!;mul(976,90)},}[~>mul(718,701)select()who(46,555)where()^@]?mul(709,96)why()when()'!(where()[mul(918,71)select()?~,how()*{mul(791,355)(mul;,;[mul(909,333)^~mul(152,45)why(935,832)@$;&}mul(202,733)@mul(631,457)$^:+from()select()+'select()mul(35,298)%,~:; mul(459,590)[how()*!]/!select()don't()mul(127,226)when()[why()mul(921;!& what()+>@&what()where()mul(926,614)mul}{'(mul(74,647)&from()?+*~*;*mul(42,7)how();-mul(991,55)where()}-:who()]why()&mul(803,14)^'<what()#mul(268,732)#when()>how(301,29)select()mul(904,721)how()+from(209,448)}-:& ,(mul(786,950)when()}from()how();@-how()mul(44,272):>mul(780,770)mul(983,607)}mul(537,296)why(){mul(183,498)<mul(593,927)select()^*{@@-do()+/<['{when()mul(643,615)<[??who()mul(55,297)(?(mul(685,900):)who()when()%what()( ,~mul(684,595)why()who()]<where(939,153)from()?from(696,279)^mul(67,792)+:%$what()/mul(743,464)%do()<how(597,533)@mul(744,439):when()when()where()when()^}mul(241,329)+!who()when()^(+$where()mul(468,885)mul(172,30)^^]:<mul(314,256)]mul(185,690)> $mul(447,332)mul(857,945)&mul(211,6)-]%&<?}why()when()when(351,438)mul(966,579)when(365,315)mul(801,792)when()how()%#mul(275,938) ,)%]{from()mul(508,757)mul(303,112))}when() - )/mul(586,61)-when()-why()-{mul(186,812)*,mul(737,699);:#don't()+!, +mul(361,96)mul(977,760)/!&mul(187,236)!!^:@}%~[{mul(816,160)where(392,83)&mul(88,203)[ ? when()<$+>mul(217,55)]where()*select()how():#$mul(610,760)]when()!%[$'mul(812,579)#select()*+how() %mul(650,756)&!,don't()&mul(467,791)<$]?where()mul(708,303)@mul(664,527)[?'mul(459,591)*}%who())select()~:mul(237,606)how()>mul(133,311)mul(554,252)?when(493,438)'^{(do()<{ mul(286,334)(-;how()where()how();;mul(388,580)<select()[how(){+{#who()mul(235,709)who(267,722){when();select()mul(917,863);how())>>select()from()mul(120,119)?*&select()who()mul(375,829)why()+%from()why(),*}+mul(378,224)#mul(330,898)mul(551,592)why()>don't()++'$}mul(660,503)+/ who()why():*mul(978,917)+;[select()-( }mul(848,970)mul(48,20)/$,mul(942,625)+mul(220,813)who()select()~&mul(916,14):!!from(),how()~where()what(647,454)mul(31,90)]/&)<}mul(689,827)@[mul(626,927)'&;))![where()mul(608,109)*mul(317,649)why()'mul(547,176)-who()]@#:mul(465,974)&;[mul(801,152)%[~$who()(mul(229,210)}({)who()how()^where(480,366)^/mul(218,42)&*select(905,451)when()]who()):from()how()do()&what()@from()@select()&<mul(448,624)where()<who(), -*
;

const day4input =
    \\SAXXAXMMSSSSSXMXMAMXSXMAMAMXXXAMXAXXMXMAXSXMMAMXXXMSSSSSMSSSSSSMSSMMXSAMMMMXSAMXSMMMSASASMXMASMMXSSMXSAMXSAMXMMXXXAMAMXMASXSSMSASXMXSMMMMXXM
    \\MASXMSMAXAAAMMMAMAMSAMSXSAMSMSMMXMSSMMSAAXASAMSAMXAAAMAMXAASAASAAAASMMASMAAAMXSXAMAASXSASXMSXMASAXAAAAASAXAXAXMMSXMASMMMMSAMXAMMXASXXAAMMMSM
    \\MAMAAAMXMMMMMAMAXASAMXAAMXAXAAXMAMXAAAMMXMAMAXSAAAMMSMAMMMXMMMMMMMMMAAAMMMMSSXXAMMMMXMMAMXAXASMMMSMMMSSMXSMSMSMAAAMAMAAMAMXMMXMASMMMSSMMSAAX
    \\MXSMMMSASXSSSSXSXXMAXMMSMMSMSMSMMSSSMMXASMSMXMSXSXXMAXAXXMXSXSASMSMSSMSSXSAMMMMSXSXXXAMXMAXSMMAAAAAAXXAMMAXAAAMMMXMAMSMMAMMMSXMAAAAAMAAAMSSS
    \\SMMMAXSXSAAAXAAXXXSAMXAAAXMXAAAASAMXAXMASAXASXMAXXMMMSXSXMSMASAXAAAXMAAXXMASAAMAXAAAASMSMSMSASXMSMSMMSAMMXXMMMSMXAMMXXXSASAAAAMSSSMSSMMMAAXA
    \\XAAXXASASMSMMMMMAXASAMXSAMXSMMSXMASMMMMMMXMMAASXMASMXSAAASAMAMMSSMSMMMMSMMXMXXMMMMMMMMAAAXAXMSXAAXAMASMMSMMSAAXXSXXSASAXAMMMMSMMAMAAAMMXMMSM
    \\SSMXSAMAMXXAMXAMMMAXXXAXXAMXXMMMXSMMMAAAMMSSSMMAMAMSAMMSMSAAXSAAAMXXXMAXAMXSSSMXXXAAXMSMSMMMXSMMMSXMAXAAAMASMSSXMAXMAMMMSMMMXXMMAMMSMMSAAXAX
    \\XAAMMMMXMAXAMSSSXMSMMMSMMSAMXMAMMXAXMXMXSAAAAASAMXXMXMXAXSXMAMMSSMMASMMXMMAXAASXXMMSMAXXXMXAXXAMXMMMSSMXMMAXMXXAMMMMMMSAMAMSSSXSXSAAAASXSSMS
    \\MMMMASMSMMSMMSMXMAXAXAMAAMAMXSXSAMMMSMMSMMSSMMXAXSMSMXSMXMAMMXAMXAXMAXAASXMMSMMSAAAAXSXSXAXSMSXMASAMXAAASMSSMMSMASXAAAMASXMAAAASAMMSMMSAMAXS
    \\MSSSMSAAXAAMMXXXXXSMMSSMMSAMAMAMXMAAAAXXAAAXASXSMSXMAXXXXXAMXMSSSXMASMSMSASAMAASMMXSXMAMAMMXAMXSXMSMMMMMSAAAMAXXAAMMSSMXMAMMSMSMAMMAMXMASMMS
    \\XAAAAMMMMSSSMMMSMMAMMAXXXXXMAXAMMSMSSSMSMMSMXMAMASXXXMAMMSXMAMXAMMSXMAXASAMASMMSXMXXAMXMAXAXMSMAMXXMAXSMMMMMMSSMSSXXAXXMAMMAMXMMAMXAXXSMMMAX
    \\MMMMMMAXMAMXMASAXSASMSSXSAMXSSMXAAMAAXMAXMAMSMMMMMASXMXXXAMXASMAMXSASMMMMMMMMAMXMSAMAMSSXSMMMAMXSASASMSAXXXXAXXMAAMAASASXSMXXAMMSSSXSASXMASM
    \\XAAMMSMSSSXMMXMXMSASAAXMASMXMAAMSMMSSSSSMMMXXAXSAMXMXXAMMASMMMMMMXMAMAMXAMAMSAMMAMXSAMAMASAMSMMAMMSAMASMMMXMXMMSMSMMSAMAAMMSSMSAXAAASMMAAAXA
    \\MSXSAAAAXAAMSSMMMMMMMMMSMMSAMMMMXAXMAMAAXXMASMMMSMSMXMXSMAMAAXMASAMAMAMSASAMMAMAMXASASMMAMAXAXMXSXMAMXMXAAXMMXAAXAXXAAMMSMAAAAMMSMMMMASMMMAS
    \\XAAMXMSMMSMMAAAASAMAXMASAASXSXXMSMMMAMSMMAMXXXAMXXAMXMAMMSSSMMSAXMMAXAXXXXMSMAXSXMXMMMXMAMMMASMSMXXSAMXXMSAMSASXSMSSSXMAXMMSXMMAXXXXMAMSAMXX
    \\MMSMMMAMAAAXSSMMXASMSMAXMMSMMMMMAAAXSXMAXMMAMSSMSSSSSMASXMAXMXMXSAXSSXSAAMXAMMMXASASXSSSMSAXAAXAMAMMAXMASXXXAAXAAAAXAMMMSXMMXAMSSMSMSMMSMMSS
    \\XAAMXSAMSSMMMMAMSMMXAMXSXAXAAAASXSMXMASMMAXAMAMXXAAAXXMMAMSMSAXMAMAXAMMMMXSASMAXMSASAAXAXSXMMSSSSXXSXMMMAMSMMSMSMMMSMXSAXMAXMMSMAAAXXAAMAMXX
    \\XSXSAMAMMMAMXAAMAMMSMSXAMMXSMMMSAXMASMMMSMMSMASMMMMMMMMSSMMASAMXMASMAMXAAXMAMMSMAMAMMMMSMSMSMAAMXMXAXXAXASAAXXAMASAXXAMASMMSAXAMMMMXMMMSSMMX
    \\MMAMXSMSASMSMSMSXSASXMAMXMAXMXMMMMMAMAAXAXAAMAMAMSMSMSMAAXMMMMXAXAXSAMSMSXMXMAXMXMXMASXMAMAAMMSMMAMSMSMSMSASXMAMAMMSMMMAMAXAXSMXSASXSMXMAAXX
    \\XMAMAAXSASAMAAXXMMMSAXAXAMXSAASAMXMMSSMSXSSXSSMSMAAMAAMSMMXSAASMMSMMXAXMAMSMMMSMMMMMAMMMAMSMSXXXAXAAAAXAAXXXMXMMXSMXMSMMSXMMXXMASXSAXMAMSMMA
    \\SXSSMSXMAMMMSMSAMXASMMMSMMAMMMSASXSAAAAMXMXAMXXXSMMMSMXAMAMMMMAMXMASMMXMSMMASAMXAAAMASMSMMXMMXMMSMSMSMSMSMSMSAMXMMMMXAAXXAXXSASASXMAMSAMASXM
    \\SAMXMMMMMMXMXXSXAXMXMAMAAAXMAXSAMAMMSMMMASXXXXXMASXXAMSSXSAXAMMXMXMMAXSMXAXXMASXSSSSMMMMMMSASAXAAMAXAAAXAXMAMMSXSASXSSSMXMAXSAMASMMMMXASASXS
    \\MXMASAAAAMAMMMMSSXMAXAXSSMSMMMMXMAMXMAXSMSXMXMASAMXSMXAMXMASMSMAXSXSSMSAXSMMSXMMAMAMAAAAAASAAAASASMSMSMMMSMSMAAAMASAXAAAAMMMMMMMMMAAXSMMASAS
    \\SASXMMSSMMASASAAMAMAMXMAAMAAMAAMSASAMSXSXSASXSAMASMMXMAXXXAAMAMMXSAAAAMAAXAASAMMAMXMSSSMSAMXMXMMAMXAMAXXXMAMMMMSMMMMMSMSXSAXAAMAAMSXXAXMAMMM
    \\SASXSAMXMSAXAMAXSSMAXSAMXSSSMMXMSASXSMASASAMMMXSSSMSAXMAMMXMSXSMAMMMMXMMMMAMSAMSSXSAMAXAMXMMSMXXMAXXMAXXMXMXXMAXAAAXAXXMXSASXSSSMXAMXSMMASMM
    \\MAMAMASAMXAXSMSMAAXSXXAXAAXAAXSAMXMMAMXMAMAMASAMXMAMSSMSMAAXSASMAMAXXAXXMASMSAMXAAMAMAMXMAAXMAMSASXSMSSMMAXMXMSSSMSMXSAMAMAXAAMXMSAMAMXSAXAX
    \\MMMSMAMASMMMXAXMXMMMMSMMASXSMMSMMSMSXMASAMAMSMASXMAMMMAAASXSMAMMMSASMMSXXXXAXAXMMMMMMMSSSMSMMMMSAMAAXAAASXSMAAXAAAMAAXAAAMMMMMMAMSAMXSAXMSSM
    \\XXAXMXMAMAXMMMMMAMXXAAASAXAAXXXMASXMXSASMSSXMXXMAXMMXMSMXAMXMAMAXAMAXSAMMSMXSMMSMSAAAXAAAMXAMAMSAMXMMSSXMAAXMSSSMMMMMXSSSXSAXAXAXXAMAMMMMAMA
    \\SMSSMSASMMMXAXAXAMAMSSXMMMSMMMXMASASXMASAAMAMSMXMMXSSMAMMAMSSMSXMAMSXMAMAAMAMXAAXMXSXXMSMMSMSAXSAMXMAXAMMMMMMXAAXXXAMAAAAASMSMSMMSAMXXAAMASX
    \\AXXAAAMAAAMSMSMSMSMMAMXAAMAAXMXMSSMMXMAMMMSXMAASXSAAASAXSAMXAMXMMXMMASAMSSMXSMMSXSAXAMMMMXAASMMXXMAMXXMAAXASMMXMMSMAASMMMMMXAAAAXMAMSXSXSXSX
    \\MXMMMMXSSMMAXAMAMAMMMSXSAXSSMMAXAXXXXMMXSAMAMXSAAMMSMMMMSASXXMAMXSASAMAMAAXXXAMAAMAMXMAAXMMXMSAMXSSXSASXSAAAXMMSAXMSMXAASXXSMSSSXXMMMAXMMXSA
    \\XXMAMXXXMASMMMMASASMXXMASMXAASMSMMSMMMSMMMSMMMMMXMXAXXMAMMMMSMMMASAMMMMMMSMXMMMMSMAMASMSMXXMAMMAXAAASAMAAMSMAMXMAXXXMSMMMMAMXAMMMSMAMAMAMAMM
    \\MMSAMXXMMMAAASMMSASAMXMAMXXXMMAAXAAAAAAXMAXMAAAXMSXSMMMSSMSAMASMAMSMAASAMAXAAASXMMASXSXAAMXSMSASAMMMMMMXMMMMMXAMAMSXMASAAAAAMAXAAAMXMAMAMASX
    \\XASMSMSMASMXMXAXMAMAMMSMSASMSMSMMSSMMSMSMAXSMMSMAXMAAAAXXMAXMAMMAMAMSMSASASMSMSASXXMASAMSSMSASMAAXMXAAXAMXXASAMMAMMASAXSSSXSMSSMMSSMSSSMSASX
    \\MXSAAAASMSMXXMAMSMSSMAAAMAMAAXMAMAXAXMASMMXSAAXAMMMSSMSMMXSAMAXXAXMXMASAMXSAXMXAMXSMMMSMAXAMAMXMAMXSMSXSSMMASAMSXMSAMMXMXMAXAMXMAAAXMAAXMASM
    \\XMXMMSMSXMAASXMMSMAMMSMSMSMSMMMAMASMMMSMAMAXMMMSAMAAXMXMSAMASASXSSXMSAMXMASAMSMAMAXAMAXMXMSMAMMXMSXMAMXMAXXAMAMXMAAAXMAXAMXMAMAMMMMMMMMMSASA
    \\XXAMXMMXMMMMXAAAXMAMMXAAAAAAXAMAMXSXXXAMAMMSSMAXAMSSMSAMMASXMAMAXAAXMSSXAAMAAXSXMMSAMSSSSMAMAXXASMAMAMASAMMSSXMAMXXMMSMSSMMMMMSSSXSAAMXXMASM
    \\MMXSAMXAMXAAXXMMSSSSMMMMSMSMSSXMSMSASXMSXSAAXMASAMXAXSAMSAMXMSMSMMXMAAXAMXSMMMMXAMMXMAXMASMSSSXMXXAMAXXMXMAMMAMXSMXAXXMAMXAAASXAAXSSMMAXMXMX
    \\AAXSASMMSSMSXSAAAMMAMSSMXXMMAMAAAAXASAXAXMMSMXMAMSSSMSMMMMSAXAAMAXAMMMSXAMXXAAMSSMSAMMSSMMMAAAMSMSSSXXXAXMXXXAMSXAMSASMSSXSMSMMMMMXAMSMSMSAS
    \\MSXMASXMAAMAASAMMMXAMXAMSMMMASMMMSMAMMMSMMAXMASAMXAAAXXAXMMMMMSMXMXXAXAMXMASXSAAAASAMXMAASMMMMMAAMAXMASMMMMSMMSXASAMAXXMAMXSMMSSSMSMMAAAAMAM
    \\SMXMAMAMSSMMMMXMASXSSSMMASXMASAMXXAMAXAAXMAMXAMMMMAMMMSSSMMSAMMMSMMSXSMAAMXSAMMMMMMAMMSSMMAMXXSMSMAMSASAAAAAAXAXMXAMMMMMXXMASAAAAASXXMSMMMAM
    \\AAAMASXMAAAXSAMMXMAXAAMSASXMASAMSMXMXMXSSMSSMXSAAASAXXAAAAASASMAAAXSASASXSMMXMASAMSAMXAAMSAMXXXAXMAXMAXXMMXSSMMMXSAMXAXXXXMMMMMMMMMMAMAXASAS
    \\MXMSAXAMSSMMXAMXSMSMMMMMXSAMXSXMASAMXSAXAMAAMASMMSXMXMMSMMMSMMMXMMMMAMAMASAMASXSMMMASMSSMSASXMMMMMSSMSMSMSXXMASAMXAMSSSMMSMAAXXXSAMAMSASXSAS
    \\XMXMMMXMMAMXMXMAXAXASMMMASAMAMASMSXSAMXSXMSSMMSSMXXMAMAAASASAXMASMMMAMAMXMAMASAMXAMSMMAMASAMXAAMAXMAAXMAAMMMMAMMSXMMXXAMXAMMMMXMMAMSAMXMXMMM
    \\MMAASXSSSMMAASMMMSMAMXAMASAMXSAMXMMMMMXMAXAAAAMAXMASXSASMMASAMMAXAASASASASXMXMMMMSSMASMMMMMMSSMSMSSMMMSMSMAAMXSAMMAXSSMMSMSASMSMSAMXMXMMXSAM
    \\ASMSMAMAMXMXSXAAAAMAMXXMASAMXMASAMASMXSSSMSSMMSAMSMMMAMXAMMMMMMSMSMSASMSMSXSAMXMAMAXAMXMXASAMXAAAMXXXAAXAMSSSXSAXSAMMAMAAMSASAAAMXMXXXMAAMAS
    \\MXMAXXMAMMXXXMSMSXSASXSMAMAMAMXXAXSAMXMAAXMAAAMAXAAAMMASMMSAXXXAAMAMXXXMAMMAMSMSMSAMXXAASXSXMASMMSMMMSSXMAXAXMMMMMAXSAMSSMMAMMMMMMSAMXMMXSAM
    \\MAMAAMSSSMXSXAXMXMMAMAMMSMSMSXMSAMAMSMMMMMSXMMSXSSSMSAMXXASXXXAMXMXMMAMXMSAAXAAAXMAMXMMMSAMMSAMXXAAAXMMMXMMMMXAAAXMMSAMAMASMMMMSSSMAAMSAMXAA
    \\MAMXSAAAAXASMXMASXSSMAMAXAAAXAAMAMXXMAXASASAMAXAMXMASMXSMMXXMXMXMXXSSMXAXAXASMMMMSAMXMMASAAAMAXMSSSMSAMASXAAAMSXSMSMSAMXSAMXAAAXMASXMASMXSXM
    \\XAXSMMSSSMAMMMMMMMAXMXXAXMMMMSXSAMSMSSMAMASMMSSSMSMAMXAXAAMSSSMAMXMAXMSSSMAXMXSXMSMSSSMASXMASMMMAAAAXXMASMSMXXMAXAAASXMAMMMSSMSMSMMMMAXAASAS
    \\MSSXAAMAMMSMSAAAAMMMMSMMXSAXMAXXASXMAXMXMAMXXAAXXXMMSMMSMMSAAXSXMAMAXMAMAXMXMASAMXAAAAMAMAXMAMXMASMMMSMXSXMASASMSSMXMMMMSMMAMAAAXXAXMAXMXMAM
    \\XXAMMMSAXXAASMSXSMXMAAAAAXMXSMMXXXAXAMMXMASXMMSMSSSMAAAAXXMMSMMMSXSMSMASXXXMMMSXMSMMSMMAMXMMASMMAXXAAXAAMAAMAAAXXASXMSMAAMMAMSMSSSSSSSXMMMSM
    \\XXAMXAMMSMMXMMXXXMAMXSSMSXSAMASASXXMSMMASASASXXAAAASXMMXMSAMXAAXXXAXXMAMAXMASAMAXXXXAASXSAAXAAXMASXMSSMMSAMAMSMMSAMXMAMMSXMAMXXMAAMMAMASXAAA
    \\SMMMXMMASXMXAASMMAMSAMXMAAMASAMMAMXXXASASASAMXMMMSMMXASAMSAMSSMMMSMASXSSMAMAMASXMMSSMXMASXSMSMXMASAAAMAAXASXMAMAMXMXSMSXAAMSSMASMMMMASMMMSSM
    \\XAAXSAMASMMSMMSASAMMASXMMSMXMMMXAMMMSXMASXMAMXAXAXMXSSMAXSAMXXAAAAMMXAMXAAMAMMMMASAMXAMMMMMAAXXMASMMMSMMXMMMXAMSAMXXMXMMSSMAMMAMSXXMAMAXXAXX
    \\MXMXMAMASAAXAXSXMASXASAMXMMSAMXSAMAAAXSAMXSSMXSMMSMAMMSSMMXXXSSSMXSSMSMASMSSXSASXMASMMXSAAMSMXMMXMXMASMMASAMMXMXXSXMSAXMAMXMAASAMXXMMSMMMMMA
    \\SSSMSSMMSMMXMMMASXMMMXMXAAMAXSASASMXSXMAXMAXMAMASXMASAAXAMSMMMAXAAXAAXAXMAXMASASASMMMAAMMXMXXASMXMXMASASASAMXMASMSAAMMSMXXAXXMAMAMXXAAMAAXAS
    \\XAAAAAAAMASXAAXXAMXAAAXSMSAMSMASAMAAXASMSSMMXASXMAXAMMMSXMAAASAMMXMMMMMMMSMMAMAMMMXAXMMSSSSMMMMAASASAMXMASAASMMSAMMMMSAMXSSSSXSXMXSMSXSSSSMA
    \\MSMMSMMMXAMMSSXMSSSSSMXAXAMXSMAMMMMMXAMXAMAMMXSXSMMMXSAMXSSSMMASXMXASASAAAAXXMXSASMMMSAXMAMXAAMSMMAMMSSMMMXMSAAMXMXSMSASAMMAXXMAMXAAAAMXMAMM
    \\XMAMXASAMSSMAXASAMXAAXSAMMSAMMSXXSSSSSMMXSAMSMMAAAAXAMAMXXAXASAMAMSASASMSMSXXXMSASASAMMSMMMMMAMAXMMMSAMXAAAXSMMSAMXSASAMXMMSMSSSMAMMMMMASAMX
    \\MSAMXXMAXXAMASXMASMMMMMAAXMXSAXSMSAMAAAXAMASXAMSMXAMMSAMXMAXXMAXAMMXMAMMMAMMMAAMXMAMSMXAAXAAAXSAMXAMMMSMMMMMXXAXASAMMMXMXMAMMAAAXAXXMASAMXSM
    \\ASMMSXSXMSMMASASXMXAMXSMMXXAMXSAMMAMSMMMSSMMMSMXXXXMXSASXMASMSSMXSAMMMSXMAMASXXSAMXMXXSSSMMSXMAMXSMMSMAMSSSSSMXSAMASXMMSMMASMMMMMMXMSXXAXXMX
    \\MXSAXMASAXXMMSAMMMXSXMXAMXMMSSMMMSSMAASAXAAMAMXXXSAMXSXXMASXAAXAXMMMAASAMXSXXAASXMMXMXMAMMMMASAMMASAXXAMAAXSAAAMMMMSAMSAXMAXXXAMASAMXMSMSMSM
    \\SAMXMSAMSAMXMMXMASMMMMSXMASXSXMXMAMSMSMMSSMSSMMMMMASAMXMXMAAMMMXMAASMMSASAMXMMMMAMAASMMAMAASXMAXSAMMSSSSMMMSMMAXAAMXAXMAMSXSMSXSASASAAAAAAAM
    \\MMMMXMAMMMAXXSMXSAMXAAMASASMMAASMSXSMAMMAMXAAAAXAMMXAMAMAMSMSMXSMSMSAASAMAMAMAXMASXMMAMXMXMSAMAMMASXMAAXXXMXMMSMSSMSAMXSMMASAAAMXMMMXSMSMMXS
    \\XAAMXSAMXXSSMAAMMXMMSMSMMMSAMXMXAMAMMMMMAMMSSMMSSSMXSAAXAXAAXAAAMXXSMMXXMAMAXXSSMSASXMMMSMMSXMAMXMAMMMMMMXAAXAAAMAMXAMAMAXAMMMMMASXMMAMXXMAS
    \\SSXSASAMMAMAAMSASASAXXAAAMSAMXMMXMAMXXSSSMAMAMAAAAMSASMSXSMSMMMSSMASXSSMSSSSSMAAASAMSXAAAAXSXSSSXMAXXXMAXMSMMMSMMAMSXMASAMXXXAAMAMAXMAXAAMAM
    \\XXAMXSSMSAXAMXXAXAMAMSSSMMMASXMAASXSAAXAXMXMAMMXSAMMAXMAMXAMAXAMAMAMMAAAAAAAAMSMMMMMSMMMSSMMAMMAMMSSXMSSXMASMAMASXMMXMXSMMMXSMSMSXMMSXMSSMSS
    \\MMXXMXMXSASMMMMSMSMAMXAMXAXAXAMSMSASMXMSMMSMASXXMMAMXMXMASXSAMXSAMASASMMMXMSMMAAMXMXMASAMMAMAMXXAAXXMMAAASASMASMMAAMSAMXAASXMAXXMASASAAMMAMX
    \\AXAMMXMMMAMXAAAXMASXSXSXSMSMSAMXMMAMXSAXAMAMASMMMMXMASMMAMMMMMMMASASMMAAAAMMMXXSXAAXSAMAXSAMXSXSMSXSAMMMMMAMMMXAXMMMMASMXMXAMAMASMMASMMMMAMS
    \\SSMMSAMAXMAMXMMMSASXMAXAAAAASXMMMMAMXMASMMXMASMAMAXSAMAMAMMAAAXXXMMXASMMMXSAMXMMXMSMMASMMXASXXAXAAASXSSSSMSMMMSMMMSASMMMXSXMMXSAMXMAMAAMXSSS
    \\XAAASAMAXXASMMSAMMXAMAMSMMMXMMMAXSXSXSAMXAMMMSMSMSMMASMSMSSSSSSXMASMMMAMXXMAMMSAMMAXSMMMAMSMMMXMXMMMAXAAAAAAAMAMXXMASAAXASAMAXMASMMXSMMSAMAX
    \\SMMMSXMASMMSAAMXMSSMMAXAMAXAAAXMXMMMMMASAASXASMMXMASAMAMMAMXXXAASMMAXSAMMXSSMXMAMXAXXMMMAMXAMXMMXXMMMMXMMSMSMSASAMMSMMMMASMMXXMXXAMAMMAXXMAM
    \\MAMMMMMASAASMMMSAXAMMMSSSSSSSMSMSXAXMSMMMSAMXSASASXMASXMMXSXSMSMMASMMMMSXASAXXSSMMSXMASMMXMAMXAAAMASXMMXXXMXXMMMAAXAAAXMAXXAMMMMMSMASAMXSMSM
    \\MAMAAXMAMMMMAMAMXMXMAXMMAAAAAAAASXMMMAMXXXMAXSAMXMMXMAMXAASXMAAMSASXAXASMMMMAXMAAXAASAMASMSSMSSSMSAMAXMASAMSXMAXXSSMSMXMMSMMSAAAAAMAMMMXSAAS
    \\XSSSSMSSMSAXAMXSSMSSMSAMMMMSMMMSMAMSSSSSMMXSAMXMXXXMXMSMMXSAMSMMMASMMMMSASAXMSAMXMMMMASAMXAAAAAAAMASMSMMMAXAASAMMMAAAXSMMAAASMSMXXSAAXMAMSMS
    \\AXAMXAAAASXSMXXMAXAAMSAMXXXXXAXXMXMAAMAAAAAMXSMMMMXSAAXAMXSAMXXXMAMAMAMXAMXSXSASMMXSSXMASMSMMMSMMMAMXAAMSMMSMMASXAMXMSSMSMSMMMXXAAMAMXMMXMSX
    \\MMAMAXMMMMAAAASMSMSSMSXMXMSSSSXSSSMMSMSMMMXSAMMAMSASMSMSMMSAMMMXMXSXSASMAMAAAMAMAXMAXXSXMMAXAXAAAXAMSSSMAAMXASXMXMASXXMASAMXXSAMSSSMMAXMASXM
    \\XSXMASMXMMXMMMSAMAMMAMMMMAXAAAASASXMAAXMMMMMMMXAMMASAAMMAMMXSAMMMAMXXAXXAMSMSMASMMMMMXSAXSXSSSSSMMSMMXMMSSMSXMMSMSXMXAMSMAMAXMAXXAAASXMSMSAM
    \\XASMAMAAMXMSAAMXMAMMXMAAASMMMMMMAMMSMXMXAAAAAMMSXMAMXMSSMMMASASAMASMMSMSXXXAXXAMAAXXXASMMMAMXAMAMXMAMMMAMMXMAXMAMMAMSMMMMMMXMSSMMMMMXAAAMSAM
    \\SMAMASMMSMASXSMMSXSAMSSSSXMAAMAMAMAXXXXSSXSSXSAXAMXSSMMMAAMMSAMMSASXAXAXSAMXMSMAMMMSMASXAMASMMMMXMSAMAMSXMASMMSMMSAMASAXASMXXAAXAAAXMXSMXSAM
    \\XXMSASAAXMXMAMAXAAMAXAAMMMMSXSASMXSAMXXMXAMXAMASMMAXMASXXMSAMAMXMASMMMMMMXXAXAMSMSASAMXXXSAMAAAXAXMASMSAASASXASAAMASAMMSXSSSMMSSSSMSAAXMAMXM
    \\AMXMASMMMSASAMXMXSXMMSXMASAMXSASASMSMSAAMXMMSMMMXMXXSAMSXSMASAMSMMMXAAAAXAMASMSAAMAMSAMXMMXXSSMSMXXAMXMXMMASMXMMMSMMMSMSAMMMAMAMMAMSMMMMASAM
    \\XXAMXMAAASASASXMXXXMAMASASAMAMXMXMAMMAMMMXSXAAMMMSMMMMAMMSSMMXXAAAMXMSSMSXSASXMMSMMMMMSXMASMMMASMSMXXMXXXMASAMXAAAXAXAAMXMAMAMAMMAMXAXMXASAS
    \\ASMSMSSMMMASXMAMASAMXMAMASAMMMMMMMMMMAMAXMASXSMAAAAXMMSMAMAMAMXMSMXAMXAMMXMASXXXXAXSAMXAMAMMAXMXAAASXMMMXMAMMMMMMXXASMMMSSSSMSXSSSSSMMSAASAM
    \\MMAAAMXMXMMMMXAMMXMMMMMMASAMXAAMXMAAMAMXSMXMMAMMXSAMXAAMMSAMASMXMAMSXSAAXXMAMMXMMAMMAXSXMMSMSSXMMMMMAAMMAXASAMASAMSAAXSAAXAAXXAAXMXAAAAMXMMM
    \\XMSMMMAXMASAXMXMMXSAMXASXMASXSXSASXSSXSAMXAXMASXAMAAMSMSASXSMSAMXAAXASXMSAMAMMXSAMSSSMSXMSAAXMASXMMSSSMSXSASASASAMASMXMMSMSMMMMMMMSSMMAXSAMX
    \\SAMAMSAMAXSASMSXSAMASMAMXSXMAMASMSAAAASXMSXSMAXMMMSAXAXMASXSMMAASMMMMMMSAXMAMMASASAAXAXAXXMSMSAMAXAMAMAMASXMAMASAMMAXASAXXMXAAAAAXXXSAXMMAMS
    \\XXSAMXAXSAMXMAAXMAMAAMAMMMMMAMAMXSMMMMMAXAXSMSSMMAMXMASASXMMAXAMXMAXAAXXMXMXSMAMXMMXMXSSMSMXAMXSAMXSAMAMMMASXMXSXMXMMXMASAMXSMSSSSMAAMMXSAMA
    \\MMMMMSAMMMSAMMMMXAMXXSASAAAMAMXSASMXSASXMMXMAMAXMASMXMAMMAMSSMMXSSSSSSSXXXSASMSMSXSXMXAXAAMMXMMXXMASXSXSASAMASAMXSMXMASXMAMMXAMXAAMSMXAXMMXM
    \\XXAMXAXXXASXSXMASAXMAXMMXSXMMXXMAXMASMXAAXAMSSMMSXSASMMASXMAMASAMXXAAAMAMXMASAAAMAAAXSAMSMMSXAMASMXMAMASAMASMMASAMMXMASASXMAMSMMMMMAMMSMSMSX
    \\MSSSMMXMMMSASAMXAMXMAXSSMMXSAASMMMMASMSSMMXSXAXAMXXXMASMMMMXSAMASXMMMMMXSAMAMMMSMXMXMMXMMAASXSMMXMAMMSAMMSXMXSAMXSAXMASAMAMXSMXMASMMSAAAAAAX
    \\XAAAMXAMXXMXMASMXMXMMSMAAAAMAMMAASMMSAAXAASXXMMMXMMSSMMAXXAMMMSMMMXAAXMASXSSSSXXMAMAMXSMMMMSAXXMASXSAMASXXXAXXSAMXMXMAMMSMMMMMSSMSAMMMSSMSMM
    \\MMSMMSXSAMSSMMMMSXMASAMXMMSSMXMXMMAMXMASXXSAXMAXAMXMAASMMMMSAXAMAMAXSSMXSAAAAMAMSXMASAMSAAMMXMASASMMMSXMMMMASAASMXSASXSMAAXXAAXAMMMMAMMXXAXA
    \\AXMAMXMAXSAASXAAMAAXSXXXAXMAMMSXXXAMMSMMXMMXMSSSMSAMMMMXMAASXMMSXXMSMXAXMXMMMMMAAXXXMXSAXMXXASXMMMAMXAAXAAXAXMAXXASASAMMSSMMMSSMMASMSSMASMMS
    \\MMXXSAMAMMMSMSMSMSSMMAMSAXMAMMAASMMSXAXMMXAAXXMAASMMSAMASXXSMSXMMMXAMXSMSAXAXASMMSAMXMMMASMXXSXXXXXMMSMMSSMMSAMXMXMAMXXAXAXMAAAAMAXAAAXAMMAM
    \\SAMMSMMASXXXXXMAMAAAMAMAASMMMMMSMAASMMMXAMSSSSMMMMAASXMASMAMXXAAMSMMSAXAXAXSSMSAAMMAMXAXMASMSXMASMSAMXXAXMAMXXMMXSMMMSMMSSMMMSSMSSMSMSMSSXSS
    \\ASAAMASASXMXXMASMSSMMXSMSMAXMAMAMMMMASMMXXAAAAXXMMMMSXMXSMAMMSMMMXASMXSSXSXXAMXMMSMSMSAXSAAMMAMAAXMASMMSSSSMMAMAAXAXAAAAXAAXAAAXXAAAAMAXSAMX
    \\MXSSSXMASASXXSAMXAAAAMXXAMAMMMSSXSAXAMAAXSMMMMSMSXAAXAMMSXXSXXMAMXMMAMXXMAMMAMSXMXAAMAAXMMXXMAMXXMMAAXSXAAMMMAMMXSAMSMSMXSMMMSAMXMMMMMSMXMAS
    \\XMAXMMSXXAXAASMSMSSMMASMSSSMSMAAAMSMSMMSXMASMXSAMXMXSAXAXMSMAMMASAXMMMMMXMSSSMSAAMMMMMSMXXXMXMXSAAMMMSMMMSMAMASAMMXMAAAXMMXXXXXMAXAXAAMASMAS
    \\SMSMMAMMMSMMMMASAMXMASAMXAXAAMMMSXXXAAXXASMMSAMMMMSAXMASMXXXAAXASXSAMXAMAXXAXASMMSMSAXMAXSMSAAASXMMSMAXAMXXMSAMMXMASMSMAASMSAMXSMSSSMMSAXMAS
    \\XAMAMSMSAAASXMAMAMSXMMASMAMSMSXAMAMXXMMMMSAAMXSMMXMASMMMAAMMMSMXXAAXSXMSSSMMMXMAXMASXSMXMAASMMMSAMAAMAXMMMAMXXXXAXMMAXXXXAAXASMAXAAAMAMXSMAS
    \\SXSAMXAMSSSMAMXXMMMAMSAMXMXXXXMASAMSMSAXASMXSAMASASXMMXMSXAXAAXAMSMMMXMAMXAXAXSXMMMMMXMAMMMMAMMMAMSMSSSMSMAMMMMSMXXMASXSAMAMMMXAMSSSMSSMMMAS
    \\AASXXMMMXXAMXMSMSMSAMMXSASAMXXMAXASAAMAMXMAMMMSAMXXXAXMAMXSMXXSMMAAAAAMAMXMAMMAXSAXAXASAXAXXAMSMSMXAAAAASMSSSMAAMASMMAASAXSXMSSMMAAAXMXMXXAM
    \\MMMMMXXSMXMMMXAAAAXMXSASXSXXMMMMMMMMSMXXSMSMAAMMSSSMMMSXMAMXSAAASMSMSXSMSSMMXAAMSSSMSXSASXSSSSXAXASMMMMMMAXAAXMMMAXAAMXMXMXAXAAAAMXMMMAMXMAS
    \\MSAXSAMASAAAXMMSMSMXXMASXMASXSMSAXMAMXXSAMXAMXSAAXXAAAXAMXMAASMMMMXMAXMAAAMSMMMMXAXAAAMAMAAXMAMXMAMAXMAXMMMSMMSSMMSSMSAAAAMSMSXMMSAMASAMAAXA
    \\SMMXMASAMMSMSAXMAMXXXMXMXMAMAAASMSAMXAXAMASAMAMMSXMMMSXSMAMMMMMMMAAMXMMMMSMXAMXXXAMMMSMSMMMMXMASMXMXSXXMAXAMAMAAAMAMXMMSMSAXXMASASMMMSASXSXA
    \\SAMASMMMSAMASMMMAMAMSAAMAMASXMMMXXXMMSMSXMXXMXSMMASXMXAMMAMMAXAAXXMXSAASMXMMSMMMXSAXSXAXSXXXSAMXAASAMASMSMAXAMXMMMAMMXMXAMAXMSAMASXSASAMAMAS
    \\MAMXSXAAMXMAMAASAMAMXASMMSASAAXXXMXSAXAMXMSMSAAAMAMAAXMMSSMSASXXMAAAXXMMMAMXAAAAXXXXXMXMMXMASASXSMSAMXMAXXSSMMSMSSSMSAAMMMAMMMMSAXMAAMXMXXAM
    \\SSMMMMMMSMMSMMMSMMSMMXMAXMASMMMMAMAMMSMSMSAAMSSMMXSMMMXXAXAMASAASMMMSASXSSSSSSMSSMSMSMAASAMMMMMMAXSMMXMXMMMAAAAAMAAASXSAAMXMXAMMASMSAMXAMMMM
    \\SAAMMAAMXAAMASAMMAMMMASXMMAXAMXAAMXSXMAAXSMMMXMMMMXMAAXMASMMXMMMMXAASAMXXAAXAMXXAAAAAXSASMSAAASAMXSXSXSXSSSMMSMSXSMMMAXMMSAMXAMMMMMAASXMXSAM
    \\SXMMSMSSSSMSAMASMASASASMSMMSAMSSMSXXAMMMMXMASAMAAMASMSMAXXXMSMMMSMXMSAMXMMMMMMMMMSMSMXMXMASXSMMMXXMAXAMAMAAXAMMAAXSXMXMXXSASAMSMMSMSASAXXAAS
    \\SXSXSAAAAXXMASXMMASAMXSAAAXXAMXAMAMMMSAASMSAMAXSASASMAAMMMSAAAXXAAAXSMMSAAXAAAAAXXAAXXXMSXSXMASXSSMSMAMXMSMMASMMMMAMSMMMMXAMMSAXMAXMASXMMSMM
    \\MAXAMMMMMMASAMMSXAMMMMMAMMMSSXSXMMXAASMMMAMMSXMXASXSMMSASAMSSMMMSSXXMAAXMXMSSSSSXMSMSMMMMMSAMXAXMXAAXAXAXAXXXAXSXMMSAAAMAMSMMSASXSSMAMMAAAAX
    \\MAMMMMMMAAMMMSASMSMSASMSXXXAXMSAMXMMMMAXMMMASAAMAMAMAAXXMAMXMAMAXAMXMMMSMSMXMMXMMXAXXAAAAXXXMSMSMMMMSMMMSSSSSSXMASXSMXMMXMAAXMAMXMAXAXMMMMSM
    \\MXSAAAXSSSXSXMASAXAMASAXAMMMXAMAAAAMSSSMSMXASMMMAMAMMMSAMSMAXAMXSASMAAAAAASAMXASAMSSMSSSSSXAMSAAXAAMAMAMAMXAXMASAMXXXSMASXSSMMMMSSMMSMMASMAM
    \\XAMXXMXMAAMMAMAMMMSMMMMMMMAMSXSAMXSXMAAAAXMXSAAXXSXSXMSMMXASMSSMSAMXSXSMSMMMMSAXSAMAAAAMAXMXAMSMMSXSAMMMMMMAMSAMXSMSMAMASMXAXXAAMAXXAASAXMAM
    \\MSSMMSMMMMSSMMASXAXXMAXAXSXXAMXXXMXMMMMXMMXMXMMSMAMXAXMMSXAMAXAAXXMAMMAMXXXAAMAMMSSMMMSMXMMSMXMMMMAMAMSAMSSSMXMMAAAAAMMXSXSMMSMSSSMSMMMMSSSM
    \\XMAMAAAMXAAAASAXMMXSMSXXMSMMASXMSMAAAAMSMMSMXMMAMAMSXMAAMMMMXSMMMMSAMXXSAXMMXSXXAAMAXMXMASAAXMAMAMXMAMMASAAAXMSMSMXMMXXAMMXAAXSAAXAAXASXMAXM
    \\MSAMSSMMMMSXMMMSASMSAMMXXMASAMMMASXSXXMAAAAAASXXSAXAASMMSXXAAXAAMAMMSXSMMSMMMSXMMSSSMSASXMMMSMXMASMSMSSMMMSMMAAXAXMSSMMMSAMMMMMXMMSMSASAMAMX
    \\MMXMXAMSSMMXXAXXMSASAMXSSSXMXSASAMXXMMSMSMMMMSAAMXSMAXAXAASMASXMSSMASXXAAXMXAMAMAXAAAXXSMSMMSAXSAMAAMMAMSMAMASXSXSAAAAXSAXXMMXSMMAMXMASXMMSS
    \\XSASMMMXAASMMMXSAMXMSMXAAMXMSXMMASAXAXSAAAXSAMXMMAMXMXSMSXXAMAMXAXMASMMXMXMMXSAMAMXMXMASAMXAMMMMASMSMSAMXSASXMXAAMMXSMMMASXAMAMAMASXMMMMXAAA
    \\SXAXASMMMMMAMAAMXMASXSMMSMSXSAXXMMXSXAMMMMAASXMSAMXSXAMXXAASMASAMXMASXAAMAMAMSXMXXXAXMMMSMMMMXXXAMXMASAMXSMSASMMSXSMMMAMAMMMMSSSMAMASMXAMMSS
    \\MMSMMASXMSSSMMSSXXXAAXXXAAXAMSSXSMAMMSSSSSMMXXAAAXAMMXSAMXXMXXMXMAMAMMSASAMAXSMSXAXSSMSAMXMSSMSMXSAMAMASXSMSAXXAMMMAXXXMAXMAAXAXMXSAMXMSMMAX
    \\XAXASAMXMXAAASAMMMMMMMMSMSMAMAMAASAXMAAXAAXXMMSMAMASMMMXMMXMXSAMXSMASAXXSXXMMSAMMMMMAAAAMXSAAAAAAXXMMSXAAMAMAMMXSASMMSMSASXMSSSXMAMXMAAAAMAS
    \\MSSMMSSSSMSMMXAXMAAAMAAXXMAXMAXSASMSMMSMSMMMXAAXXSXSMAMAASMMASASAMMXMXSMMMSMAMXMAXASXMSSMXMMSSMMXSAMASMMSMAMAXMASAMXAAAMAMAAAAMASAXAXXMMXMXS
    \\MAMXAMMAMAAAXSMMSMSMSMSMXMXXMSAMXXAXXMAMAXAXMSSSXSAMMASMSXAMAMAMASXMSAMAASAMXSASXSAXXXAMXXMXMXXAXSXMAXAXMASMXXSAMAMMSMSMASMMMXSASXMAMSAXSAMX
    \\SAMMMSMAMSMSAMAAAXAAAAAMMMAMMXXMSMSMXMASXMSAMXAXMMAMSMSXMXSMMXXMAMXAMASXMMMMMSASASMSMMAXMMXAXXMMXMMMMSMXSMMMXMMAXXMAAAXXAAMXMXMASAMAAMAMSAMS
    \\SASXSMMMXXAXAMMMMXMMMMMSAMSSMAASXAXAXSAMXMAMXMMMAMAMMXMASAXASAMMSSSMSAMAAXXAAMXMAMAAAXMMSASMXSASXSAAMAMXSAAXAMMSMMMSSMMMMSXAMXMASAMSSMSMMAMA
    \\SXMXAMAMSMMSMMSMSSMMSXMMXXMAMXXXMSMMMMASXSXMSASMSSSMXAXMMMXAMMXMXAAAMMMXMMSMXSMMXMMMMXASMASAASAMASMXXXSAMMMSXSAAAXAAAAXXMAXMSXMAXAMXXAXXXAXA
    \\SAMMXMAXAAAMAMSAAXMAMAXAMXXAMXSSSMMAASAMXSAASAAAAAAXSSMSASMXSXMMMMMMSMSAMXXAASAMASMAAXMMMAMXMMAMXMSSXSMASMMXAMXSMMMSSXMXMASMAMMXXAMSMXMMSMSM
    \\SAMSMXSSSMMSSMMMMSMASXMSSSMAMSAXAASXXSMSAMMMMAMMMMMMXMASASAASMMAAXAAAAMMMSXMXMAMASMMSSMAMSSMXSXMASASXASAMAXSMMAXAXMMMMMMXMAXMSAXXAMSXMAMAMAM
    \\SXMASAMAMXMAMAMAAAXASAAXAXMAMXMSMMMXAXXMMSSMSMXMMMMXXMAMAMMMMASXSSMMSSXMASASMSSMXXAAAAMMMMAMAXMMXMASXMASXXMMXMXSMMSAAAAMMMMMXMAXMSSMAMMSASMX
    \\XASASXSSMAMASAMMSSSSSMSMAMSSSXMAMAMMSMSXMAMXAAAMSASAMMSMASMXSAMXXAXAAAXMASMMAAMMMSMMSSMMASMMSAMXAMAMAXAMMSAXXXMMMASMSSXSAAASMMSMMXAAXMASASXS
    \\SXMASXXASXMASMSAAAXAMXAMXMAAMMSAXAXMAAMXMASXSMMXSASAXAXSXXAAASXMSMMMSSXXMXXMMMMAAAAXAAASASAXMASMSSMSSSXAASMMMMXAMXSAMAASMSMSAAMMMSXMMMXSAMMA
    \\MAMAMXSMMSMMSAMMSSMSSSSSMMMSMASMSMSSMSMAMAMAXAMXMXMMMSMMSMMMMMMAXXXMMMAAXMASASMMSSMMSMMMAXXMXXXXAAAXAXAMXMAAAMMXSAMMMMMMAXXSMMSAAXAMAXAMAMXM
    \\SAMAAXXXAXXMMMMAXAAAAXMMAAAMMMSAAAMXAMXXXSMMSXMXXXXAAXAASXXAAAXXMMSMAMXMMAAMASAMAMXMXSMMAMSMMMMMSMMMMMSXAXSSXXAXMXXMAXXMMMMXXAMMMSMMAMSSMMSX
    \\SXSMSMSMSSSMASMMSMMMSXSSSMSSMAMMMSMSMSSSMXAXSASMSMASMSMMSASMSXSMSMAMASMSSSSSMSAMMMMMAASAMXSAAAXXAMAXAAMAXXAAAMSMMMSSMMMAAAASMMSAMXAAXSAAMAMS
    \\MAXAXAAAAAAMAMAXXAXAAMMAMXAAMXSXXMASAAAAASAMSAMAAAXMAXMAXAMAXASAAAMSASMAAAAAASXMAAAMXMAXSAMXSSMSASMSMMSAMMMMMSXAAAXAAAASMSSXAASAMXMMSMMSMASA
    \\AMMXMSMMMSMMSSXMSMMMSSMAMMSXMASMSMSMMMSMMMXAMSMSMSXMXMSAMXMXMXMSMSXMASMMMMMMXMASMXSAMXXMSAMXXMMSAMXAMXMASXSSXXXSMSSMMMMXAMXMMMSXMXXMXMSMMXSX
;

const day5input =
    \\24|55
    \\38|32
    \\38|21
    \\48|51
    \\48|92
    \\48|14
    \\78|35
    \\78|54
    \\78|87
    \\78|44
    \\72|29
    \\72|65
    \\72|87
    \\72|82
    \\72|37
    \\23|56
    \\23|51
    \\23|81
    \\23|83
    \\23|25
    \\23|87
    \\25|14
    \\25|18
    \\25|55
    \\25|22
    \\25|15
    \\25|77
    \\25|17
    \\54|96
    \\54|65
    \\54|33
    \\54|21
    \\54|36
    \\54|29
    \\54|56
    \\54|89
    \\56|78
    \\56|88
    \\56|77
    \\56|52
    \\56|22
    \\56|81
    \\56|14
    \\56|85
    \\56|17
    \\33|23
    \\33|22
    \\33|83
    \\33|14
    \\33|89
    \\33|25
    \\33|55
    \\33|92
    \\33|72
    \\33|78
    \\96|78
    \\96|21
    \\96|14
    \\96|77
    \\96|92
    \\96|68
    \\96|88
    \\96|24
    \\96|83
    \\96|55
    \\96|91
    \\97|56
    \\97|54
    \\97|17
    \\97|43
    \\97|13
    \\97|33
    \\97|48
    \\97|96
    \\97|65
    \\97|89
    \\97|83
    \\97|37
    \\35|92
    \\35|23
    \\35|25
    \\35|52
    \\35|24
    \\35|33
    \\35|51
    \\35|21
    \\35|55
    \\35|88
    \\35|17
    \\35|56
    \\35|89
    \\52|44
    \\52|61
    \\52|88
    \\52|82
    \\52|64
    \\52|71
    \\52|51
    \\52|99
    \\52|97
    \\52|68
    \\52|85
    \\52|91
    \\52|18
    \\52|55
    \\22|43
    \\22|61
    \\22|72
    \\22|68
    \\22|15
    \\22|87
    \\22|64
    \\22|85
    \\22|97
    \\22|88
    \\22|51
    \\22|71
    \\22|18
    \\22|63
    \\22|91
    \\29|14
    \\29|81
    \\29|35
    \\29|89
    \\29|96
    \\29|21
    \\29|13
    \\29|36
    \\29|23
    \\29|65
    \\29|48
    \\29|17
    \\29|24
    \\29|52
    \\29|33
    \\29|99
    \\65|17
    \\65|15
    \\65|25
    \\65|48
    \\65|56
    \\65|22
    \\65|52
    \\65|21
    \\65|92
    \\65|23
    \\65|36
    \\65|83
    \\65|24
    \\65|55
    \\65|37
    \\65|89
    \\65|81
    \\36|77
    \\36|96
    \\36|83
    \\36|99
    \\36|56
    \\36|89
    \\36|68
    \\36|21
    \\36|55
    \\36|92
    \\36|78
    \\36|88
    \\36|51
    \\36|72
    \\36|52
    \\36|14
    \\36|24
    \\36|17
    \\32|24
    \\32|83
    \\32|13
    \\32|29
    \\32|21
    \\32|25
    \\32|92
    \\32|56
    \\32|33
    \\32|99
    \\32|96
    \\32|14
    \\32|35
    \\32|22
    \\32|88
    \\32|17
    \\32|65
    \\32|81
    \\32|37
    \\64|42
    \\64|48
    \\64|37
    \\64|96
    \\64|44
    \\64|56
    \\64|71
    \\64|76
    \\64|36
    \\64|29
    \\64|33
    \\64|23
    \\64|65
    \\64|13
    \\64|25
    \\64|38
    \\64|43
    \\64|32
    \\64|97
    \\64|54
    \\55|64
    \\55|76
    \\55|61
    \\55|43
    \\55|38
    \\55|87
    \\55|71
    \\55|72
    \\55|54
    \\55|68
    \\55|18
    \\55|67
    \\55|85
    \\55|63
    \\55|51
    \\55|78
    \\55|77
    \\55|44
    \\55|15
    \\55|97
    \\55|91
    \\43|14
    \\43|96
    \\43|32
    \\43|89
    \\43|48
    \\43|35
    \\43|23
    \\43|36
    \\43|83
    \\43|24
    \\43|33
    \\43|52
    \\43|56
    \\43|65
    \\43|13
    \\43|25
    \\43|21
    \\43|17
    \\43|54
    \\43|76
    \\43|42
    \\43|37
    \\92|85
    \\92|71
    \\92|38
    \\92|77
    \\92|64
    \\92|76
    \\92|44
    \\92|51
    \\92|63
    \\92|68
    \\92|87
    \\92|55
    \\92|88
    \\92|18
    \\92|99
    \\92|15
    \\92|72
    \\92|97
    \\92|43
    \\92|82
    \\92|61
    \\92|91
    \\92|78
    \\17|18
    \\17|81
    \\17|82
    \\17|52
    \\17|92
    \\17|77
    \\17|64
    \\17|21
    \\17|14
    \\17|68
    \\17|51
    \\17|83
    \\17|99
    \\17|24
    \\17|91
    \\17|72
    \\17|88
    \\17|15
    \\17|87
    \\17|85
    \\17|55
    \\17|22
    \\17|67
    \\17|78
    \\83|68
    \\83|77
    \\83|18
    \\83|99
    \\83|67
    \\83|51
    \\83|15
    \\83|72
    \\83|92
    \\83|22
    \\83|82
    \\83|85
    \\83|88
    \\83|63
    \\83|78
    \\83|44
    \\83|52
    \\83|24
    \\83|91
    \\83|55
    \\83|87
    \\83|61
    \\83|14
    \\83|64
    \\76|25
    \\76|14
    \\76|56
    \\76|22
    \\76|89
    \\76|23
    \\76|42
    \\76|35
    \\76|83
    \\76|29
    \\76|48
    \\76|32
    \\76|81
    \\76|33
    \\76|96
    \\76|13
    \\76|65
    \\76|21
    \\76|36
    \\76|52
    \\76|24
    \\76|17
    \\76|37
    \\76|54
    \\67|32
    \\67|71
    \\67|33
    \\67|25
    \\67|56
    \\67|97
    \\67|42
    \\67|43
    \\67|38
    \\67|37
    \\67|64
    \\67|29
    \\67|76
    \\67|35
    \\67|48
    \\67|44
    \\67|36
    \\67|82
    \\67|54
    \\67|23
    \\67|61
    \\67|63
    \\67|65
    \\67|13
    \\71|25
    \\71|48
    \\71|29
    \\71|33
    \\71|96
    \\71|42
    \\71|17
    \\71|89
    \\71|97
    \\71|35
    \\71|37
    \\71|54
    \\71|23
    \\71|43
    \\71|83
    \\71|36
    \\71|21
    \\71|13
    \\71|38
    \\71|76
    \\71|81
    \\71|65
    \\71|56
    \\71|32
    \\42|22
    \\42|35
    \\42|29
    \\42|24
    \\42|92
    \\42|36
    \\42|32
    \\42|99
    \\42|89
    \\42|14
    \\42|48
    \\42|65
    \\42|56
    \\42|17
    \\42|37
    \\42|96
    \\42|23
    \\42|25
    \\42|13
    \\42|21
    \\42|52
    \\42|81
    \\42|33
    \\42|83
    \\51|67
    \\51|78
    \\51|61
    \\51|71
    \\51|63
    \\51|97
    \\51|42
    \\51|87
    \\51|72
    \\51|77
    \\51|18
    \\51|29
    \\51|15
    \\51|64
    \\51|85
    \\51|82
    \\51|44
    \\51|43
    \\51|68
    \\51|54
    \\51|38
    \\51|76
    \\51|91
    \\51|32
    \\85|61
    \\85|67
    \\85|76
    \\85|25
    \\85|37
    \\85|33
    \\85|36
    \\85|32
    \\85|23
    \\85|97
    \\85|43
    \\85|63
    \\85|38
    \\85|35
    \\85|13
    \\85|48
    \\85|29
    \\85|44
    \\85|64
    \\85|82
    \\85|65
    \\85|42
    \\85|54
    \\85|71
    \\81|82
    \\81|72
    \\81|52
    \\81|87
    \\81|91
    \\81|15
    \\81|14
    \\81|83
    \\81|92
    \\81|22
    \\81|78
    \\81|68
    \\81|77
    \\81|18
    \\81|24
    \\81|67
    \\81|51
    \\81|85
    \\81|64
    \\81|99
    \\81|88
    \\81|55
    \\81|61
    \\81|21
    \\63|29
    \\63|44
    \\63|38
    \\63|89
    \\63|36
    \\63|48
    \\63|25
    \\63|33
    \\63|96
    \\63|17
    \\63|81
    \\63|32
    \\63|43
    \\63|42
    \\63|35
    \\63|37
    \\63|13
    \\63|76
    \\63|56
    \\63|97
    \\63|54
    \\63|65
    \\63|71
    \\63|23
    \\37|22
    \\37|56
    \\37|99
    \\37|36
    \\37|33
    \\37|78
    \\37|92
    \\37|23
    \\37|52
    \\37|14
    \\37|24
    \\37|55
    \\37|13
    \\37|48
    \\37|25
    \\37|81
    \\37|89
    \\37|83
    \\37|21
    \\37|96
    \\37|15
    \\37|17
    \\37|88
    \\37|51
    \\15|67
    \\15|61
    \\15|29
    \\15|77
    \\15|76
    \\15|68
    \\15|97
    \\15|71
    \\15|85
    \\15|32
    \\15|64
    \\15|63
    \\15|54
    \\15|35
    \\15|87
    \\15|91
    \\15|38
    \\15|43
    \\15|78
    \\15|42
    \\15|44
    \\15|82
    \\15|18
    \\15|72
    \\82|71
    \\82|54
    \\82|36
    \\82|65
    \\82|61
    \\82|63
    \\82|35
    \\82|96
    \\82|32
    \\82|33
    \\82|48
    \\82|76
    \\82|97
    \\82|56
    \\82|29
    \\82|43
    \\82|89
    \\82|23
    \\82|38
    \\82|25
    \\82|42
    \\82|37
    \\82|44
    \\82|13
    \\88|42
    \\88|78
    \\88|71
    \\88|15
    \\88|44
    \\88|54
    \\88|51
    \\88|85
    \\88|97
    \\88|43
    \\88|72
    \\88|91
    \\88|76
    \\88|87
    \\88|18
    \\88|64
    \\88|82
    \\88|63
    \\88|77
    \\88|38
    \\88|67
    \\88|68
    \\88|55
    \\88|61
    \\14|85
    \\14|77
    \\14|68
    \\14|87
    \\14|55
    \\14|67
    \\14|44
    \\14|99
    \\14|22
    \\14|91
    \\14|92
    \\14|61
    \\14|38
    \\14|64
    \\14|71
    \\14|15
    \\14|72
    \\14|52
    \\14|51
    \\14|82
    \\14|63
    \\14|78
    \\14|88
    \\14|18
    \\18|65
    \\18|64
    \\18|71
    \\18|38
    \\18|33
    \\18|63
    \\18|43
    \\18|61
    \\18|67
    \\18|91
    \\18|37
    \\18|13
    \\18|82
    \\18|29
    \\18|48
    \\18|97
    \\18|44
    \\18|42
    \\18|23
    \\18|35
    \\18|85
    \\18|54
    \\18|76
    \\18|32
    \\77|54
    \\77|68
    \\77|97
    \\77|63
    \\77|67
    \\77|85
    \\77|37
    \\77|42
    \\77|38
    \\77|61
    \\77|72
    \\77|18
    \\77|65
    \\77|29
    \\77|44
    \\77|35
    \\77|91
    \\77|82
    \\77|43
    \\77|71
    \\77|32
    \\77|76
    \\77|87
    \\77|64
    \\44|38
    \\44|35
    \\44|25
    \\44|36
    \\44|29
    \\44|33
    \\44|89
    \\44|76
    \\44|56
    \\44|37
    \\44|23
    \\44|48
    \\44|96
    \\44|65
    \\44|97
    \\44|43
    \\44|54
    \\44|71
    \\44|17
    \\44|21
    \\44|81
    \\44|42
    \\44|32
    \\44|13
    \\21|61
    \\21|22
    \\21|14
    \\21|82
    \\21|72
    \\21|92
    \\21|91
    \\21|18
    \\21|15
    \\21|24
    \\21|87
    \\21|67
    \\21|83
    \\21|55
    \\21|85
    \\21|99
    \\21|77
    \\21|63
    \\21|68
    \\21|51
    \\21|88
    \\21|64
    \\21|52
    \\21|78
    \\87|37
    \\87|65
    \\87|64
    \\87|48
    \\87|67
    \\87|91
    \\87|33
    \\87|82
    \\87|29
    \\87|63
    \\87|54
    \\87|85
    \\87|42
    \\87|61
    \\87|76
    \\87|38
    \\87|97
    \\87|44
    \\87|35
    \\87|43
    \\87|32
    \\87|18
    \\87|13
    \\87|71
    \\89|87
    \\89|81
    \\89|92
    \\89|78
    \\89|15
    \\89|88
    \\89|64
    \\89|91
    \\89|17
    \\89|68
    \\89|24
    \\89|72
    \\89|77
    \\89|99
    \\89|55
    \\89|83
    \\89|22
    \\89|18
    \\89|14
    \\89|52
    \\89|21
    \\89|85
    \\89|51
    \\89|67
    \\61|63
    \\61|97
    \\61|33
    \\61|23
    \\61|65
    \\61|17
    \\61|35
    \\61|13
    \\61|56
    \\61|71
    \\61|44
    \\61|96
    \\61|42
    \\61|38
    \\61|37
    \\61|29
    \\61|76
    \\61|48
    \\61|32
    \\61|54
    \\61|36
    \\61|43
    \\61|89
    \\61|25
    \\91|65
    \\91|67
    \\91|44
    \\91|13
    \\91|76
    \\91|32
    \\91|61
    \\91|82
    \\91|63
    \\91|85
    \\91|29
    \\91|43
    \\91|36
    \\91|64
    \\91|48
    \\91|71
    \\91|38
    \\91|37
    \\91|33
    \\91|42
    \\91|97
    \\91|35
    \\91|23
    \\91|54
    \\68|87
    \\68|65
    \\68|63
    \\68|91
    \\68|38
    \\68|37
    \\68|61
    \\68|35
    \\68|54
    \\68|32
    \\68|82
    \\68|97
    \\68|18
    \\68|71
    \\68|13
    \\68|72
    \\68|64
    \\68|85
    \\68|44
    \\68|42
    \\68|29
    \\68|76
    \\68|43
    \\68|67
    \\99|91
    \\99|15
    \\99|38
    \\99|55
    \\99|72
    \\99|64
    \\99|77
    \\99|18
    \\99|97
    \\99|54
    \\99|76
    \\99|61
    \\99|78
    \\99|44
    \\99|71
    \\99|68
    \\99|82
    \\99|43
    \\99|51
    \\99|88
    \\99|85
    \\99|63
    \\99|67
    \\99|87
    \\13|15
    \\13|14
    \\13|99
    \\13|89
    \\13|17
    \\13|21
    \\13|25
    \\13|51
    \\13|56
    \\13|33
    \\13|48
    \\13|36
    \\13|78
    \\13|83
    \\13|77
    \\13|81
    \\13|24
    \\13|52
    \\13|88
    \\13|23
    \\13|22
    \\13|55
    \\13|92
    \\13|96
    \\24|18
    \\24|87
    \\24|77
    \\24|92
    \\24|52
    \\24|14
    \\24|44
    \\24|61
    \\24|22
    \\24|71
    \\24|82
    \\24|72
    \\24|78
    \\24|68
    \\24|64
    \\24|63
    \\24|51
    \\24|67
    \\24|88
    \\24|99
    \\24|15
    \\24|85
    \\24|91
    \\38|43
    \\38|65
    \\38|54
    \\38|42
    \\38|23
    \\38|33
    \\38|76
    \\38|83
    \\38|96
    \\38|25
    \\38|37
    \\38|48
    \\38|35
    \\38|81
    \\38|56
    \\38|97
    \\38|29
    \\38|13
    \\38|36
    \\38|89
    \\38|24
    \\38|17
    \\48|33
    \\48|83
    \\48|23
    \\48|78
    \\48|55
    \\48|81
    \\48|22
    \\48|77
    \\48|89
    \\48|25
    \\48|24
    \\48|21
    \\48|99
    \\48|36
    \\48|17
    \\48|96
    \\48|68
    \\48|56
    \\48|52
    \\48|15
    \\48|88
    \\78|68
    \\78|72
    \\78|77
    \\78|43
    \\78|64
    \\78|38
    \\78|61
    \\78|97
    \\78|71
    \\78|76
    \\78|42
    \\78|32
    \\78|85
    \\78|65
    \\78|91
    \\78|63
    \\78|82
    \\78|18
    \\78|67
    \\78|29
    \\72|32
    \\72|67
    \\72|97
    \\72|64
    \\72|61
    \\72|13
    \\72|42
    \\72|85
    \\72|76
    \\72|71
    \\72|91
    \\72|35
    \\72|18
    \\72|54
    \\72|48
    \\72|63
    \\72|43
    \\72|38
    \\72|44
    \\23|96
    \\23|68
    \\23|92
    \\23|99
    \\23|22
    \\23|14
    \\23|89
    \\23|72
    \\23|77
    \\23|17
    \\23|24
    \\23|55
    \\23|52
    \\23|15
    \\23|78
    \\23|88
    \\23|36
    \\23|21
    \\25|72
    \\25|51
    \\25|52
    \\25|21
    \\25|92
    \\25|78
    \\25|87
    \\25|91
    \\25|24
    \\25|88
    \\25|96
    \\25|83
    \\25|99
    \\25|81
    \\25|68
    \\25|89
    \\25|56
    \\54|83
    \\54|22
    \\54|81
    \\54|42
    \\54|48
    \\54|92
    \\54|24
    \\54|25
    \\54|13
    \\54|35
    \\54|52
    \\54|37
    \\54|32
    \\54|14
    \\54|23
    \\54|17
    \\56|68
    \\56|24
    \\56|99
    \\56|72
    \\56|15
    \\56|55
    \\56|51
    \\56|18
    \\56|21
    \\56|91
    \\56|87
    \\56|92
    \\56|83
    \\56|89
    \\56|96
    \\33|56
    \\33|99
    \\33|96
    \\33|52
    \\33|81
    \\33|88
    \\33|15
    \\33|36
    \\33|68
    \\33|77
    \\33|17
    \\33|51
    \\33|24
    \\33|21
    \\96|72
    \\96|52
    \\96|67
    \\96|51
    \\96|85
    \\96|81
    \\96|89
    \\96|87
    \\96|18
    \\96|17
    \\96|22
    \\96|15
    \\96|99
    \\97|42
    \\97|29
    \\97|14
    \\97|36
    \\97|81
    \\97|32
    \\97|23
    \\97|21
    \\97|35
    \\97|76
    \\97|24
    \\97|25
    \\35|65
    \\35|22
    \\35|99
    \\35|37
    \\35|13
    \\35|96
    \\35|81
    \\35|36
    \\35|14
    \\35|48
    \\35|83
    \\52|92
    \\52|15
    \\52|78
    \\52|63
    \\52|67
    \\52|22
    \\52|72
    \\52|38
    \\52|87
    \\52|77
    \\22|92
    \\22|78
    \\22|99
    \\22|82
    \\22|44
    \\22|67
    \\22|77
    \\22|38
    \\22|55
    \\29|55
    \\29|92
    \\29|56
    \\29|88
    \\29|22
    \\29|83
    \\29|25
    \\29|37
    \\65|14
    \\65|99
    \\65|88
    \\65|13
    \\65|51
    \\65|96
    \\65|33
    \\36|81
    \\36|87
    \\36|25
    \\36|15
    \\36|22
    \\36|18
    \\32|36
    \\32|48
    \\32|89
    \\32|23
    \\32|52
    \\64|82
    \\64|63
    \\64|61
    \\64|35
    \\55|32
    \\55|42
    \\55|82
    \\43|81
    \\43|29
    \\92|67
    \\
    \\42,54,21,36,22,33,13,29,35
    \\83,67,22,14,78,99,18,92,15,77,52,68,82,55,21,61,85,91,51,64,72,24,88
    \\85,67,64,82,61,63,44,71,38,97,43,54,42,32,29,35,65,37,13,48,33,23,36
    \\96,81,21,14,52,99,88,55,51,15,77,68,72,18,85
    \\63,52,77,85,91,83,22,61,14,64,82,68,51,24,55
    \\63,97,76,32,29,35,13,48,33,36,25,56,96,89,17
    \\15,99,51,88,21,83,72,56,81,18,92,52,55,17,89,96,87
    \\92,22,17,96,78,87,72,14,24,55,81,91,52,83,68,88,18,99,56
    \\87,18,61,67,64,76,72,85,97,65,91,68,32,44,29,43,37
    \\87,63,72,64,85,38,43,78,76,82,77,67,88,54,55
    \\51,77,87,85,67,61,63,44,97
    \\35,65,37,13,48,36,25,56,81,24,22,92,88
    \\85,29,32,42,35,87,43,13,63,37,71,72,82,76,91
    \\56,35,81,96,55,92,83
    \\54,68,67,77,61,18,63,76,82,55,97,15,42,91,51,38,85,43,72,87,71
    \\99,88,55,15,77,68,72,87,18,91,67,82,61,44,71,38,97,43,76
    \\14,17,81,91,55,22,21,87,64
    \\92,51,68,96,81,17,88,89,83,22,23,15,14,21,25,99,24,78,56,72,36,77,55
    \\68,87,18,85,82,44,71,43,76,54,42,32,29,35,37
    \\92,22,88,14,21,55,24,17,25,36,13,23,48
    \\92,25,18,68,88,51,17
    \\32,17,37,54,89,71,43,33,42,21,25
    \\33,36,25,56,96,89,17,81,83,24,14,52,22,92,99,55,51,15,78,77,68
    \\61,63,44,71,38,43,76,54,42,32,65,13,48,33,36,56,89
    \\14,88,51,87,64,44,71
    \\14,92,88,51,15,77,68,87,71
    \\42,21,89,83,35,65,81,24,23,32,33,13,29,14,52,25,17
    \\17,83,14,22,92,55,51,15,78,77,18,91,85,67,64
    \\21,83,22,18,92,67,15,99,64,85,68,87,55,91,78,51,88,77,14,61,52
    \\64,15,77,85,92,61,88,83,78,22,18,72,68,52,82,91,87,63,14,99,55
    \\89,21,76,35,96,83,17,13,38,25,54
    \\77,68,91,85,64,82,44,38,65
    \\54,64,91,38,63,51,71,61,85,97,44,18,67,76,43,72,78,15,32
    \\51,87,52,85,72,14,83,24,68,15,21,17,92
    \\21,83,99,96,36,17,52,81,56,65,25,14,48,13,24,92,55,23,89
    \\76,42,29,48,33,36,25,56,96,89,17,81,83
    \\77,55,22,78,87,64,61,88,67,68,71,72,51,44,52,82,99,15,14
    \\37,33,85,54,44,76,38,23,13,42,36
    \\43,25,29,13,33,38,35,97,48,56,65,32,17,54,89,81,44,37,36,23,71
    \\81,92,88,78,68,91,85,67,82
    \\56,81,21,24,14,88,55,51,77,68,91
    \\97,29,65,33,17,83,24
    \\38,33,56,43,61,35,76,54,64,32,36
    \\63,44,71,38,43,76,54,42,37,13,48,23,36
    \\22,17,96,89,14,92,83,37,99,88,29,21,52,48,23,81,35,24,36,13,25
    \\77,61,18,87,72,51,38
    \\24,92,99,55,51,85,44
    \\64,82,77,35,38
    \\87,51,15,88,67,52,18,82,72,77,99,71,64,22,44
    \\99,88,51,15,78,72,87,18,85,67,64,61,63,71,76
    \\23,36,25,56,96,17,81,83,14,52,92,88,55,51,78,68,72
    \\52,92,99,15,78,77,68,72,87,91,85,64,82,61,44,71,38
    \\13,23,17,14,99,55,78
    \\25,17,35,37,44,54,71,81,56,65,32
    \\38,64,55,52,87,77,71,99,88,68,18
    \\71,38,97,76,54,42,32,29,35,65,13,33,23,36,25,56,96,89,17,81,21
    \\82,91,52,83,21,18,14,77,85,61,92,64,88,51,68,99,78,22,24
    \\29,35,13,33,25,56,96,89,17,21,83,24,14,52,22,92,88
    \\91,61,14,88,18,15,55,99,82,77,64,92,78,87,71,68,51,85,72
    \\13,36,35,32,38,76,63,82,37,43,65,42,54,48,64,29,56,97,33
    \\61,88,71,68,92,55,77,63,67,51,38
    \\18,85,88,63,77,52,38,61,64
    \\89,83,99,88,55,15,78,77,68,72,87,18,91,85,67
    \\13,17,35,89,48,33,43,54,21,23,38,83,76
    \\36,25,56,96,89,17,81,21,83,24,14,52,22,92,99,88,51,15,78,77,68,72,87
    \\24,52,22,55,51,15,78,72,87,64,82,61,44
    \\55,15,78,87,18,85,63,71,38,97,54
    \\37,44,61,32,85,76,71,68,87
    \\23,65,89,56,33,21,37,22,48,17,96,25,92
    \\24,14,52,92,99,88,55,51,15,72,87,18,91,61,63
    \\24,14,22,92,99,88,51,15,78,68,72,87,18,85,64,82,61,63,44
    \\64,44,97,43,76,54,42,35,37,13,33,36,56
    \\15,87,91,67,82,61,97
    \\63,18,32,76,67,82,15,64,91,72,85,68,54,43,42,71,61,87,97,44,38,78,29
    \\48,33,25,56,96,89,81,21,14,52,22,92,99,88,55,51,15,78,77
    \\89,17,81,83,52,88,15,78,77,72,87
    \\51,55,92,77,88,72,68,24,87,89,85,99,52,14,83,81,21,91,15,17,22,18,96
    \\76,35,33,13,14,42,81,43,23,29,89,24,21,96,17,37,32,25,65
    \\89,25,13,56,78,15,92,48,17,23,88,99,14,51,52
    \\21,83,54,33,35,25,13,22,48,37,56,14,36,89,42
    \\61,71,29,37,13
    \\96,17,24,14,22,92,88,51,77,72,85
    \\99,88,55,51,77,68,72,87,18,91,85,82,61,63,71,38,97,43,76
    \\65,35,42,32,13,17,25,83,33,23,54,14,24
    \\76,54,87,72,61,18,97,91,44,42,65,85,82,71,77,35,29
    \\91,87,92,78,21,52,18,24,68,85,77,15,81,83,22,64,72,51,99,82,14,67,88
    \\43,32,35,37,13,96,17
    \\33,36,96,21,24,14,52,22,92
    \\77,83,92,85,81,91,21,68,24,64,82
    \\61,71,48,63,44,32,42,65,37,56,96,43,35,76,29,23,38
    \\44,71,38,54,32,35,13,33,23,56,96
    \\23,17,81,21,83,24,92,99,88,55,51,15,78,77,72
    \\42,33,61,67,23,64,25,65,82
    \\81,13,48,22,29,23,35,14,21,92,89
    \\33,23,36,25,56,96,17,81,21,83,24,14,52,22,92,99,88,55,51,15,78,77,68
    \\32,29,35,65,37,48,23,36,56,96,89,17,81,21,83,24,52,22,99
    \\65,37,13,25,96,89,17,21,92
    \\48,76,13,82,71,97,23,61,56,29,36,33,44,42,25,43,38,54,37,96,35
    \\21,99,61,87,68,22,88
    \\18,38,54,32,35,48,33
    \\97,63,55,78,15,77,68,87,61,18,38,51,71,91,88,99,92,22,44,85,82,67,64
    \\56,99,36,96,13
    \\56,25,43,76,23,33,64,29,36
    \\99,51,68,87,91,82,63,44,71,43,76
    \\82,54,85,91,29,64,33,61,42,37,97
    \\56,42,17,33,97,43,63
    \\77,17,21,99,52,85,15,91,78,88,14,67,51,24,92,22,64
    \\55,51,15,78,77,68,72,87,18,91,85,67,64,82,61,63,44,38,97,43,76,54,42
    \\87,78,67,18,42,61,55,82,91,71,85,97,15,72,43,76,63,44,64,38,54,77,51
    \\37,44,64,13,29,97,25,82,61,67,36,35,43,63,23
    \\33,23,25,56,96,89,17,21,83,14,52,22,92,99,88,51,78,77,68
    \\33,36,32,35,48,23,24,21,22,17,99,83,25,37,96,29,81,92,14,65,52
    \\76,32,71,42,33,82,97,36,54,44,35,13,29,43,37,63,48,96,65
    \\65,37,13,48,33,23,36,25,56,96,89,17,81,21,83,24,52,22,92,99,88,55,51
    \\42,32,29,35,37,13,48,23,36,56,96,21,83,14,52,22,92
    \\42,43,25,65,23,37,61,44,48,29,76,33,36,38,54,97,96,89,35
    \\52,99,55,51,78,18,64,82,63,71,38
    \\36,96,89,17,81,83,14,52,88,51,15,78,77
    \\96,81,51,15,99,37,24,36,13,17,33
    \\21,83,24,14,52,99,88,55,51,15,68,72,91,85,67,64,61
    \\25,51,81,22,99,56,18,52,78,14,87,92,15,77,68,83,55
    \\81,77,92,21,51,15,99,96,56
    \\71,43,65,82,54,42,13,36,25,61,23,33,35,63,67,38,76,97,37,32,29
    \\37,76,63,61,96,56,25,35,13,36,43,29,82,32,48,33,97
    \\35,52,23,14,96,42,89,21,81,83,76
    \\48,23,36,25,56,96,89,17,81,21,83,24,14,52,22,92,99,88,55,51,15,78,77
    \\44,61,85,92,91,77,15,64,51
    \\37,13,48,33,23,25,56,81,83,52,92,51,15
    \\56,78,96,88,92,36,23,17,25,52,48,99,24,89,55,21,15,81,51
    \\64,22,67,55,97,72,15,18,68,38,88
    \\85,64,68,44,54,87,76,91,82,63,88
    \\85,38,78,82,18,87,91,32,77,43,76,72,15,42,51
    \\22,92,88,72,87,91,67,82,61,44,97
    \\55,18,54,38,87,88,85,15,76
    \\83,24,14,52,22,92,88,55,51,15,78,77,68,72,18,91,85,67,64,61,63
    \\42,32,35,65,37,13,48,33,23,36,25,56,96,89,21,83,24,14,52,22,92
    \\32,17,29,83,48,14,21,25,52,42,96,33,37,65,76
    \\35,89,81,14,32,83,29,65,52,25,92,13,22,36,33,48,37,42,24
    \\81,42,35,36,89,54,71,25,32,43,76,37,38,44,65,23,17,33,56
    \\21,18,87,52,22,56,51,15,77,92,25,55,72,99,78,96,14,83,24
    \\56,25,37,81,38,89,21,43,65,83,33,36,35,96,48,42,29
    \\55,15,77,68,87,18,91,85,61,44,38,97,43,76,42
    \\22,99,72,83,67,52,61,21,68,14,87,18,77,51,64
    \\92,55,85,14,22,17,52,89,78
    \\88,68,18,14,81,22,91,52,83,99,72
    \\36,17,29,83,96,65,54,89,43,35,56,23,25,13,81,76,14
    \\88,51,78,63,43,76,54
    \\91,67,82,61,38,97,43,76,54,42,32,29,35,13,48,33,23
    \\67,63,35,71,54,68,37
    \\85,35,33,32,61,76,65,54,37,67,91,42,97,48,71,82,38,29,13,44,43
    \\77,15,81,89,96,25,14,92,78,22,51,24,21,83,56,18,88,99,68
    \\23,36,25,22,92,15,72
    \\23,25,54,36,65,17,14,76,56,96,35,48,81,24,37,21,89
    \\85,64,61,38,32,29,65
    \\56,89,17,24,14,92,99,55,78,18,91
    \\18,85,61,63,44,71,38,48,33
    \\81,21,14,52,92,88,72,67,82
    \\55,51,15,78,77,64,63,44,38,43,76,54,42
    \\76,54,48,23,96,81,83,24,52
    \\21,83,13,14,22,96,25,37,56,81,36,92,42,89,23,32,24,33,52,35,17
    \\42,13,91,38,43,82,35,18,87,29,37,85,64,67,54,32,63,76,72,61,44
    \\23,22,29,21,24,36,14,99,89,56,88
    \\77,56,15,33,48,24,81,22,92
    \\78,87,85,67,44,71,97,29,35
    \\61,15,78,63,77,71,44,68,91,87,32,85,72,43,76,82,29,97,42,54,18,38,67
    \\99,18,81,82,87,24,78,51,83
    \\54,65,48,36,14,52,22
    \\63,44,38,97,54,42,32,65,37,56,96,89,17
    \\83,88,68,72,81,52,55,36,25,22,17,92,87
    \\44,38,97,54,42,37,13,33,23,36,81
    \\61,18,67,64,38,35,65,85,68,29,37,63,71,42,91,82,97
    \\65,54,23,35,89,43,29,38,36,76,81,21,32,17,56,71,42
    \\96,78,55,91,17,77,85
    \\64,82,61,44,38,97,43,42,32,35,65,37,48,33,23
    \\23,36,25,56,89,17,81,21,83,14,52,22,92,99,88,55,51,15,78,68,72
    \\97,43,54,42,32,29,35,37,13,48,33,23,56,96,89,17,21,83,24
    \\54,65,36,23,71
    \\13,44,33,63,48,97,25,38,64,82,61,56,76,42,54,65,71,43,23,35,36,37,32
    \\65,13,48,23,36,56,89,21,52,22,88,55,51
    \\68,51,14,83,64,18,77,17,91
    \\76,37,38,25,13,33,71,21,42
    \\21,92,81,87,24,56,51
    \\48,83,35,37,81,97,89,54,33,29,36,13,96,23,38,21,65,17,76,56,32,43,25
    \\13,48,17,83,14,15,78
    \\18,22,92,82,68,87,24,52,44,99,67
    \\77,99,87,92,22,51,52,68,71,14,82
    \\22,67,83,63,14,15,82
    \\64,44,97,61,67,32,37,65,38,29,35,48,71,36,54,76,85
    \\24,14,92,99,15,78,87
    \\63,71,76,54,32,29,35,65,37,13,48,33,23,36,25,56,96,89,17
    \\42,96,71,35,25,65,23,33,44,81,32,97,29,76,13,54,43,56,17
    \\87,91,67,82,44,71,38,97,43,76,29,35,65,37,48
    \\33,38,13,48,65,43,61,82,37,76,54,32,35,44,67,29,85
    \\24,52,22,92,55,51,78,68,72,18,91,85,64,82,44
    \\63,48,85,67,38
    \\42,32,35,65,13,48,33,36,25,89,17,81,14
    \\63,44,71,43,35,65,37,13,23,36,17
    \\25,21,97,33,54,32,76,42,37,17,35,65,89,81,83,96,36,23,48,43,13,38,29
    \\42,32,29,35,65,37,33,25,56,89,17,21,24,14,52,22,92
    \\37,48,81,21,83,14,22,88,55,51,15
    \\55,51,77,68,87,18,91,85,67,82,63,44,38,97,54
    \\35,65,13,33,36
    \\61,48,44,64,43,36,82,42,56,29,23,54,33
    \\92,99,88,55,15,78,77,68,72,18,91,67,64,82,61,63,44,71,38,97,43
    \\32,29,33,23,96,83,22,92,99
    \\63,55,61,92,87,64,88,85,72
    \\67,92,77,64,52,51,81,91,17,85,21,22,14,78,15,88,18,72,83,55,68
    \\36,78,92,22,51,87,99
    \\37,13,36,56,81,92,88,55,15
    \\29,35,37,13,48,33,23,25,56,96,89,17,81,21,83,24,52,22,92,99,88
;

const day6input =
    \\............#.............#......................#....#....................................................#..............#.......
    \\..................................#...#......#.......#........#..................#....#...........................##....#.........
    \\...........#...........#...........#...#...#...............................#.......................##....................#........
    \\..................#.............#........#.....................#...........................................................#......
    \\....#............................................................#..#...#......#.#......#...#..........#..#.....#....#...#........
    \\.................................#......##.............................#..........................#...#.........#.................
    \\.#.............#.........#..#..............................................................................##...........#..#......
    \\....#..............#..........................##......#........#...#........#..........#........#.............#...................
    \\.....#.......#..#......#..#..................................................................#.........................#..........
    \\......................#...............................#......#................................#......#.....#......................
    \\.......#.........#.....................................................................#....#.#.....................#.........#...
    \\........................#......##..........#....#..........................#....................#...................#.........#...
    \\................#..#............#...#.................................................................#...........#...............
    \\.#.....#.....................#..........................................#................................#........................
    \\.............#.##........#......#......#......................#..................................................#...#..........#.
    \\.......#.........#.#..........#.............#.......#............#.....................#..........................................
    \\.............................#.........................................................#.........#.........#.............#........
    \\....#..#.#..................................................#...........#..................#....#.................................
    \\...............#..........#.....#..............................................................#..................................
    \\.......##.............................................................................#...............#.........#.................
    \\....#.....#..........................#..........#................................#....................#...#.......................
    \\.#.................................................#..#.....#.....................................................................
    \\...........................#..............#.#...#..........................................#......#..........................#....
    \\.#....#........#....................................................#...........................................#.................
    \\...#..................#................##...#.............#..#....................#...............#...............................
    \\..................................................#......#..........................................................#...#.........
    \\#.#....................................#........#.............................................................#...................
    \\...............................................#.......##...............................................#.........................
    \\...#.............#................................................................................................................
    \\.......................................#....#..#........#............#..........#.........#...#..................#................
    \\........#.................................................#.........................................#...........#.................
    \\...................#...........#...............................#..........................#................#..#..........#.....#..
    \\...............#......#...............................................................#............................##..#.....##...
    \\.........................................##.#..#..................#.......#.....................#.................................
    \\...........#...................................................................#...#..................................#.....#.....
    \\......#...............................#.......###..........................#....#.....................................#...........
    \\.....##...............................#...................................................#................................#...#..
    \\..................#....#.......#.......................................................................##.........................
    \\.....#..#.................................................................................................#.......................
    \\.#.................................#......................##....................................#..........................##.....
    \\#.#................#......................................#...........................#.......#...................................
    \\.................................#.......#.....#..............................................##..#....................#..........
    \\............#...............................................................................#....#...........#..........#.........
    \\................................................##...............................................#..#..........................#..
    \\.................#.......#........................................................................#...............................
    \\..#.........................#......#.............#.......................................#........................................
    \\...............#.............#...........................................................#.....#..................................
    \\.........#...............................................................................#...............................#........
    \\.........................................#...................#.................#.........##........#.........#....................
    \\............#..........#.....#................................................................#...##............................#.
    \\........#...#....#..............................................#..............#........................#.........................
    \\..#.....................................................................................................................#.........
    \\.#....#.............................^................#..#...................#.........................#...........................
    \\..........................................................................#.........#....#......#.................................
    \\.........#................................#.#........................#.................#...................................#......
    \\.............................................#.##............................................................#......#..#.........#
    \\..........#............#...........#..#......#..........#.........................................................................
    \\......................#....................................#....#.............##....#.............................................
    \\......................#...#............#.......................................................................................#..
    \\.##.................#.......................#...............#.............#......#..................................#.....#.#.....
    \\....................#........#.......................#....................................#.......#...#.......#.......#......#....
    \\.............................................................#.......................#..........................#.....#...........
    \\...#.................#.......................................................#.......##...........#.......#.......................
    \\...............##.........................#.........................................................#.....#.......#...............
    \\.......................#.......................#.........#..............#....................#..........#........................#
    \\...................................##..........#..........................................................#.........#.............
    \\..................#...............................#...................................#.......#.......................#...........
    \\.......................#..#...................................#........................#........#............#....................
    \\...................................#....#............#..................#........................................#..........#.....
    \\.............#...#...#......#.............##...............................................#..........................#....#......
    \\....................#..........................................#....#......................................................#......
    \\............#.........#...............#..#.....................................................................#.#................
    \\.......................#..#..............................................................#.....#........#..#..................#...
    \\.............#..#..............................#.....#.................#.............#.......................#................#...
    \\...............#......#...........#............#.........#......................................#.................................
    \\............................#.....#.........#.....#..#...........#................................................................
    \\....#.......#.................#..............................................#.......#.#.............................#...#..#.....
    \\..................................................#.#......#............................................................#.........
    \\..................................#............#........................#.......#.........#...#...............#...................
    \\............##....#.#......#..............................................................................#..............#........
    \\.....#..........................................#.........................................................#........##.............
    \\............#.....................#..#.#..............#........#......#.............................#....#...#....................
    \\.......................#...........................................................................#..............................
    \\......#.........................................#........#............#..#..............................#.#.......................
    \\#.#......#..#...............#...........#....#.................................................#..................................
    \\.........#...........#............................#..............#......................#.......................................#.
    \\...#............#..................................#..............#............................#.........................#........
    \\...##..#.....................................................................................#...........................#........
    \\...............#......#.........#................................#...#............#....................#..........................
    \\..........................#...........................#..............................................#................#....#......
    \\.........#........#.#...........................................................................#..#..............................
    \\.................#..............#........................................................................#.................#......
    \\...#.........#.#.........#.#...........................................#........#........#.........#..............................
    \\..........#............................................................#..........#.....#.........................................
    \\..................................#.....#...........##........#......#..........#..........................#......................
    \\...........................#....#.............#............................................................#......................
    \\.............#.......#...................................#.....#............................................................##....
    \\............#..............##.............#.....#...............#..........#........................#.........................#...
    \\..##.....................................................................................................#........................
    \\.............#.#...........#...................#....#...#......#................##................................................
    \\.................#.#............#........................#.......##..#.........##.................................................
    \\......................#.#...#................................................................#...............#.....#...........#..
    \\#.................#..........................#.............................##.....#...........................................#...
    \\..............#.........#.................#................................................................................#......
    \\....#.#............#.......#.......................#.....#.......................#....................#.....#.............#.......
    \\......................#..#....#.........................................#.#............##............#............................
    \\.........#.#...#...#........................................#...............................................#....................#
    \\.......................#...................#.............................................................#.......................#
    \\................#............................#........#..........#.......................##....#..................................
    \\.#...................#......................#.......................................#............................#................
    \\..#..##.......#......#..........#..#..................................................#...........................................
    \\..............#..........#...........................................#.........##.................................................
    \\....#..............................#.........#...#.................#......#.#.......#.............................................
    \\#.................................#........#.....................................#...##...................#..#...........#........
    \\.......#.....#.............................................#..................#...................#...........#..#........#.......
    \\.......................#................#.............#.#.........#..............................................................#
    \\......................................................#....................#..........#................................#..........
    \\#...............#...#.............#.................#.................................................#...........................
    \\..................................................................#.........................#......#.........#............##......
    \\#.................#........#.......#...#....................................#.#...................................................
    \\.....................................#...#....#.........#................#.........................................#...#..........
    \\............#............................#.............#.#........................................................................
    \\......................................#.................................................#...............#.......#.................
    \\.#.#..........#........#.......................#..................................................#....................#..........
    \\....#...............................................................#...........#............#.......................#............
    \\....#.......#.#..#...................#.........#..................................#....................................#..........
    \\..............................................#...................................##.......#......................................
    \\#...#.#............#...............................#.........#...........#..........#............................................#
    \\..#...........#..#..........#.......................#..........##.................................................................
    \\...#.....#..................................#................................................#....................................
;

const day7input =
    \\234815: 36 8 815 40 55
    \\155271616759: 1 7 652 2 7 421 4 58 3 9
    \\8580336: 3 6 35 3 6 539 2 59 1 3 3
    \\189612: 65 20 4 236 9 61 7 508
    \\17087913891: 854 2 2 5 910 22 367 1
    \\4724307587818: 82 651 885 4 1 8 7 8 18
    \\25057637: 630 6 396 6 1 637
    \\7872602815: 9 26 602 6 4 543 354
    \\20319060825485: 3 47 1 8 3 6 712 52 7 9 2
    \\6937026: 78 5 4 9 33 2 6 92 2 1 3 6
    \\16490320: 1 290 2 97 5 7 176
    \\81202174: 5 76 5 6 5 36 20 1 94 80
    \\531135610: 111 491 16 25 55 613
    \\527172: 3 955 854 462 72
    \\2799: 8 26 71 9
    \\1558950: 134 7 4 5 5 71 27 949
    \\8043570: 4 72 22 8 279
    \\43643248: 433 2 86 56 513 727 8
    \\583307: 59 2 9 23 11 231 76
    \\10272379: 876 1 514 739 27 9
    \\3254637331: 1 3 32 9 35 6 6 7 5 1 5 42
    \\892457: 89 24 20 6 31
    \\133629334: 4 8 287 22 97
    \\5784660503: 310 311 8 78 6 782 3
    \\4400201: 65 236 957 270 11
    \\1091316: 3 421 319 8 9
    \\909346771: 606 3 5 1 9 3 3 5 5 90 6
    \\73663: 73 6 63
    \\507442: 481 26 418 22 4
    \\246922771: 96 83 500 24 99 51
    \\30421378: 33 8 9 13 33 9 37
    \\995887199: 238 5 48 55 317
    \\1374726: 1 9 701 77 3 1 582 3 39
    \\5993001673: 7 1 859 1 59 28 9 2 115
    \\32111: 6 37 5 25 8
    \\15749: 48 9 6 94 46
    \\163723896: 723 251 525 9 13 4 42
    \\14156664983203: 9 25 50 937 721 2 67
    \\173811792: 407 42 4 82 31
    \\1447453: 5 8 462 241 7
    \\29495757285: 7 373 488 449 4 9 285
    \\4212640331532: 9 320 904 6 6 307 5
    \\499870673: 49 98 70 667 7
    \\1604946219: 58 75 1 895 721 220
    \\765912480: 2 75 6 987 47 7
    \\86058621: 956 12 8 69 9
    \\41337379: 4 64 979 91 33 3 47
    \\9744108902: 73 1 819 132 902
    \\1530162: 98 67 5 155
    \\198731: 220 6 44 3 9 5 4 6 5 8 3 8
    \\84748076541: 789 7 5 7 73 5 7 3 994 3
    \\2529151157: 7 705 97 376 9 317
    \\2228: 66 7 88 7 4
    \\2651040266: 807 45 612 8 73 5
    \\1064798: 5 7 52 7 85
    \\37595457: 264 734 8 2 14 97 3 1
    \\263091920: 3 98 80 91 284
    \\4343335925: 40 274 2 693 998 7
    \\5450841: 840 721 9 1 6 75
    \\643963238282: 2 6 33 1 885 783 1 2 91
    \\171085643: 223 14 548 36 7
    \\45690309: 27 821 2 687 3
    \\5564104817: 7 643 728 813 4
    \\86673: 89 7 69 2 701
    \\87323: 32 5 3 7 64 29 6 8 3
    \\19873: 380 7 106 7 508
    \\1548: 5 8 93 740 656
    \\762: 9 1 1 5 712
    \\307671: 9 815 8 881 30 41 48
    \\2932551: 42 54 431 3 27
    \\23646: 5 91 4 9
    \\1653697595: 7 54 5 40 6 9 9 72 7 8 9 3
    \\17216951640: 538 40 8 52 898 1 642
    \\4346316390: 78 753 74 387 3
    \\527476015: 6 2 9 433 23 4 7 52 8 15
    \\7028573625: 481 902 8 9 3 4 34 5 45
    \\93857: 64 6 9 5 98 8 62 9 26 3 8
    \\45372094843: 8 95 597 948 40
    \\13074553: 81 571 79 66 6 2 43 5 3
    \\3472508224: 4 9 60 719 23 3 677 7
    \\1123: 88 5 5 8 339
    \\1376356816: 483 548 65 2 8
    \\314881054465: 55 465 65 66 64 886 1
    \\23746140: 6 5 1 1 9 2 8 524 8 4 9 3
    \\724670: 1 8 1 3 700 3 2 6 6 2 46 4
    \\169538: 31 94 44 534 4
    \\10188004277: 456 26 943 796 2 77
    \\53849072361: 8 42 71 3 9 6 7 462 2 7 7
    \\102705: 7 168 5 58 915
    \\6862448: 5 680 239 9 996 4 4
    \\56087: 4 821 71 8 61 891 52
    \\188280018: 260 57 93 72 18
    \\3521099170: 2 48 7 69 2 5 54 54 4 6
    \\11299837: 184 4 231 1 6 591 6
    \\574320039: 3 9 903 53 5 69 634 9
    \\48049: 6 249 32 240 1
    \\9770796: 48 836 175 2 386 4 63
    \\190310120618: 9 70 49 65 80 8 77
    \\90545520: 692 1 6 23 94 6 7 3 4 5 3
    \\473: 427 5 7 1 33 4
    \\283849008: 834 414 4 4 428 2 17 8
    \\1420968: 734 25 78 5 6 4
    \\11864163: 23 8 91 77 495
    \\39421369: 16 7 5 114 9 4 387 107
    \\1822914130: 870 65 62 24 322
    \\290186191: 50 1 34 4 90 21 9 413
    \\14426: 7 9 9 18 10
    \\3992: 5 790 3 37 2
    \\470473510: 5 512 5 2 42 875 1 4 3 3
    \\1933330256: 263 4 9 7 573 757 2 56
    \\391837988: 484 8 5 6 73 3 5 3 6 8 1
    \\41215: 3 3 55 31 4 281 7 7
    \\932574: 1 690 4 6 5 52 56 4 674
    \\40262525: 246 7 227 103 445
    \\19826832189: 30 27 6 5 91 70 8 4 189
    \\2847924866: 50 7 816 99 7 82 3
    \\14027830830: 50 783 74 9 4 2 807 6
    \\56176536: 656 2 728 1 9 6 7 9 3 5 6
    \\441309276: 696 5 704 7 756 1 9
    \\297893: 2 322 461 932 77
    \\53805752: 4 1 6 8 6 4 1 576 8 7 19 8
    \\31530: 6 1 6 2 7 7 8 35 948 9 2 1
    \\7174489: 76 944 89
    \\153772299459: 3 9 9 4 5 4 1 90 86 9 77 9
    \\7038084958: 4 840 30 521 2 6 8 9 6 2
    \\27975: 5 70 6 62 75
    \\1157576: 7 31 5 846 9 3 9 5
    \\335534490: 243 863 2 8 90
    \\23443: 5 8 34 26 4
    \\630040988: 2 70 7 53 866 8
    \\900135925: 899 417 2 716 92 5
    \\2834904: 78 49 93 1 1 24
    \\37470200672: 96 1 6 74 643 9 9 6 67 5
    \\1736124: 8 894 9 9 6 6 2 6 39 52
    \\7869680: 9 15 44 4 805
    \\447156020: 38 336 5 5 34 1 4 3 7 7
    \\14761454: 1 91 3 13 25 1 1 59 7 7
    \\3227583252: 76 847 1 22 42 6 5
    \\7402326818339: 78 1 937 268 1 8 337 2
    \\180366: 9 7 7 66 7 6 3 24 2 77 1
    \\103360506330: 40 706 575 5 366
    \\259: 50 5 4 6 1
    \\59315037424: 977 44 78 8 8 778
    \\111540286525988: 8 401 9 46 79 3 74 39 9
    \\168954: 3 56 9 5 4
    \\4697629: 6 33 20 8 3 7 3 65 5 8 9 7
    \\21028140: 3 6 9 6 6 41 850 5 9 3 7
    \\2137182330: 77 4 9 660 221 81 27
    \\1270333614966: 9 7 417 5 7 2 2 163 1 8 3
    \\1518169539: 581 937 16 953 9
    \\1226257202: 12 262 57 19 7 2
    \\51632376: 5 509 2 2 7 5 47 8 9 2 1 5
    \\13761434: 8 2 839 7 25 46 8 4 2 2
    \\36652742: 3 2 854 976 8 79 6 2
    \\48788351: 84 702 12 4 12
    \\327773952: 4 316 56 4 648
    \\399669886: 397 2 669 886
    \\6890073: 911 7 6 3 5 8 9 4 5 9 20 4
    \\113214: 7 98 55 8 3
    \\787574304: 787 574 263 4 37
    \\114516889: 426 22 76 6 831 424
    \\490344553: 7 3 709 95 91 3 7 8 65 8
    \\11283196: 4 24 15 50 91 5 95 2 6
    \\392017032: 33 5 2 3 5 2 7 93 9 5 85 7
    \\7736727: 4 73 36 373 351
    \\540982: 540 1 982
    \\79329: 93 853 1
    \\763474860: 9 42 6 822 4 5 2 9 4 6 6
    \\54: 8 5 6 1 8
    \\41329549210760: 738 56 8 7 49 210 758
    \\11664: 3 1 8 3 48
    \\2169144: 9 87 217 9 2 7 3 2 40 2
    \\149623: 95 75 21
    \\220739980: 4 69 480 3 996 3 2 76 4
    \\127746: 2 3 24 65 709 6
    \\31250248161: 5 1 5 5 82 4 5 6 5 74 6 4
    \\2287761: 1 462 165 30 726 135
    \\996: 2 902 95
    \\1422687066: 986 6 71 677 3
    \\157354426236: 7 253 1 74 688 3 2 3 9 4
    \\610084: 1 9 62 94 9 90 87 1 5 61
    \\80898918: 6 7 4 69 3 9 8 59 3 2
    \\10388417: 274 61 7 4 82 37
    \\144427107194: 8 29 5 81 865 549 7
    \\61515: 578 40 99 38 297
    \\34146279: 379 401 2 1 9
    \\9728167914: 8 9 382 1 2 28 4 6 1 5 8
    \\104134517: 5 4 9 752 65 6 35 29
    \\17556093509: 7 6 3 4 2 73 5 67 5 2 404
    \\138: 1 5 23
    \\147849564004: 75 4 84 9 9 6 3 9 3 778 4
    \\8847: 65 8 225 9 8
    \\5661042: 1 942 5 6 37 4
    \\3207509550: 858 63 66 6 14 566
    \\722647: 7 57 8 14 12 47
    \\13280839264: 4 649 53 39 429 494 4
    \\2933: 9 1 6 8 3
    \\2524032: 2 44 77 1 9 829 2 6 2 6 8
    \\801191452: 327 35 581 2 35 782
    \\20879018: 718 6 9 3 1 8 4 2 7 6 46 6
    \\178: 9 65 6 8 93
    \\3374254: 73 2 5 3 8 4 7 641 7 26 4
    \\15093: 958 13 94 96 13
    \\597125887: 3 9 334 15 2 5 9 48 3 6 8
    \\4661394: 465 63 7 8 32 3 96
    \\835995349: 3 7 1 2 864 7 8 5 771 4 8
    \\26987199: 5 526 766 2 9 8 5 6 79 9
    \\520177: 3 304 6 6 5 4 8 3 5 3 7 91
    \\20670045: 212 975 37 5
    \\3424427877418: 8 7 9 74 6 7 980 6 4 9 95
    \\4514904676: 3 145 728 776 9 6 93 7
    \\5168: 7 71 5 9 936 14 354
    \\1014610: 159 8 2 410 91 4 482
    \\118433: 4 67 7 7 87 4 3 3 4 6 76 7
    \\21913289376: 9 1 29 3 9 3 371 9 5 2 6 2
    \\1998: 8 4 72 2 55 901
    \\56185682: 280 8 9 2 21 4 735 2 82
    \\3523211998: 216 94 246 50 924
    \\15800687: 513 11 7 7 4 6
    \\211665306879: 529 1 4 62 3 24 6 687 9
    \\124169195: 5 2 3 9 4 2 6 1 6 8 1 192
    \\6415: 806 770 6 9 4 37 14
    \\63754677: 2 64 965 64 677
    \\241396: 264 2 353 274
    \\38766796: 6 985 370 3 1 3 5
    \\1375304961: 55 710 991 2 93 907
    \\890426953: 10 118 477 88 977
    \\16774347156: 223 503 29 647 4
    \\1705177: 7 8 988 6 438 22
    \\1217609: 25 487 5 5 8
    \\350630: 24 1 10 45 14
    \\12594: 203 6 25 16 6
    \\29996424973: 3 2 9 284 3 7 249 62 6 5
    \\42762313: 4 2 10 38 4 30 87 74
    \\1957877082: 42 6 91 567 706
    \\1535: 1 1 2 27 7 5
    \\6003072855: 2 75 9 4 772 90 8 50 5
    \\42639052854: 47 405 20 8 7 8 4 8 5 3 1
    \\62301: 1 3 692 7 3
    \\216116392: 41 8 147 8 6 1 4 7 9 5
    \\567: 5 55 507
    \\426745: 123 29 701 49 5
    \\9849: 9 1 8 9 4 937
    \\1435267: 88 4 50 78 6 2 3 4 1 4 7
    \\122151: 11 1 89 32 51
    \\18989349: 7 3 8 95 68 3 58 1 8 3 3
    \\57454838427: 820 783 395 9 7 714
    \\1831360: 6 3 31 288 72
    \\55892870: 9 46 89 2 870
    \\723110784: 64 3 1 188 2 814 781
    \\578540160: 1 96 475 1 54 8 8 8 198
    \\965197554: 6 959 19 75 54
    \\5076765233: 5 640 841 9 2 5 9 4 6
    \\358902: 75 1 281 2 90 2
    \\434: 8 5 7 9 15
    \\511: 1 7 3 7
    \\18974676: 4 6 41 34 9 9 2 8 722 1 7
    \\9740211: 304 9 89 6 6 4 3
    \\120617043418: 6 5 768 1 8 629 5 570 6
    \\1792345: 255 1 7 3 41 1 3
    \\10447: 38 8 225 97 1
    \\7032854752: 59 596 2 2 5 2 8 9 4 2 2
    \\32524773: 114 28 60 1 3 773
    \\105636707: 99 957 3 643 4 273
    \\26939: 49 6 4 178 483 7 476 7
    \\18925509213: 4 626 8 5 5 4 61 3 1 1 2 5
    \\53911: 9 657 8 655 9 8 8 48
    \\16540603: 8 15 8 8 99 612 7 5 2 72
    \\635047284121: 9 588 2 1 1 6 1 67 412 1
    \\3498179460048: 6 420 770 6 876 98 21
    \\55940162: 932 27 7 59 6 10
    \\2673431161: 220 1 6 9 9 1 6 2 1 2 56 9
    \\992: 9 86 6
    \\34751772: 5 78 21 1 3 90 5 4 7 6 9 6
    \\11754337: 532 486 2 8 923 8 22 6
    \\399393: 414 104 403 918 9 1
    \\21013231642: 337 29 623 64 642
    \\3335004: 371 16 1 8 9 1 14 5 5 8 4
    \\3363268: 267 407 5 998 8
    \\5822561565: 5 6 7 439 6 46 5 8 1 85 9
    \\242218567: 225 10 1 7 65 1 85 6 7
    \\3936275: 7 1 792 3 2 7
    \\11537194338144: 7 350 404 14 872 2 9
    \\1719584: 3 13 679 516 83 4
    \\1314269: 31 51 61 159 769
    \\647: 48 3 3 31 103
    \\341416031: 7 5 2 11 1 92 3 9 6 9 62
    \\1452753: 21 79 6 50 97 96 81
    \\6804: 3 92 4 8 1 59 16 1 5 9 4
    \\2973255928: 1 6 5 8 45 2 648 5 6 85 5
    \\145350: 1 1 741 3 3 8 5 599 6 51
    \\6276679: 69 74 6 5 15 4
    \\58725315257: 7 6 73 7 5 9 6 7 933 4 7 7
    \\198748813: 29 7 74 1 5 298 826 8
    \\4224050454: 3 2 3 4 8 61 2 1 899 9 7
    \\545644: 4 26 603 771 548
    \\2037239837: 794 8 453 354 2 989
    \\99372320: 75 828 4 30 8 5 8
    \\156820: 736 2 94 2 20
    \\64309027437: 12 95 8 375 49 560
    \\18351: 594 43 79 303 2 9 8 1
    \\879044880: 54 4 859 63 657 3 8 35
    \\13148172: 4 2 7 531 1 1 77 7 3 7 9 9
    \\375445666: 75 5 371 74 16 9 495
    \\33108201: 45 34 93 44 73
    \\2383405: 611 39 6 36 6 2 6
    \\338437376: 87 389 7 3 73
    \\377102966: 9 2 960 4 8 3 6 6 8 7 79
    \\5207: 8 1 483 856 4
    \\421240244: 6 6 8 62 6 9 9 7 9 179 7 1
    \\6833185492: 96 12 12 632 8 6 92
    \\8995831: 6 47 3 33 630 137
    \\64063: 78 2 8 63
    \\189629583557: 1 838 58 2 1 958 355 7
    \\667400891: 71 95 704 139 7 4 891
    \\535715: 707 151 314 72 5
    \\35859722: 3 8 3 6 9 436 1 3 3 7 464
    \\17619000: 4 9 6 518 7 7 7 5 9 5 839
    \\1384137216: 7 6 70 1 2 3 64 329 4 6 1
    \\153820: 5 53 3 955 20
    \\166606210: 85 196 586 35 1
    \\5116097: 56 216 91 28 413
    \\625625: 1 3 992 7 6 6 121 6 1 5
    \\1098088311: 5 3 23 71 604 237
    \\14318248: 1 18 8 61 9 99 967
    \\12041646: 90 475 818 99 87 933
    \\27827184050: 1 902 474 6 308 4 9
    \\22218206396758: 728 4 657 835 305 7 1
    \\29293466: 82 166 4 538 9 427 3 3
    \\2043: 43 4 3 3 4 1 250 3 1 1 3
    \\552330: 70 408 87 423 19
    \\2564011611: 87 2 9 25 34 32 8 723
    \\38646: 37 4 48 597 8 9 584
    \\7137998: 8 5 56 3 417 17 82 1 8
    \\44663: 1 3 2 2 661 2
    \\2277256255: 190 22 7 8 7 256 247 8
    \\1003001: 9 2 8 2 969 3 291 5 500
    \\850006705952: 389 8 66 6 51 5 7 855 5
    \\14221542: 505 88 32 8 734
    \\24228423565: 42 506 57 35 68
    \\246743: 96 239 7 7 707
    \\3160602: 61 5 9 39 6 5 70 8 6 3 3 2
    \\43848294: 8 597 23 40 7 57 6 21 7
    \\862506240: 8 776 819 8 120
    \\4969: 16 289 6 270 69
    \\1433578: 4 9 7 1 6 822 4 6 6
    \\556935795: 370 92 1 35 98 7 3 9 5
    \\438347796: 4 383 254 223 96
    \\101329722098: 30 4 298 966 6 20 98
    \\1077664776293: 58 9 9 88 9 2 388 1 48 2
    \\89178: 12 9 68 501 2
    \\13972204: 12 17 55 876 1 4
    \\169687678: 459 7 69 88 808 6
    \\339338795540: 5 67 836 72 83 8 2 9 4 1
    \\70824884424: 8 4 8 4 1 2 1 19 276 1 3 8
    \\135972749: 520 871 3 8 959 49
    \\407463489597: 407 463 4 89 599
    \\14318725: 894 53 9 3 10 8 7 4 2 79
    \\545272096067: 9 810 543 66 366 798
    \\583: 2 5 7 160 59 315
    \\257321712: 1 56 566 8 997
    \\1725165348: 9 32 8 1 6 594 53 7 4 3 5
    \\1438277: 7 3 3 4 9 9 69 2 9 1 1 77
    \\3771839519: 6 4 16 92 9 1 9 71 800
    \\1758340: 9 39 667 1 5
    \\5275488825: 50 71 978 6 361 2 4 25
    \\26053872450: 6 691 89 7 2 6 447
    \\9450: 6 5 3 7 84 5 6
    \\95311557: 8 27 7 54 34 63 2 9 2 3
    \\804519: 18 41 9 359 3
    \\66106: 3 2 8 5 37 9 8 9 936 65 1
    \\68453598: 4 5 64 90 93 6 44 246
    \\951596: 2 7 9 62 85 7 6 297 2 4 4
    \\98538336263: 438 6 5 9 832 77 8 3 8
    \\911484: 3 303 2 48 4
    \\1640: 3 5 46 9 74 1
    \\103459686: 1 2 661 6 51 3 9 1 8 3 2 6
    \\115965921: 5 85 1 4 42 6 2 97 6 3 9 3
    \\386223718: 8 378 22 3 715 4
    \\19649: 7 8 6 4 97 8 761
    \\5027443270: 26 32 798 90 1 745 46
    \\1920817: 10 48 4 817
    \\23557514: 7 3 76 60 96 8 33
    \\127832584428: 81 6 29 907 4 428
    \\701077: 308 2 5 8 222
    \\5414824290: 2 2 82 941 43 30
    \\345251177859: 639 354 54 1 2 5 859
    \\18396970: 42 2 16 7 6 968
    \\184177: 3 2 365 29 83
    \\508375: 993 232 415
    \\82711: 7 697 552 3 4 185
    \\5249836800: 4 488 8 6 3 2 39 475 2 1
    \\275554044: 13 9 9 6 4 6 693 4 47 18
    \\624: 3 6 51 9 3
    \\576516693: 7 88 260 8 2 1 4 9 9 9 3 1
    \\84680467: 53 8 7 98 75 202 4 4
    \\739388: 671 68 33 5 53
    \\819857339208: 9 8 3 7 83 1 2 566 8 53 8
    \\9710: 4 967 3
    \\66557741426: 976 458 36 7 8 18 517
    \\108308520: 2 3 4 5 86 2 678 32 8 5 8
    \\204651: 3 65 9 1 97 454
    \\2508: 3 4 18 3 5 76
    \\11483: 12 944 96 20 39
    \\2455900: 9 156 646 2 599
    \\1878400: 24 9 9 6 8 936 1 4 8 5 1 4
    \\272387: 894 9 7 299 297
    \\99168: 3 4 2 30 956 210
    \\1572619563: 4 90 8 1 8 316 6 24 3 9
    \\1293: 10 5 6 787
    \\19662: 9 4 7 455 97
    \\9368735930490: 41 815 4 74 492 77 90
    \\17389031: 3 2 43 407 16 2 7
    \\46884: 726 5 2 554 6
    \\522: 46 351 5 59 61
    \\379558743: 8 8 456 67 12 70 7 46
    \\13246734: 79 5 219 469 331 3 31
    \\6531950815: 258 4 4 803 3 11 5 9 9 7
    \\10632348: 9 7 6 9 59 7 77 6 4 3 81
    \\1906238880: 33 40 5 538 468 120
    \\115357: 4 6 753 782 7
    \\527211: 31 6 2 1 8 8 4 7 582 8 1 9
    \\1645989082: 636 5 862 3 82
    \\2396: 572 4 4 61 31
    \\568779: 74 486 2 85 82
    \\643028: 20 38 56 564 2 66
    \\1743917: 4 612 89 8 941
    \\6515470: 33 1 7 5 8 1 1 496 8 1 6 8
    \\6703746465: 26 5 1 6 111 9 9 1 7 7 7 6
    \\5540262: 708 94 32 949 7
    \\277206086: 59 4 8 8 9 327 5 89 7 3 1
    \\980162: 31 2 69 29 4 26 226
    \\3542490: 328 4 27 8 8 2
    \\652680: 9 67 6 1 109 84
    \\3471: 8 7 59 64 96 7
    \\42356: 846 50 18 5 33
    \\19653579138: 42 8 194 2 603 5 4 9 1 4
    \\8832693: 120 763 26 93
    \\4956: 642 3 2 6 963 24 38 73
    \\18061244: 50 17 9 4 41
    \\3844233: 1 9 375 1 139 7 8 8 9 9
    \\10332: 6 4 8 5 708 2
    \\56814705894: 590 4 7 278 1 4 8 9 8 3
    \\56961: 31 8 3 4 8 3 6 8 440 3 7 4
    \\4349305992772: 2 17 465 2 5 992 77 2 1
    \\29479: 1 4 7 245 2 8 6 5 9
    \\786181051: 751 34 526 4 476 410
    \\165789: 1 11 63 34 507 3
    \\118010445: 6 6 411 66 5 4 3 5 6 1 2 5
    \\8316103: 87 3 924 48 53
    \\73226602495: 70 6 73 94 50 3 99 49 5
    \\2011100: 783 4 2 321 356
    \\146136086: 940 2 777 600 86
    \\19534951825: 7 18 5 1 8 89 998 7 9 24
    \\100230: 6 94 2 2 8
    \\3663504: 6 6 4 2 9 54 7 6 6 206 78
    \\7682131090: 2 12 61 6 2 8 9 5 66 37
    \\213463262: 843 3 3 3 4 9 5 7 5 9 46 6
    \\72035028: 2 26 987 32 98 8 117 6
    \\1069: 212 6 1 849 1
    \\50223360920: 928 5 33 328 920
    \\18815: 13 133 96 4 558
    \\95388581922: 5 1 76 5 2 9 6 5 5 7 585
    \\2270164: 2 7 9 293 52
    \\5441524: 3 2 85 1 61 564 34 2 6
    \\1076: 61 3 3 4 4 4
    \\2282157: 319 7 7 1 54
    \\1254937608: 5 6 699 4 724 4 8 1 5 4 2
    \\9735: 8 2 243 2 4 7
    \\79989614: 7 99 896 1 3
    \\527207309: 673 45 3 87 980 54 2
    \\3223380: 9 53 7 14 18 465
    \\99930: 4 7 9 866 64
    \\5470080: 85 454 13 787 80
    \\564252: 24 2 191 26 49
    \\5871813984: 85 6 91 6 189 8 13 98 4
    \\80735566: 77 286 703 52 757
    \\20499203: 8 298 87 668 287
    \\12093339: 2 4 157 29 68 5
    \\16792883: 1 2 836 604 2 73 7 6
    \\977491676593: 9 2 1 5 74 916 76 593
    \\12702104: 1 270 210 4 1
    \\34581205: 836 5 3 4 4 3 3 6 9 57 49
    \\10643489: 435 70 559 347 9 7
    \\406030588798: 8 5 1 3 68 3 698 2 7 7 9
    \\100340500685: 96 237 948 441 5
    \\43203: 4 300 236 80 3
    \\322535925: 616 68 27 81 95
    \\119242816: 18 9 719 33 39 64 1 64
    \\2776175: 58 673 67 71 4
    \\7194: 7 133 59
    \\701907953: 2 83 4 62 8 51 8 953
    \\14629123: 11 9 3 18 8 8 2 5 9 3 4 22
    \\4237: 3 56 7 60 7
    \\334: 186 62 77 9
    \\8716: 7 32 222 57 1
    \\378970: 5 1 5 2 178 211 93 638
    \\2261424: 44 16 2 1 1 5 4 5 2 678 8
    \\3700: 415 7 1 33 761
    \\671175: 22 7 48 83 40 535
    \\1487916050680: 31 331 2 98 725 675 4
    \\1514704135: 249 14 381 639 9 1 1
    \\1715: 232 2 4 432 975 70
    \\52378: 59 443 20 2 64
    \\32: 7 1 4
    \\71295537753: 3 3 86 5 501 31 89 8 99
    \\34542: 18 327 42
    \\2832644: 5 57 113 2 70 3 4 5 9 7 4
    \\546019: 26 1 3 70 17
    \\663752103951: 75 885 2 103 951
    \\39361407117: 9 7 7 5 5 9 6 4 4 7 57 115
    \\1112816: 314 8 443
    \\608225: 3 37 9 18 5
    \\10620: 99 5 48 9 7 94 1
    \\53963240114: 593 91 240 11 2
    \\77831461: 9 54 7 8 94 5 5 5 7 3 2 1
    \\280640: 8 4 4 76 2 659 7 3 353 5
    \\22673927: 249 5 760 89 287
    \\1774013122: 17 740 131 2 4
    \\16021618208: 4 326 68 717 26 42 6 8
    \\130387: 2 5 5 4 6 21 5 2 34 28 75
    \\48101318: 79 1 168 8 3 3 6
    \\1541632303: 1 5 5 2 116 581 6 14 82
    \\154225: 726 79 737 25
    \\1924560677: 3 8 8 2 78 9 99 8 630 47
    \\9573007: 327 287 4 34 3
    \\386463: 4 7 57 6 5 6 6 9 3 5 8 63
    \\61654284961: 139 9 666 74 961
    \\7623216066: 4 4 146 6 5 93 843 24 7
    \\181746: 64 284 520 2 784
    \\466308168: 20 778 5 1 27 831
    \\3829539362: 981 933 16 1 13 3
    \\1289888927: 82 3 6 4 5 8 50 1 55 873
    \\34260323963010: 9 93 6 352 98 6 5 6 968
    \\1960810915502: 15 70 29 95 657 690
    \\331976860905: 331 976 854 6 906
    \\5380055: 4 890 96 11
    \\26233385: 2 2 2 2 639 81 4 1 9 85 1
    \\20269389221: 558 55 9 913 357 221
    \\2282784237833: 9 8 4 8 1 6 79 2 3 6 1 833
    \\56888859: 23 1 82 694 712 50 6
    \\1611982: 3 730 12 366 59 1 2
    \\1759460: 2 4 8 4 4 3 141 7 2 278
    \\222805681: 5 906 9 7 1 6 5 7 9 4 4 81
    \\1624808255: 3 5 15 95 4 3 4 224 19
    \\14585438833: 3 73 9 74 3 64 24 33
    \\23412: 2 971 398 7 5
    \\21366575784883: 7 3 3 6 6 575 78 1 4 88 3
    \\712636287: 8 95 5 51 937
    \\1167610: 5 2 417 4 1 10
    \\1780908850: 6 7 7 4 1 37 4 617 50
    \\55250: 4 3 1 1 2 5 2 10 4 836 74
    \\78589: 68 77 3 66 8 437 8
    \\222410760: 4 5 8 564 8 9 5 14 331 8
    \\16554988493568: 361 4 441 966 32 841
    \\1380842766: 17 23 6 1 9 1 66 446 7
    \\481725: 9 308 539 36 6 90 45
    \\31247442135: 31 247 409 33 1 36
    \\1450717: 68 4 267 3 269
    \\923769: 91 21 483 56 698
    \\73630440: 32 62 39 8 780
    \\1529044: 5 729 8 5 418
    \\245940029: 9 7 72 8 2 347 29 5 5 2 9
    \\960620: 7 3 8 1 3 1 286 3 50 6 5 7
    \\82802721: 4 43 8 6 329 52 1
    \\472539559: 9 450 7 4 5 50 7 49
    \\452196: 1 1 44 21 95 1
    \\2383008: 8 74 6 6 58 5 672 6 96
    \\435601: 50 87 6 2 38 1 3 4 5 7 4
    \\1892: 33 5 6 8 68
    \\529904695: 58 9 3 52 7 557 95 786
    \\155303680: 4 76 114 9 4 4 7 2 5 4 1 4
    \\6325771: 8 94 9 375 8 25 68
    \\14435769: 5 3 75 5 233 882 8 4 89
    \\84250: 337 25 3
    \\8388299868: 9 21 5 6 9 285 2 7 5 86 8
    \\5591700: 7 40 48 135 436
    \\42310630: 861 7 156 6 45 799 20
    \\3907126: 4 559 5 145 345
    \\7181817627778: 718 181 762 77 77
    \\114: 7 1 2 97 6
    \\5012536329654: 5 808 4 31 87 2 4 9 6 57
    \\14994272: 9 6 7 2 1 3 1 36 62 14 68
    \\88: 1 2 29
    \\37171659: 2 5 1 1 106 258 716 5 9
    \\125547: 5 7 55 40 149
    \\516724523: 5 4 87 6 7 52 523
    \\8547254016: 4 7 120 1 63 68 4 21 68
    \\6496977509286: 42 8 4 946 17 70 5 3 73
    \\202045216: 92 6 5 9 415 2 3 9 8 54 8
    \\2142699050: 4 3 4 2 24 4 6 7 49 3 3 2
    \\262828: 6 900 4 713 30 8 6 32 7
    \\56968: 477 623 2 322 4 8
    \\7933170: 182 161 80 1 27
    \\284718813594: 823 37 21 935 92
    \\609005: 71 975 6 80 8 852 5 5
    \\7664: 4 9 177 8 7 1 5 8 8 4 1 9
    \\24519673876: 7 2 9 6 4 21 246 3 72 4
    \\4891: 9 152 6 5 61
    \\34731871: 6 9 8 9 88 78 4 72 2 7 99
    \\11940400213: 4 219 6 7 6 3 7 26 8 9 7 7
    \\177088003: 9 89 925 29 239
    \\15730032: 8 857 8 222
    \\48884514: 23 16 5 5 748 13 9 7 7 6
    \\5006910: 64 88 79 1 1 587 795
    \\950: 79 3 621 88 7
    \\1081631943: 5 739 7 6 9 7 2 6 90 3 7 3
    \\114117: 8 7 89 7 94 17
    \\2364516: 67 8 1 77 308
    \\121264948855: 137 910 78 9 977
    \\49509: 7 1 3 72 5 1 6 6
    \\831885228070: 31 996 9 1 692 45 35 2
    \\46568189: 2 291 8 818 9
    \\569680268: 831 34 537 646 629
    \\1544813181: 9 461 92 6 6 8 29 607 3
    \\638078: 637 44 4 633 1
    \\4399562753007: 5 12 6 726 2 75 300 4
    \\13364: 47 30 588 363 13
    \\1064634076: 4 2 5 85 7 3 3 5 3 18 4 2
    \\639290655837: 7 9 4 1 3 117 331 9 80 8
    \\672708: 5 87 1 9 20 333 46 2
    \\1373522976: 4 19 997 97 2 7 2 68 8
    \\30840121: 3 63 9 89 33 1 583 4
    \\2560185: 79 5 9 1 7 396 3 79 3 4
    \\22388150824: 4 5 6 27 319 4 1 753 2
    \\4314628: 1 6 1 52 16 3 4 2 6 47 2 6
    \\9774960642281: 701 71 3 327 71 2 281
    \\2516788936: 459 596 92 99 38
    \\62838: 57 5 8 3 8
    \\1718832: 2 96 895 43 1
    \\559683: 5 1 74 7 5 4 2 1 2 6 9 27
    \\63466: 37 7 4 48 5 4 260 82
    \\995672: 86 87 81 79 46 65 2
    \\193009700410: 5 5 772 969 18 86 11
    \\167097580: 780 1 42 3 51 5
    \\1476176: 9 53 392 607 176
    \\6416866958: 3 558 9 62 33 48 20
    \\2330944: 23 2 9 960 983
    \\2411883980: 9 21 223 73 3 114 38 7
    \\2047338: 2 909 78 580 9
    \\11510262: 9 62 316 892 26 9
    \\2643171379: 5 755 90 5 2 7 7 79
    \\87781: 2 5 9 12 8 15 46 6 4 8 9
    \\10228522: 6 96 2 852 5
    \\11702763: 86 81 7 585 691 3
    \\5144841: 211 1 7 236 41
    \\6088926: 5 2 709 8 926
    \\21656183: 7 3 652 4 186
    \\47638073: 7 9 708 356 3 7 24 970
    \\29882356081: 3 59 21 4 2 980 1 7 4 6 1
    \\49010208: 3 631 1 39 346
    \\1337526446: 47 87 56 994 48
    \\6239232904: 6 93 2 4 81 90 1
    \\1438200579: 3 7 5 36 850 3 1 4 4 9 8
    \\34066: 5 2 5 94 9 5 38 2
    \\1057: 9 128 3 8 1 410 217 8 3
    \\676708124: 901 1 2 555 75 5
    \\33205: 52 7 7 44 8 5 1
    \\66709: 61 7 5 907 413 85
    \\2475718: 6 5 14 82 7 7 4 624 6 1 1
    \\7578683: 748 8 2 16 683
    \\786430: 21 898 949 27 415 5
    \\44135460: 9 23 5 6 7 8 5 8 2 1 6 359
    \\1518946204: 166 6 9 5 4 1 565 3 2 4 2
    \\1147031: 6 2 7 2 1 8 82 5 291 1 9 2
    \\206732821: 8 934 52 5 89 61
    \\36449490: 4 4 96 6 40 4 4 3 7 9 1 20
    \\228783753138: 7 772 448 9 86 1 35 2 3
    \\86: 6 50 16 5 9
    \\1235045568965: 722 3 64 55 8 619 6 43
    \\712856718: 710 93 192 1 5 711 7
    \\5968984: 6 2 87 40 8 891 52 38
    \\517974543: 899 1 2 57 4 8 8 23 3 1 3
    \\74817: 6 6 8 811 6
    \\282697802451: 2 7 221 9 6 7 290 4 90 5
    \\271822863: 3 254 64 243 531 68 3
    \\13512: 19 23 6 7 11
    \\448211577679: 9 7 2 786 5 1 4 1 3 8 6 79
    \\1968308: 98 2 250 580 8
    \\60939986905: 132 91 6 9 2 2 621 41
    \\4774983552: 4 99 7 5 32 8 9 18 174 6
    \\258648: 33 3 887 7 439
    \\5747901413760: 83 2 5 3 7 2 66 120 874
    \\398710669: 9 81 2 645 63 49
    \\4389: 2 55 77
    \\21212: 4 265 6 2
    \\6870: 3 3 7 9 8 3 2 77 3 9 4 930
    \\42565865: 96 301 442 2 87 734
    \\36842511: 491 75 9 8 509
    \\165093115: 5 330 9 311 8
    \\194448: 45 231 9 4 521 5 6 6 8 1
    \\94388: 94 23 8 56 94
    \\149952019: 22 1 43 640 18
    \\5989030: 9 144 8 7 699
    \\921784868160: 30 3 4 42 490 1 1 32 65
    \\124045837347: 886 14 58 37 342 5
    \\140597144622: 28 40 71 80 57 341 6
    \\13288550: 5 9 6 7 56 3 6 1 7 5 407 2
    \\489624800: 65 4 887 8 800
    \\31824: 53 22 47 1 9 1 9
    \\9761568: 16 2 5 610 15 67 3
    \\5400210715: 4 46 2 60 2 332 9 9 754
    \\30660861688: 8 8 7 73 8 5 190 8 22 4 8
    \\10629: 32 8 6 3 771
    \\20252735: 441 7 4 509 9 134
    \\2560350: 6 73 76 38 61
    \\7806036: 218 6 79 84 67
    \\360894478: 3 2 37 14 5 7 7 42 8 8 8 6
    \\27699620: 92 29 3 39 3 18
    \\48933: 39 9 933
    \\439188456: 2 6 3 66 4 303 89 6 97 4
    \\3058662635: 30 582 4 625 6 8 9 61
    \\514470819: 69 46 8 9 162 74 1 9
    \\1362: 160 7 239
    \\8011206990: 84 425 243 762 85
    \\67314: 7 48 4 3 2 28
    \\143: 2 7 10
    \\77330133: 6 45 123 863 4 4 8 9 57
    \\14652470880098: 8 9 27 3 3 960 785 92 6
    \\68484217991: 796 48 907 948 263
    \\8888898: 634 85 14 4 994
    \\12403276: 317 6 96 4 79
    \\1545635: 18 7 72 223 553
    \\66790: 4 3 3 9 506
    \\22531835: 17 2 686 966 851
    \\26907: 8 640 261 5
    \\1810285: 112 2 49 466 79
    \\268104: 7 8 8 5 7 1 6 751
    \\42855: 7 13 9 6 21
    \\445: 44 2 3
    \\8047: 3 60 4 5 381 2 85 1
    \\1021: 23 7 6 256 585
    \\1064: 6 1 1 5 2 74 5 7 1 13 71 6
    \\402479220: 40 194 53 921 9 1
    \\589455408: 66 1 4 4 87 2 2 82 1 6 8
    \\33724689: 3 844 371 586 8
    \\179340: 8 911 46 20 200
    \\1210205016: 7 68 7 3 70 1 3 9 48 54 4
    \\9564: 3 372 5 6 4 3 6 242 4 36
    \\20285637: 25 5 2 4 2 9 9 81 59 8 93
    \\94121829: 98 337 3 551 78 5 9
    \\2922: 15 943 16 3
    \\16854333: 87 9 4 6 3 607 7 5 32 4 6
    \\7846808: 8 34 727 2 5 260 5 6 8
    \\366220: 30 8 93 7 29 56 9 2 998
    \\232546579763: 5 40 4 78 33 770 44 2
    \\1364793638489: 5 30 9 1 562 2 41 31 19
    \\191227442: 1 558 6 6 57 3 6 485 45
    \\31440: 9 38 1 9 953 3 3 3 9 4 2 1
    \\563024: 639 8 8 11 1
    \\968436: 97 1 61 9 9 2
    \\54483: 883 474 5 4 3
    \\35696: 92 5 92 1 4
    \\48802840301: 610 8 2 840 304
    \\4640985990: 94 2 6 4 4 7 2 8 2 6 6 264
    \\65759: 14 58 7 8 745
    \\93478: 93 48 1
    \\1165: 89 22 9 39 7
    \\5626467081: 6 35 7 15 68 31 6 9 62
    \\25705178: 265 97 178
    \\96427474: 2 4 7 926 6 6 865 4 7 2 2
    \\95871699683: 5 9 7 11 3 5 88 3 3 96 8 6
    \\2461274295: 9 1 5 54 82 2 6 77 9 1 2
    \\75444566: 443 96 281 92 4 5 68
    \\1731805708: 91 62 989 189 785
    \\1725: 542 2 3 18 73
    \\3322698: 55 3 6 4 583 80 4 29 2
    \\217862649: 2 323 3 90 4 69 61 9
    \\299653325193: 930 6 92 35 77 5 7
    \\3245407825: 67 78 361 2 575 31
    \\51713982: 1 29 1 348 39 35 529 9
    \\130867: 99 9 4 1 9 42 36 727
    \\393375: 96 7 5 38 7 5
    \\9640088670: 7 38 7 549 8 1 4 67 1 5 6
    \\27977912: 3 14 9 1 8 3 1 1 2 656 9 8
    \\22015896015: 9 7 6 5 5 3 2 965 7 60 7 8
    \\59170: 888 6 8 6 78 6 9
    \\252687: 1 55 349 5 11 676
    \\2688762662709: 233 56 447 969 461
    \\91885664071: 7 38 9 2 84 8 8 639 1 70
    \\70719660: 208 69 284 5 764 33
    \\6090205: 608 95 50 567 89
    \\279814: 5 9 659 842 2 76 2 9 96
    \\13035: 5 6 60 8 165
    \\8830: 629 98 69 8 864
    \\164203534: 3 910 6 1 1 6 1 3 3 45 8 2
    \\1180515208: 3 3 5 12 96 386 91 598
    \\201379689098: 6 3 693 342 63 50 2 96
    \\1081964: 7 7 951 81 964
    \\8349602882: 710 4 2 7 7 3 2 78 9 1 4 9
    \\106930151: 8 1 193 5 3 9 7 4 7 6 3
    \\63797700657: 6 82 9 9 21 5 629 8 2 1 6
    \\19513155835: 272 15 717 8 37
    \\325472: 1 4 53 8 4 7
    \\42251: 61 68 8 69 2
    \\950015391: 1 8 9 5 5 4 999 7 3 6 391
    \\2488834474356: 8 9 3 6 166 1 31 45 3 6
    \\9609639416: 901 7 592 63 8 1 418
    \\452711265134: 8 2 813 94 44 87 4 4
    \\3163159356: 12 345 949 27 3
    \\520669356: 5 78 512 7 9 855 17 9
    \\21850454: 910 50 33 2 22 52
    \\2735378: 7 421 2 52 460 218
    \\31544: 624 49 12 69 887
    \\1785141121: 3 404 263 4 5 317 6 28
    \\3813649: 55 43 545 895 7 7 9 49
    \\125764604056: 85 4 2 6 17 4 6 470 866
    \\5353720042: 6 2 55 1 8 3 1 7 2 888 5 2
    \\2046728: 1 64 6 208 8
    \\12731308: 615 115 18 6 799
    \\75530: 83 1 1 70 13
    \\5585555520: 445 4 2 8 530 74
    \\60290: 7 861 5 3 9
    \\6005643840: 6 565 16 913 3 5 7 5 6 8
    \\13786986: 8 3 846 7 3 97 278
    \\541296749: 737 8 39 641 8 83 9
    \\677: 50 5 514 99 9
    \\5929: 1 41 35 24 970
    \\133575: 3 1 8 970 66 552 2 207
    \\23813165: 25 7 866 61 1 53 5
    \\321: 26 7 48 40 51
    \\7572679: 9 1 4 1 4 6 666 601 7 2 7
    \\21428764753409: 6 3 6 6 566 4 752 5 9 1 2
    \\800864113: 6 3 8 64 682 3 77 377 4
    \\581925765: 2 6 169 20 7 869 576 2
    \\11566767: 5 102 9 836 99
    \\2124521: 59 5 8 9 29 492
    \\44315624521: 39 5 4 88 833 24 519
    \\73836378: 424 347 58 3
    \\6324: 190 54 9 2 21 12
    \\41389305103: 643 190 4 99 44 65
    \\2264807129: 7 4 7 6 5 5 3 98 4 4 9 13
    \\9834346: 1 7 128 4 66 1 344
    \\8041812452: 1 44 89 555 6 411 4 52
    \\359572559043: 2 870 6 87 3 3 5 87 80 3
    \\619646: 61 889 71 4 3
    \\30132: 6 3 818 2 2 18
    \\3867753588: 82 818 955 71 45 395
    \\42019719768251: 2 95 1 614 4 3 8 9 4 2 5 4
    \\67142400: 5 538 4 312 20
    \\4859: 35 78 43
    \\63062582: 76 975 6 2 585
    \\66641931: 66 625 7 9 929
    \\7652445: 19 49 41 7 2 2 365 78
    \\49162643986: 42 153 8 9 5 3 849 8 8
    \\8804602981773: 38 662 7 5 298 1 7 73
    \\4113176424: 892 50 50 2 8 7 329
    \\1117038228: 2 797 7 4 8 3 8 140 2 86
    \\13544236: 281 482 17 19
    \\69460233: 3 1 193 6 465 2 8 8 3 3 1
;

const day8input =
    \\...............3................d.................
    \\.........................s..7......i.....e........
    \\................C.......................e.........
    \\...............Z.......m....................e.....
    \\....................gC.....q......................
    \\...............Q....s..........................A..
    \\................................s........A........
    \\...........n.....3.C..F......w..m...d.............
    \\..E...............3.....m......d.i................
    \\............f.3.......C....d........A.............
    \\.........Z...........................n..A.........
    \\....Q......p..............g.i.....................
    \\.r......n...Q....p............S.7...........O.....
    \\..........r......K....p.....M..........7....G.....
    \\....................Fs...................G........
    \\..z.........D..........G.g........................
    \\rR.............F................M...............G.
    \\.........I..c.nr...............M................O.
    \\...I..............................................
    \\...................f......I.......................
    \\z.I...............f..K..........0................7
    \\k...................K......u.........O............
    \\.........Q...z.................ga......0.......o..
    \\....E.5..F..................u..b.P......a.1.......
    \\..........k9..................K.........H......1..
    \\.E.........h..........................0......a...H
    \\..........9...h..e........i......M....1...........
    \\.c.............z.......................j.........T
    \\c..D......................Pb.................2....
    \\....................w.y......W......j.........T.2.
    \\......ph...N..................y.......W.t.2.......
    \\............9.................................o..1
    \\.................Vq.......u....Pb.................
    \\.......6R.........................................
    \\........5............w...a.W.............H.j......
    \\......Z.......Y..........V............H..2........
    \\..........D.................v..y.........t...T..o.
    \\.......5...................t......................
    \\........8k...l...............v.........S....T...4.
    \\......6....U......PR........b.B....y..............
    \\..........6.V...U........................L........
    \\.......8.........N....4.Vq.v..t......oJ.....L.....
    \\N...........R.................w.JY................
    \\............N.....................................
    \\.....5Y.....................................j.....
    \\.98........Y.....l.............B...........S...L..
    \\.8...............U...............4................
    \\..................W.........U4....................
    \\...E........l..........B......................L..u
    \\.....D............l....J..q.....................S.
;

const day9input =
    \\1420246358115615159448658011444034495988947721324334285442101229872348312916304522703197195345597061772498605363984239553957302482663677272169494831829416248712671165699481784932213134289985741163494280789480479566522614248850258942381644783457519121322691625912162966151573446347716888172178835864207415862988675063532764201551877739539780656275351285822099801016985868354345143852172578669575251095812923575441842416751934692375928613673089902851511854338578603039415599771176117175225571201228261021752018208031608164823996213963751160129384296870382454451252975639885818448121584462462423691177228380776690488310495836869661942368339135556430555519746538388990398225583467258510344391474773468611572681443149442135549575213556246042284042718563921893348430454242939927932771507883136474815797505777306180654149942843738320431255218813199662731416966422433693905463654151183292889587802152844435264889768933495873809367868768364350748862158480666660439389802019531176214064326822731886882340748097731171958624497428803293956951988943755317512235729227683040988980796972587276164636243939913281668472626017911675661796847234657111626675637011356917382164631462841924506584655242774444825331117416699059989984271782723797405879607052478958401256663368423341925734509962558156409927509152243841364932184341567110578193311666357321583116298085795045224983174545521666718615821114618990275712427511143939243740737832839392854511609161537215747275113555443411529476289661744326821035264492127551951114517383908866582171567310446743764856482080844561498270495184494590404132431630913354845048549025914174812788965949279926438880869364255976332982739734468485832732685645602768955676445825678398575257105422519550191782348242617978302732909774763751143314899837865630733451927556917617754768126230768453658921645313899437435537592394103876919180255131824117889510308861935148617546785982652435763342524427551872589658297392116253919820634919263740521953136653228245492133308523954433154011885995539589114794194084504792499286541442397317118367608895697628647452677975783881808651853437533684834336694641407967312888598326303555872185785368737959969585361263251390183578212649239446154731565868903919645646492371242936497077419110765896276830537444368793119074596190624057924796698495999050478258303876328219794587103036697448576254969116175019313867198357236558746867789534391423878176352160191498532672812648236463811915342988345083659925471936517128453286685061181612416367469481807921688681857234535981552321613739501127923618472172618087955132369554754074932725974332514617723947402620338322363565947361447544131336855954579648511776573729811331594890432475632346995134986318579626758812843017298662189360368350486313755749822583127122652695463699171544713532639563393481591524624357385963803126177784432249778943549048821054307180798931871582467857445310285997654575334951348323531124935046362043442083702279911822843573769013859176608579706932994048133621167172595781616181679456871992969876374469521461269235906997502859843434996061928192352975157134996794699385837186712676321512714290169542989134971770354543567751279692255370599797776673475330942148988158841096424041653170329959576254158525543165529828983949658137281696206455435780297120539841202565907467892113712491538288304431542551928893971063997395127243435352541828223395641694417577214440396750311610701196896484658138329984467559899033988265516568477978429556275586689057148864108951192660958337831355834644614077813978724378596857336136958374175327875378946572777334453552558741315234226224775228208274679888421160341478801315185214887463654542581221845133809889801478493181345830385082584793943976943780277668716663684794389862832325943116785725936223833215315810746118137498625420463672186650508638492136815147772033106760934472228557794949987428155526192819236061693972505454629125365556235954195272207918619269803955771513604155899231436452139366262496542611399439305398803271706090478175737334417937922783226932549577422964796540941829553615159550605129294744393765978693552310715946819984593765361970802451149161535562786832882372481558758154174551709472404897556154886199527776127921174262403629506998166457985336604095636551639016935052437858862383504316322410775528616557928777102191936194837349606854789552439241178744607361833631776714269765621252659479685740292245782956706666766524561171746179624251711732966421435541696670625621339885873264598736475679727964933860189239167685225049219787652461556810682066437116395045404354301017219667967956113683731493998353363697778848686353768290967819681891784857966078428522475614175266799281595010497669522337563952687982142725801585625436938710697851496948443838865444268183736243553210741867446338624746471690891736747075849843925760176955566919826548966854656151649112309893647127392546618090246477991626587287269683606637711267387258561482712981263735598358244470224719123756309996961620263616459235629760153083474428584920308349182628635267812322117013571019599135949264108295134998635783184390242759624957262539717936755221825091317776216382942528314321296854135020351588544599714348182778341613298878403726554664733198668560603477729755642051261592584095493179869877411792946391855333781777607827716499345441421598753822862136226595902372154830777228111045756448854496757629391949494472689310341080978645507962421582761070727042388258958463876636338723231083205816158835731015859341528553452449538297728058105979613997406715282199657960622899243898237555255392175676211317371049157851923659782486749292795226425426674710279948933978306282994742397213902643143497492652697921106075131089837025785836826079223120728962633088105939763627341087417546581876446648237565396049872385567854477314952130481717459279308763805121443487117688108725545250506181314754393587564629697623538478318439709781682111145830595184539195113175246524517717743584495949214253843825688993775081355036314390143685154439432689925952876760118361959592204547174191662954328988976379326978856733829265573340251964965024611391942832718828535961665657124755769986884022722576908646549357251710492186775830848434123730837655452918929425681815716512812540823127443789402436741972185620125715749749297683419779675142881053327067539217767512251469892850696121716588293897112276405090412483245859427411829964522723787550208272787010592591979096598676672676512726108248507958133517617798866698362932328789556416601795355343648337725554686455674863208696112499843583881637498282329358665227771578359599585921707169544991451280641431548039203339879339742152733130603170762578877676524029124668822183335341457876365090974662893519266429465265698761722333934737255345583340576469121019663064825168726217933753592818198792746353544544714651857963871888111117415813254420994582869032512720904643706517963120546268394762337428127842243777303047565513609483938335174077712198978463725448927666207935402366964065965311707026168567964329667035643123442256627527386313258053104479951236413889746694863214741270256016769719831197334526846777317383576045568159501813209655561724207486527532258773919828317668376799381526428339987856289142683639194986186397684287441311797372376634285071795670586493788268275176892738566523161478164180643980226463319541992963379794165274917695868315612628775158687140637145903871483973169840532893833765325449816922828089105564835452163477564956851824411829534013504350875540362381295922411725336065678784979346506060196735363738295639921011796118311286874359464314581034423329608337116621793017546671745534217586669011555898983682957659557752914468662973735017206425102964479587671710281612817822602313915615271130615984104549887890553968483558425233476166727049949034347389784471435150594739432196866710516389728060186637183371519834203027701839667592789785113743657889862667825428994171108558643443281747866027918989619968936957597549227960998312138227273854643423972877266963288659676240275292178881178031768486541841137672507146806093535674108264587494412535526975798633414650983960976222235430304555396599756673494734174973391151188453507792114318764028648695445523298524985565778763623691441046781584634312302944781256459871619829148844657555736884461436806825395185788657612511918892101273146463197539125542418115626133561718777142328663902441632785314858353363336824558334231163965197651443536512835058212892452990447745567611545577881596414443125052403564444785397264512446912070592741628583337575892749587420287359757696183428459518387897771863565941185792285542248526328990862941653354795528359835758316564452361655644142318889232588815594861367795044188717253363192874516351816693682230985991801589613286265362445723751360411543761890746057666919585274225663556425978510531871697578409712593886814359248537843635882172963014178727349558721430969993536442312247162280831666815559908242483416101341755491423842193467442623171431706759591886666129722775105137617545502015109987533334573883828630265063658444465288991986601053105473227284608891915240949782486842695176889131805539816148522376852454341422529656245065441937162783785150609677301483693668583662985273321242995157798468264942972282998787784952748376431239844663696993733186288746524194808251528423925323857042282181683013891798186254636364391664705742612479304793229953263795647897379563117891103188565558183892571312279056133824253416399371639452601790637918919536955429319053364141692677482013552445986511416945636317569359919313985647398736139682638331335886479129458328279222602767981774162182638866478321548138481954175256321363116320133922282066555542539387958718369610435915399914399648395415851226439818469488816868942690881769825218482558986936579340392522198915799569573869189312889294809671806418755284768370934642702644794657225575488123877082206490724494989948334975382315793337879230706719347879714735756325942585894331933380728864325227567688643625106932131811844987816262143396759885978691152710602927421567458092683327732572128025191315267434518659647112609750227895419229665824143741467158781393187220608557727986382631132870409536397172591315799263938172972183607078329638561415977117581110235937216460453422724246686718554952516384363011373549106660929599235945612343794470824130381095401756916170322235147250391370865230356995478149204624673041396120127173999699235923642466109751393181569629435249846942418225701636596734191029479246234553263549937967553189397656783925631233104660647537745371224646586246266842497923517528688697384970836838463053903845338067346363381461643065997116279317872137708496393449736097717247959148761064635782848058624089232040115023545531885132763117909038941419864788137958232040637257837070619145909513863957587675959534296661314340178931787299884633678041548575729726212423748076256763257761403825395612148522139336149566662015552444642820278789197876616025835141737897747063749787906040739789658524767463524125588772211492159976829383728566541474583983874383306039782976756659333346173734845724694835407665492443457561373340354537769175609729667373299665541341444241954972925499618658684640623423635716293531362373962969819715851540377829394987372036802230192932255329363249205554238365762831655450455178322082382665287956398139246784431077402161661866205761372241265813852935475984477128906419544799732918891436308557504737197849766140612036418990125132251327307974305537905177527442707664894278955919173922114499667950633361361837987596568572326984131623236356371826218298492278152557485232726264217518219617755446566153129552162985819529594489557831641937577156377933222055848441726348893010383177335853955013221221796252297795361212682559956330477961289090715116757634422370932653864016646460997595632421187489973666391639287422686484274337637275894850547945882267552194561764526643617386994165826168122747134883594987714763735351136229739279859419903019364121489119461495601057612275452438604773356472194115869195637121424867147785182133417460755060563825856344445453908735568664388073224755869870387613599468962319585255975230436344132736747723819738407483612692668796283542979586261331194622265493851459921123376884614186592576365638253124925141802514209493504789855338346851507136717336571350456943924929477359992151477661466361401174893748538318215756684783868043466237866687345616836542874454948913839196445322211290487613766241693610705337798593471326623724524361675277459910857986716628511859891162858689954564951531182050715737108761756039704835787673557628536845592459392398159896773144704285179875569458238133968246824416551122778390752057452289497613275465147066236325814551834152203339351677232289342344431271251244757332373629384943267258237219396373903884784074227368895122205987807344943172155753609394293345138216568320755361722516803277856644202572325890531383969633918679881495802520739297716127304854508516555590591175443438921588129036131215373941398119735326703440959664124549882494346311297458433799869220363442274529467334934779164072794826972081282172934937941547508310681455179140924761924297779313242566686213189714599224701146392236859699518832913028414027786196558028264098338398894248269199945863564586841979364243197724502169172379778934837558569958624070904180947938666481938594865279296116931612575736875422629558256448366222113972252740918693657897169591365335237767382385361869805627671719899878631418754721605130186762847189128131603083874372611182578326724033942428367697218199937180774877103590488315946499294762243079472858624592432349972170614481853030374432838333457464584571833416246842551345259456308810638037157285868399774398566853492777831310293121363943478954793125529864746038193997901580737456789220351953905024847765259183215773703877963540239556975650325591881170582367824595763515647292898090376691613581627596658089383747291380484996751869949841443227963322435334375831233561674573323291259088844627719336776833302015319080229527114476695448565348328552316454174662355257812595479896279431161846879751485896778497388515295241138369952529662756604399663919657677593346251177308780116590847836718024724491331155321419373278812324486522446255956384211058588066352446929637778815558455373618316523878725506048136178102889626456566696944082308025743115314125398937463141423646306336935424211568384744303532573711883013923174152923731867951199514096375826481378929866358384884853864375825368411887412588923920394644294070592260458974212937633244369176635823632758666858288319594114229015838076482760948642425221356669249067343716128872887470663867854764865229664873192662927529132867246641304435472171434058747987366327829713717378977298401694639342693190214515742622271165949121516319264277113535234412328834732938406648121963825753275480442344927051527654211749242327352492686963965689676262329697139968287784705130436518131797648533936387117871952725369657266084536053718856922214157239355994297076582869713392707362182122445446795170424292911060132783569665634654132742669383634910253835123043579623168618417964233639435941478757226258239596899396501371506697901844812215925061514236128547536222412170825273438053103494437627895033726628861128272749255012839030775760214033934080975426559590738943594227823468145646359775763459772151637842758587458671417627183222612777526724814252966611562055287357925442316972176376582266422529746561629641673332981894836628878145343673225186266343311488418447834178123892453057724052141417839078362280806027541726105084575430203199929930345811453991199137793445671224228144563861357281251177223823264877703636381388177097721935408179183069911388153559457333719950713642262678682471569841235089992626573275186772153339742636596954441183815440992252682019769695723956151737575963287483642772537750674916896651586727738015744134614282363538598789491979939234548878776568358566544046515312151096987138378283845390859017785744648068828289269417195574776879363319633465914437811963907895314472348161401558425785483364614629191155313529908762591197745719769348697088587813237118656432546565767379681997355720812879675597381390181562755735884131568012672184889837459576205247712381671491716164189661592868536220878550212541457554721010717592236596445866131763668227786016431039372193373974441195875331357937887315832962793093555198117576507754132782527087575319394687317033724157932516605158246495308711329547423681497740949452526770163368945323893955487259934043776084245287397976719551321716318715713145305533742961953850531023369689131317364839202623721764622341327659502758974089963190554942649211116524426328313964652792324816299751945165436269996766616834271510212513458083587957946636874789917353708948553977171366353380804464651919637548926834101661878514119456886621341871931473599133805128806045766950145155505920365484174155618267936229552221256391182689286761726486216835441132808414597163432735781338949554469678472977715031298099749134997289621976208771453220267372589182283239451688998313267144569350902240294432988753894470295264687520424681938373562583255087728048259486239828201011689362408993151923485059166515678355491249203839723542685231672355317887701364357364291057925358382213233115998588502139439254819724365210803961716361637539643043423872465444912088997045124130908128257743473852809588466519438540878296825324489791766863851416985322919434475852941289437076454457289368459781608231466229811171669040558273597389503773367069235930616934594894961644595413259263846682536050914225489073921278301285287954384979131443443160904191271570259579463165846837435638169486932322767274184410973194617423866270644184119489885043109983413936815116951075127142958587241370845153495134672682965494716774598495653618359060457055474614846939855341795562979229875696693615849190718214803264443365555989802281265585716036477169484550368999708869656620915978174811749686273833742215429246928335134973616515181471387410209869106639888222281911802797104175102675132653156178464879134467294066757528578262652940622847851259646956963630968171433379914681375198178433612219973564165898511978383347875765575457987625524955411012808126233358866488574062442868717020343860199479835222176175761443691778659298981522446553836113225794899491951510594320683094766166919227419357671472817844706336785121777294724923785873928745584314102095172047187418403191691385578313608048919245673414549041176038133693431134526410248938729310451149102827617021943978507196705728102023546813604387158811377033877564395769648034809735725295504136591337159267437978807282239283794037144494805951788851397035267913754771464488191599396486218395445482719113287323615771898397109494321892386889637169802258299549859468199348185562192591632631754744509994475040452073993287177379141176649319639551445596241579766687376132489914242595548143696839387884965284259285417764994419843138837410237666442751643280853825773164907823603879294177304828483889294518353849741466622511699639282528753081971025679059684139621580777095535071665360195392182338452355456325162494112163704582961090789956618294461621183165312012479971818266781133902743264075584598852476181696428115822270792156614162327397253668556680558847128638979119257039153621696172449580508466643582525932856254648092971728523580594883843762631791394775222511139561981663278692757947397710692890676374549346494947554118916642868131604328267111246319248681869188106257323960383726753049618841475259118344315171229062565073611988469446636358642631244852895995712674263476244959332342419456972371545783542585463680672898319262681988976290329434971665767764812813239143469134712365698849924813752866945770404360409590222442934070511212675868453399902633234396957788254664471017743955489859253164198729519529126271123062375274655655658823412220584311234842422182425177618798753752356293808648295847997585108235874317255216557592221764772915913935596776543461204274235751557587966151396590256874632199884125895050694345104663433065639540683465626089252043238261305597498210971620486645442193609163392269961811809267582273395278917044741924125254872395423736798078861933707673975793627837826662928895577044965024401275454875647251476140548455105693954641417
;

const day10input =
    \\5678970120787667809876787651450321789810165432234561012345
    \\4301787431296556912765698540341410786728765501103676545434
    \\3212896594365443213454501231232545695439154610898387656946
    \\4307885785872337801653215432545694321089043781763296047877
    \\5456934576901236998740126721694787899676112891054102137898
    \\4327825676210365485035432830780146788765208982567873223703
    \\1012010789301345304126701910567235623654367643432984012612
    \\9887652105401253213239878323458945514545106543221265698543
    \\6798943766798760560145569850179876408763215456100896787432
    \\5212237854899621056776457763287654309854580367018701656501
    \\4302108983014552345889308954390101218345691278929632540987
    \\8921321212123467496973217654321010101210782987834541231236
    \\7010450908765658787210106563898110567623458906543210340145
    \\6524567849434349872323293478967223408988967217890107459054
    \\5433008956721238721494782566554310510177654394345498768765
    \\8942112349810101430585691057431214321287656783216321659056
    \\9853523658901233549674541008120109450392345654307010123141
    \\6765434567890312678234432219078218765431874309458927034230
    \\1034323450765403510165498348569341016210967218567898985541
    \\4125614321877654523276327653414452547893458967898769876632
    \\3210701234988347678987014512103963458982105450745601896781
    \\4678890215679298689898101105432878967821123301234312765890
    \\5469810309100198776543239416001263456710054210126543454323
    \\6954323458210789743987678327122452349821269329237632670110
    \\7856542167345679812310565498214301265430178778748911789224
    \\3067630018901256701423457012303210178923476565652100654343
    \\2188921078872345690501298989452121089012383418983434334534
    \\3298934569863418987632367898763011298234592307894521025676
    \\0387650101678507876753456501014980347105681016765601210787
    \\1456343212589216909865401432325671256501789823454782309898
    \\2341067823410365419872316543234560787432328987123495434321
    \\8932058934321474321891027652101765698543212656016596521030
    \\7634149965430589890765438984989854321692303443067787676543
    \\4543232876787672763210567823870143430781054512198971980612
    \\4687601045298101454569498014561034231278766503456890121701
    \\3894523432101212343278307601432120140389107652107765439890
    \\2183410589043239852101212587347899655473298940998987610141
    \\1012398679650126760120103496256978796554567831876898543234
    \\0310487778743245679833210145107878987143278722365687650125
    \\1223456899012632988744103230123217610012189013451232105676
    \\8346543456598701279655654389874306526323076567600345694789
    \\9857812347405654210346969210165435435414105458912256783238
    \\6768901098312343981237878301456521056905912345863109890104
    \\0345650101232107834369765412347678167876801056874223454323
    \\1278761321943456125078098943678999101210760767985214567910
    \\2109874430854534076165107834567783212323458898876307698876
    \\3436543561763325689234256623478654323212789954343298714565
    \\4567612675610118763240345510569823434101652765210134503443
    \\5698203984323709454121245432234712345612501897898325612652
    \\6782100112345890365039876101165601016780432101107210726761
    \\6783078201076761276321276543036523239891569232216874835890
    \\5894569345987457889430389236543210145652678740125965934701
    \\6784578896590356996321298107012301276743245656734014821012
    \\5693678787101243987654301058905434985890130543876523498763
    \\4542109843262012276019012765676125673981021982923434549854
    \\3432101257876540145328943894387089012832123671019323676345
    \\4309210369901234239457654703298976326721034501208710789234
    \\3218765478710123378765645612107845435434345212345621678101
;
