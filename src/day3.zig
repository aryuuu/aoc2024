const std = @import("std");

pub fn main() !void {
    std.debug.print("day3 are belong to us\n", .{});
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();
    // defer _ = gpa.deinit();

    // const file = try std.fs.cwd().openFile("./input/day3.txt", .{});
    // defer file.close();

    // var read_buffer = std.io.bufferedReader(file.reader());
    // var reader = read_buffer.reader();

    // var buf: []u8 = undefined;
    // var total: usize = 0;
    // // var curr_tok
    // while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
    //     var tokenizer = Tokenizer.init(allocator, line);
    //     var tok: Token = undefined;
    //     var multiplier = Multiplier.init();

    //     while (tokenizer.nextToken()) |tok|{
    //         switch (tok) {
    //             Token.eof => break,
    //             Token.mul => {
    //                 if multiplier.state
    //             }
    //         }
    //     }
    //     // total += 1;
    // }

    // std.debug.print("total: {d}\n", .{total});
}

// const MultiplierState = enum {
//     none,
//     mul,
//     l_paren,
//     first_num,
//     comma,
//     second_num,
//     r_paren,
// };

// const StateError = error{
//     InvalidTransition,
// };

// const Multiplier = struct {
//     num_1: u64,
//     num_2: u64,
//     state: MultiplierState,

//     pub fn init() Multiplier {
//         return Multiplier{
//             .num_1 = 0,
//             .num_2 = 0,
//             .state = MultiplierState.none,
//         };
//     }

//     pub fn isReadyToMul(self: Multiplier) bool {
//         return self.state == MultiplierState.r_paren;
//     }

//     pub fn updateState(self: *Multiplier, new_state: MultiplierState) !void {
//         switch (new_state) {
//             MultiplierState.none => return error.InvalidTransition,
//             MultiplierState.mul => {
//                 if (self.state != MultiplierState.none) {
//                     return error.InvalidTransition;
//                 }
//             },
//             MultiplierState.l_paren => {
//                 if (self.state != MultiplierState.mul) {
//                     return error.InvalidTransition;
//                 }
//             },
//             MultiplierState.first_num => {
//                 if (self.state != MultiplierState.l_paren) {
//                     return error.InvalidTransition;
//                 }
//             },
//             MultiplierState.first_num => {
//                 if (self.state != MultiplierState.l_paren) {
//                     return error.InvalidTransition;
//                 }
//             },
//             MultiplierState.comma => {
//                 if (self.state != MultiplierState.first_num) {
//                     return error.InvalidTransition;
//                 }
//             },
//             MultiplierState.second_num => {
//                 if (self.state != MultiplierState.comma) {
//                     return error.InvalidTransition;
//                 }
//             },
//         }

//         self.state = new_state;
//     }
// };

// const Token = union(enum) {
//     eof,

//     // delimiters
//     comma,
//     l_paren,
//     r_paren,

//     // keywords
//     mul,

//     // literals
//     number: u64,
// };

// const Tokenizer = struct {
//     buffer: []const u8,
//     pos: usize,
//     next_pos: usize,
//     curr_char: u8,
//     allocator: std.mem.Allocator,
//     keyword_map: std.StringHashMap(Token),

//     pub fn init(allocator: std.mem.Allocator, buffer: []const u8) !Tokenizer {
//         var tokenizer = Tokenizer{
//             .buffer = buffer,
//             .pos = 0,
//             .next_pos = 0,
//             .curr_char = undefined,
//             .keyword_map = undefined,
//         };

//         tokenizer.keyword_map = std.StringHashMap(Token).init(allocator);
//         try tokenizer.keyword_map.put("mul", Token.mul);

//         return tokenizer;
//     }

//     pub fn deinit(self: *Tokenizer) void {
//         self.keyword_map.deinit();
//     }

//     fn isLetter(c: u8) bool {
//         // only letters because of "mul"
//         return std.ascii.isAlphabetic(c);
//     }

//     pub fn nextToken(self: *Tokenizer) Token {
//         if (self.pos >= self.buffer.len) {
//             return Token.eof;
//         }

//         var tok: Token = undefined;
//         while (self.pos < self.buffer.len) {
//             const char = self.buffer[self.pos];
//             switch (char) {
//                 0 => {
//                     tok = Token.eof;
//                     self.pos += 1;
//                     break;
//                 },
//                 '(' => {
//                     self.pos += 1;
//                     tok = Token.l_paren;
//                     break;
//                 },
//                 ')' => {
//                     self.pos += 1;
//                     tok = Token.r_paren;
//                     break;
//                 },
//                 ',' => {
//                     self.pos += 1;
//                     tok = Token.comma;
//                     break;
//                 },
//                 ',' => {
//                     self.pos += 1;
//                     tok = Token.comma;
//                     break;
//                 },
//                 'm' => {
//                     const start_pos = self.pos;
//                     while (Tokenizer.isLetter(self.buffer[self.pos])) {
//                         self.pos += 1;
//                     }

//                     const content = self.buffer[start_pos..self.pos];
//                     if (self.keyword_map.get(content)) |val| {
//                         tok = val;
//                         break;
//                     } else {
//                         continue;
//                         // tok = null;
//                         // break;
//                     }
//                 },
//                 '0'...'9' => {
//                     const start_pos = self.pos;
//                     while (std.ascii.isDigit(self.buffer[self.pos]) and self.pos - start_pos < 4) {
//                         self.pos += 1;
//                     }

//                     const content = self.buffer[start_pos..self.pos];
//                     const num = try std.fmt.parseUnsigned(content);

//                     tok = Token{ .num = num };
//                 },
//                 else => {
//                     self.pos += 1;
//                     continue;
//                 },
//             }
//         }
//     }
// };
