 # Simple Calculator Parsing
 
 The program i made is mainly intended for experimentation and learning about parsing. In this section, i will explain the math parser I plan to implement for [My GBA Calculator](https://fyonietz.my.id/projects/gba-calculator) in the future.

## Algorithm

After doing some research and getting help by LLM, i decided to use the Pratt parsing algorithm for this project. It is well suited for parsing mathematical expressions and
makes it relatively straightforward to handle operators.

### Pratt Algorithm

The key idea behind Pratt parsing is **Binding Power**.

Math is an expression-based language that describes computations using numbers and operators. Some operators have higher precedence than others. For example, multiplication must be evaluated before addition. Parentheses, ( ), have even higher precedence, so expressions inside parentheses are evaluated first.

#### Binding Power
     
The greater the binding power, the stronger the binding effect an operator has on the numbers around it.

* Token Number = 0
* Operator `+` and `-` = Have 10 Binding Power
* Operator `*` and `/` = Have 20 Binding Power

### Token: NUD and LED

Pratt parsing divides the way we process tokens into two main categories: **NUD** (Null Denotation) and **LED** (Left Denotation).

A token can be processed in two different ways depending on its position in an expression.

- **NUD (Null Denotation):** Describes what a token does when it appears at the beginning of an expression, without an expression on its left.
  - Number: `5`
  - Left parenthesis: `(`
  - Unary minus: `-` (such as `-5`)

- **LED (Left Denotation):** Describes what a token does when it appears after an expression and uses the expression on its left.
  - Addition: `+`
  - Subtraction: `-`
  - Multiplication: `*`
  - Division: `/`

One interesting example is the `-` operator, which can act as both NUD and LED:

```text
-5      → `-` is NUD (unary minus)

5 - 3   → `-` is LED (subtraction)
