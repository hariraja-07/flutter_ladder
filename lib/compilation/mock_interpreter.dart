class Executor {
  List<String> output = [];

  FunctionDeclaration? findMainFunction(Program program) {
    for (final node in program.statements) {
      if (node is FunctionDeclaration && node.name == 'main') {
        return node;
      }
    }
    return null;
  }

  void execute(Program program) {
    output.clear();

    final mainFunction = findMainFunction(program);
    if (mainFunction == null) {
      output.add("Program must have a 'main' function defined:");
      output.add("https://dart.dev/to/main-function");
      return;
    }

    for (final statement in mainFunction.body) {
      if (statement is PrintCall) {
        output.add(statement.content);
      }
    }
  }

  String getOutput() {
    return output.join('\n');
  }
}

abstract class AstNode {}

class Program extends AstNode {
  final List<AstNode> statements;
  Program(this.statements);
}

class FunctionDeclaration extends AstNode {
  final String name;
  final List<AstNode> body;
  FunctionDeclaration(this.name, this.body);
}

class PrintCall extends AstNode {
  final String content;
  PrintCall(this.content);
}

class Parser {
  final List<Token> tokens;
  int pos = 0;

  Parser(this.tokens);

  Program parse() {
    final functions = <FunctionDeclaration>[];

    while (pos < tokens.length) {
      if (currentType == 'keyword' && currentValue == 'void') {
        functions.add(parseFunction());
      } else {
        pos++;
      }
    }

    return Program(functions);
  }

  FunctionDeclaration parseFunction() {
    expect('keyword', 'void');
    final name = expect('identifier').value;
    expect('punctuation', '(');
    expect('punctuation', ')');
    expect('punctuation', '{');

    final body = <AstNode>[];
    while (currentValue != '}') {
      if (currentType == 'buildin_function' && currentValue == 'print') {
        body.add(parsePrint());
      } else {
        pos++;
      }
    }
    expect('punctuation', '}');
    return FunctionDeclaration(name, body);
  }

  PrintCall parsePrint() {
    expect('buildin_function', 'print');
    expect('punctuation', '(');
    final text = expect('string').value;
    expect('punctuation', ')');
    expect('punctuation', ';');
    return PrintCall(text);
  }

  //Helpers
  Token expect(String type, [String? value]) {
    if (pos >= tokens.length) {
      throw "Unexpected end of code";
    }
    final token = tokens[pos];
    if (token.type != type || (value != null && token.value != value)) {
      throw "Expected $type $value, but got $token";
    }
    pos++;
    return token;
  }

  String get currentType => tokens[pos].type;
  String get currentValue => tokens[pos].value;
}

class Token {
  final String type;
  final String value;
  Token(this.type, this.value);

  @override
  String toString() => 'Token(type: $type, value: $value)';
}

class Tokenizer {
  final tokenPatterns = <MapEntry<String, RegExp>>[
    MapEntry('whitespace', RegExp(r'\s+')),
    MapEntry('comment', RegExp(r'//[^\n]*')),
    MapEntry(
      'keyword',
      RegExp(r'\b(var|void|return|if|else|for|while|do|break|continue)\b'),
    ),
    MapEntry('buildin_function', RegExp(r'\b(print)\b')),
    MapEntry('number', RegExp(r'\d+(\.\d+)?')),
    MapEntry('string_double', RegExp(r'"([^"\\]|\\.)*"')),
    MapEntry('string_single', RegExp(r"'([^'\\]|\\.)*'")),
    MapEntry('operator', RegExp(r'\+|\-|\*|\/|==|!=|<=|>=|<|>|=')),
    MapEntry('punctuation', RegExp(r'[(){}\[\],;]')),
    MapEntry('identifier', RegExp(r'[a-zA-Z_]\w*')),
  ];

  List<Token> tokenize(String input) {
    final tokens = <Token>[];
    int index = 0;

    while (index < input.length) {
      bool matched = false;

      for (final entry in tokenPatterns) {
        final type = entry.key;
        final regex = entry.value;
        final match = regex.matchAsPrefix(input, index);

        if (match != null) {
          final text = match.group(0)!;

          if (type == 'string_single' || type == 'string_double') {
            tokens.add(Token("string", text.substring(1, text.length - 1)));
          } else if (type != 'whitespace' && type != 'comment') {
            tokens.add(Token(type, text));
          }

          index = match.end;
          matched = true;
          break;
        }
      }

      if (!matched) {
        index++;
      }
    }
    return tokens;
  }
}

class MockInterpreter {
  String input = '';
  List<Token> tokens = [];
  Program? ast;

  final Tokenizer tokenizer = Tokenizer();
  final Executor executor = Executor();

  void getInput(String input) {
    this.input = input;
  }

  void process() {
    this.tokens = tokenizer.tokenize(this.input);
    this.ast = Parser(tokens).parse();
    executor.execute(ast!);
  }

  String output() {
    return executor.getOutput();
  }
}
