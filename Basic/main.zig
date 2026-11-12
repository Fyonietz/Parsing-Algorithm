const custom_logger = @import("logger.zig");
pub const std_options = custom_logger.std_options;
const std = @import("std");
const print = std.log.debug;
const err = std.log.err;

pub const TokenType = enum { Number, Plus, eof, whitespace };

pub const Token = struct { type: TokenType, value: i32 };

pub const Lexer = struct {
    content: []const u8,
    cursor: usize,
    pub fn peek(self: *@This()) ?u8 {
        if (self.cursor >= self.content.len) {
            return null;
        }
        return self.content[self.cursor];
    }
    pub fn advance(self: *@This()) void {
        if (self.cursor < self.content.len) {
            self.cursor += 1;
        }
    }

    pub fn to_integer(self: *@This()) ?i32 {
        var number: i32 = 0;
        var found_digit: bool = false;

        while (self.peek()) |digit| {
            if (digit >= '0' and digit <= '9') {
                number = number * 10 + (digit - '0');
                self.advance();
                found_digit = true;
            } else {
                break;
            }
        }
        if (!found_digit) return null;
        return number;
    }

    pub fn next_token(self: *@This()) ?Token {
        while (self.peek()) |char| {
            if (char == ' ') {
                self.advance();
                continue;
            }
            if (char >= '0' and char <= '9') {
                const number = self.to_integer() orelse return null;
                self.advance();
                return .{ .type = .Number, .value = number };
            }
            if (char == '+') {
                self.advance();
                return .{ .type = .Plus, .value = 0 };
            }
            break;
        }

        return null;
    }
};


const Parser = struct {
    token :[]const Token,
    cursor : usize,

   pub fn peek(self : *@This()) ?Token {
       if(self.cursor < self.token.len){
           return self.token[self.cursor];
       }
       return null;
   }

  pub fn advance(self : *@This()) void{
      if(self.cursor < self.token.len){
          self.cursor += 1;
      }
  }
  pub fn print_peek_advance(self:*@This()) void{
      if(self.peek())|token|{
          print("[PARSER] : {s} ({d})",.{@tagName(token.type),token.value});
          self.advance();
      }
  }
};

pub fn main() !void {
    const source: []const u8 = "12 + 4";
    const lexer_cursor: usize = 0;
    var lexer: Lexer = .{ .content = source, .cursor = lexer_cursor };
    const MAX_TOKENS = 1024;
    var token_buffer:[MAX_TOKENS]Token = undefined;
    var token_count:usize = 0;
    var parser : Parser = undefined;
    parser.cursor = 0;
    while(lexer.next_token())|token|{
        if(token_count >= MAX_TOKENS ){
            break;
        }
        token_buffer[token_count] = token;
        token_count += 1;

        const Tokens:[]const Token = token_buffer[0..token_count];
        parser.token = Tokens;
        parser.print_peek_advance();
    }
}
