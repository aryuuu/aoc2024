const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const file = try std.fs.cwd().openFile("./input/day3.txt", .{});
    defer file.close();

    var read_buffer = std.io.bufferedReader(file.reader());
    var reader = read_buffer.reader();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const should_run_part_2 = for (args[1..]) |arg| {
        if (std.mem.eql(u8, arg, "part2")) break true;
    } else false;

    if (should_run_part_2) {
        try part2(allocator, &reader);
    } else {
        try part1(allocator, &reader);
    }
}

fn part1(allocator: std.mem.Allocator, reader: anytype) !void {
    var buf: [4096]u8 = undefined;
    var total: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var tokenizer = try Tokenizer.init(allocator, line);
        defer tokenizer.deinit();
        var multiplier = Multiplier.init(false);
        var mul_count: usize = 0;
        while (tokenizer.nextToken()) |tok| {
            switch (tok) {
                Token.eof => break,
                else => {
                    multiplier.updateState(tok);
                    if (multiplier.isReadyToMul()) {
                        mul_count += 1;
                        total += multiplier.getMulResult();
                    }
                },
            }
        }
    }

    std.debug.print("total: {d}\n", .{total});
}

fn part2(allocator: std.mem.Allocator, reader: anytype) !void {
    var buf: [4096]u8 = undefined;
    var total: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var tokenizer = try Tokenizer.init(allocator, line);
        defer tokenizer.deinit();
        var multiplier = Multiplier.init(true);
        var mul_count: usize = 0;
        while (tokenizer.nextToken()) |tok| {
            // std.debug.print("tok: {}\n", .{tok});
            switch (tok) {
                Token.eof => break,
                else => {
                    multiplier.updateState(tok);
                    if (multiplier.isReadyToMul()) {
                        // std.debug.print("mul({d},{d})\n", .{multiplier.num_1, multiplier.num_2});
                        mul_count += 1;
                        total += multiplier.getMulResult();
                    }
                },
            }
        }
    }

    std.debug.print("total: {d}\n", .{total});
}

const MultiplierState = enum {
    none,
    mul,
    l_paren,
    first_num,
    comma,
    second_num,
    r_paren,

    do,
    do_l_paren,
    do_r_paren,
    dont,
    dont_l_paren,
    dont_r_paren,
};

const StateError = error{
    InvalidTransition,
};

const Multiplier = struct {
    num_1: u64,
    num_2: u64,
    enable_do_dont: bool,
    should_do: bool,
    state: MultiplierState,

    pub fn init(enable_do_dont: bool) Multiplier {
        return Multiplier{
            .num_1 = 0,
            .num_2 = 0,
            .enable_do_dont = enable_do_dont,
            .should_do = true,
            .state = MultiplierState.none,
        };
    }

    pub fn isReadyToMul(self: Multiplier) bool {
        return self.should_do and self.state == MultiplierState.r_paren;
    }

    pub fn getMulResult(self: *Multiplier) u64 {
        const result = self.num_1 * self.num_2;
        self.state = MultiplierState.none;
        self.num_1 = 0;
        self.num_2 = 0;
        return result;
    }

    pub fn updateState(self: *Multiplier, next_token: Token) void {
        switch (next_token) {
            Token.eof => self.state = MultiplierState.none,
            Token.mul => {
                self.state = MultiplierState.mul;
            },
            Token.l_paren => {
                if (self.state == MultiplierState.mul) {
                    self.state = MultiplierState.l_paren;
                } else if (self.state == MultiplierState.do) {
                    self.state = MultiplierState.do_l_paren;
                } else if (self.state == MultiplierState.dont) {
                    self.state = MultiplierState.dont_l_paren;
                } else {
                    self.state = MultiplierState.none;
                }
            },
            Token.number => |val| {
                if (self.state == MultiplierState.l_paren) {
                    self.state = MultiplierState.first_num;
                    self.num_1 = val;
                } else if (self.state == MultiplierState.comma) {
                    self.state = MultiplierState.second_num;
                    self.num_2 = val;
                } else {
                    self.state = MultiplierState.none;
                }
            },
            Token.comma => {
                if (self.state != MultiplierState.first_num) {
                    self.state = MultiplierState.none;
                    return;
                }
                self.state = MultiplierState.comma;
            },
            Token.r_paren => {
                if (self.state == MultiplierState.second_num) {
                    self.state = MultiplierState.r_paren;
                } else if (self.state == MultiplierState.do_l_paren) {
                    self.state = MultiplierState.do_r_paren;
                    self.should_do = true;
                } else if (self.state == MultiplierState.dont_l_paren) {
                    self.state = MultiplierState.dont_r_paren;
                    self.should_do = false;
                } else {
                    self.state = MultiplierState.none;
                }
            },
            Token.do => {
                if (!self.enable_do_dont) return;

                self.state = MultiplierState.do;
            },
            Token.dont => {
                if (!self.enable_do_dont) return;

                self.state = MultiplierState.dont;
            },
            else => {
                self.state = MultiplierState.none;
            },
        }
    }
};

const Token = union(enum) {
    illegal,
    eof,

    // delimiters
    comma,
    l_paren,
    r_paren,

    // keywords
    mul,
    do,
    dont,

    // literals
    number: u64,
};

const Tokenizer = struct {
    buffer: []const u8,
    pos: usize,
    next_pos: usize,
    curr_char: u8,
    allocator: std.mem.Allocator,
    keyword_map: std.StringHashMap(Token),

    pub fn init(allocator: std.mem.Allocator, buffer: []const u8) !Tokenizer {
        var tokenizer = Tokenizer{
            .allocator = allocator,
            .buffer = buffer,
            .pos = 0,
            .next_pos = 0,
            .curr_char = undefined,
            .keyword_map = undefined,
        };

        tokenizer.keyword_map = std.StringHashMap(Token).init(allocator);
        try tokenizer.keyword_map.put("mul", Token.mul);
        try tokenizer.keyword_map.put("do", Token.do);
        try tokenizer.keyword_map.put("don't", Token.dont);

        return tokenizer;
    }

    pub fn deinit(self: *Tokenizer) void {
        self.keyword_map.deinit();
    }

    fn isLetter(c: u8) bool {
        // only letters because of "mul"
        return std.ascii.isAlphabetic(c) or c == '\'';
    }

    pub fn nextToken(self: *Tokenizer) ?Token {
        if (self.pos >= self.buffer.len) {
            return Token.eof;
        }

        var tok: Token = undefined;
        while (self.pos < self.buffer.len) {
            const char = self.buffer[self.pos];
            switch (char) {
                0 => {
                    tok = Token.eof;
                    self.pos += 1;
                    break;
                },
                '(' => {
                    self.pos += 1;
                    tok = Token.l_paren;
                    break;
                },
                ')' => {
                    self.pos += 1;
                    tok = Token.r_paren;
                    break;
                },
                ',' => {
                    self.pos += 1;
                    tok = Token.comma;
                    break;
                },
                // 'a'...'z', 'A'...'Z' => {
                //     const start_pos = self.pos;
                //     while (Tokenizer.isLetter(self.buffer[self.pos])) {
                //         self.pos += 1;
                //     }

                //     const content = self.buffer[start_pos..self.pos];
                //     if (self.keyword_map.get(content)) |val| {
                //         tok = val;
                //         break;
                //     } else {
                //         tok = Token.illegal;
                //         break;
                //     }
                // },
                'd' => {
                    const start_pos = self.pos;
                    while (Tokenizer.isLetter(self.buffer[self.pos])) {
                        self.pos += 1;
                    }

                    const content = self.buffer[start_pos..self.pos];
                    if (self.keyword_map.get(content)) |val| {
                        tok = val;
                        break;
                    } else {
                        tok = Token.illegal;
                        break;
                    }
                },
                'm' => {
                    const start_pos = self.pos;
                    while (Tokenizer.isLetter(self.buffer[self.pos])) {
                        self.pos += 1;
                    }

                    const content = self.buffer[start_pos..self.pos];
                    if (self.keyword_map.get(content)) |val| {
                        tok = val;
                        break;
                    } else {
                        tok = Token.illegal;
                        break;
                    }
                },
                '0'...'9' => {
                    const start_pos = self.pos;
                    while (std.ascii.isDigit(self.buffer[self.pos]) and self.pos - start_pos < 4) {
                        self.pos += 1;
                    }

                    const content = self.buffer[start_pos..self.pos];
                    const num = std.fmt.parseUnsigned(u64, content, 10) catch 0;

                    tok = Token{ .number = num };
                    break;
                },
                else => {
                    self.pos += 1;
                    tok = Token.illegal;
                    break;
                },
            }
        }
        return tok;
    }
};
