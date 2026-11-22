const custom_logger = @import("logger.zig");
pub const std_options = custom_logger.std_options;
const std = @import("std");
const print = std.log.debug;
const err = std.log.err;

pub const Precedence = enum{ Plus, Minus, Star, Slash};

pub const TokenType = union(enum) { Number, Operator : Precedence, eof, whitespace };

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
                return .{ .type = .{.Operator = .Plus}, .value = 0 };
            }
            if (char == '-') {
                self.advance();
                return .{ .type = .{.Operator = .Minus}, .value = 0 };
            }
            if (char == '*') {
                self.advance();
                return .{ .type = .{.Operator = .Star}, .value = 0 };
            }
            if (char == '/') {
                self.advance();
                return .{ .type = .{.Operator = .Slash}, .value = 0 };
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
  pub fn factor(self:*@This()) !i32{
      if(self.peek())|char|{
        if(char.type == .Number){
              self.advance();
              // print("Found a number with value of : {d}",.{char.value});
              return char.value;
          }
      }
      return error.UnexpectedToken;
  }
  
  pub fn term(self:*@This()) !i32{
      var result = try self.factor();
      if(self.peek())|token|{
          switch(token.type){
              .Operator => |op| {
                  if(op == .Star){
                      self.advance();
                      const right = try self.factor();
                      result = result * right;
                  }
                  if(op == .Slash){
                      self.advance();
                      const right = try self.factor();
                      if(right == 0) return error.DivideByZero;
                      result = @divTrunc(result,right);
                  }
              },
              else => {
                  return error.NotAPrecedence;
              }
          }
      }
      return result;
  }
  pub fn expression(self:*@This()) !i32{
      var result = try self.term();
      while(self.peek()) |token|{
          switch(token.type) {
              .Operator => |op|{
                  if(op != .Plus and op != .Minus) break;

                  self.advance();

                  const right = try self.term();

                  switch (op) {
                      .Plus => {result = result + right;},
                      .Minus => {result = result - right;},
                      else => unreachable,
                  }
              },
              else => break,
          }
      }//While
      return result;
  }
  pub fn parse(self:*@This()) !i32{
      const result = try self.expression();
      if(self.peek() != null) return error.UnexpectedToken;
      return result;
  }
};
pub fn main() !void {
    // const source: []const u8 = "12 / 6 + 2";
    const source: []const u8 = "9 + 9";

    var lexer: Lexer = .{
        .content = source,
        .cursor = 0,
    };

    const MAX_TOKENS = 1024;
    var token_buffer: [MAX_TOKENS]Token = undefined;
    var token_count: usize = 0;

    var parser: Parser = undefined;

    while (lexer.next_token()) |token| {
        if (token_count >= MAX_TOKENS) {
            break;
        }

        token_buffer[token_count] = token;
        token_count += 1;
    }

    parser.cursor = 0;
    parser.token = token_buffer[0..token_count];

    print("The Math Expression : {s}",.{source});
    const result = parser.parse() catch |errs| {
        err("Error : {s}",.{@errorName(errs)});
        return;
};
    print("Result : {d}",.{result});
}
