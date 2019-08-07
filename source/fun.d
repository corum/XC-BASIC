module fun;

import pegged.grammar;
import program;
import std.string, std.conv, std.stdio;
import expression;
import std.algorithm.mutation;
import stringliteral;

Fun FunFactory(ParseTree node, Program program) {
    string funName = join(node.children[0].matches);
    Fun fun;
    switch (funName) {
        case "peek":
            fun = new PeekFun(node, program);
        break;

        case "deek":
            fun = new DeekFun(node, program);
        break;

        case "inkey":
            fun = new InKeyFun(node, program);
        break;

        case "rnd":
            fun = new RndFun(node, program);
        break;

        case "usr":
            fun = new UsrFun(node, program);
        break;

        case "ferr":
            fun = new FerrFun(node, program);
        break;

        case "abs":
            fun = new AbsFun(node, program);
        break;

        case "cast":
            fun = new CastFun(node, program);
        break;

        case "sin":
            fun = new SinFun(node, program);
        break;

        case "cos":
            fun = new CosFun(node, program);
        break;

        case "tan":
            fun = new TanFun(node, program);
        break;

        case "atn":
            fun = new AtnFun(node, program);
        break;

        case "sqr":
            fun = new SqrFun(node, program);
        break;

        case "sgn":
            fun = new SgnFun(node, program);
        break;

        case "strlen":
            fun = new StrlenFun(node, program);
        break;

        case "strcmp":
            fun = new StrcmpFun(node, program);
        break;

        case "strpos":
            fun = new StrposFun(node, program);
        break;

        case "val":
            fun = new ValFun(node, program);
        break;

        default:
            fun = new AliasedFun(node, program);
        break;
    }

    return fun;
}

template FunConstructor()
{
    this(ParseTree node, Program program)
    {
        super(node, program);
        if(this.node.children.length > 2) {
            auto exprlist = this.node.children[2];
            if(this.check_argcount) {
                if(exprlist.children.length < this.arg_count || exprlist.children.length > this.arg_count + this.opt_arg_count) {
                    this.program.error("Wrong number of arguments");
                }
            }


            for(ubyte i=0; i<this.arg_count; i++) {
                auto e = exprlist.children[i];
                this.arglist[i] = new Expression(e, this.program);
                this.arglist[i].eval();
            }
        }
        else {
            if(this.check_argcount && this.arg_count > 0) {
                this.program.error("Wrong number of arguments");
            }
        }
    }
}

interface FunInterface
{
    void process();
}

abstract class Fun:FunInterface
{
    protected ParseTree node;
    protected Program program;
    protected ubyte arg_count = 0;
    protected ubyte opt_arg_count = 0;
    protected bool check_argcount = true;
    protected Expression[8] arglist;
    protected string fncode;
    public char type;

    this(ParseTree node, Program program)
    {
        this.node = node;
        string funName = join(node.children[0].matches);
        auto sigil = join(node.children[1].matches);
        char type = program.resolve_sigil(sigil);

        if(count(this.getPossibleTypes(), type) == 0) {
            string err = "The function "~funName ~"() cannot return " ~program.vartype_names[type];
            program.error(err);
        }
        this.program = program;
        this.type = type;
    }

    protected char[] getPossibleTypes()
    {
        return ['w'];
    }

    override string toString()
    {
        string asmcode;
        foreach(ref e; this.arglist) {
            if(e is null) {
                continue;
            }
            asmcode ~= to!string(e);
        }
        asmcode ~= fncode;
        return asmcode;
    }
}

class PeekFun:Fun
{
    mixin FunConstructor;

    protected ubyte arg_count = 1;

    override protected char[] getPossibleTypes()
    {
        return ['w', 'b'];
    }

    void process()
    {
        this.fncode ~= "\tpeek"~to!string(this.type)~"\n";
    }
}

class DeekFun:Fun
{
    mixin FunConstructor;

    protected ubyte arg_count = 1;

    override protected char[] getPossibleTypes()
    {
        return ['w'];
    }

    void process()
    {
        this.fncode ~= "\tdeek\n";
    }
}

class UsrFun:Fun
{
    // This function can take any number of parameters
    protected ubyte arg_count = 0;

    string address;

    override protected char[] getPossibleTypes()
    {
        return ['b', 'w', 'f', 's'];
    }

    this(ParseTree node, Program program)
    {
        super(node, program);
        if(this.node.children.length > 2) {
            auto e_list = this.node.children[2].children;
            int arg_count = to!int(e_list.length);

            for(int i=0; i < arg_count; i++) {
                int index = arg_count - 1 - i;
                auto e = e_list[i];
                if(e.name == "XCBASIC.Expression") {
                    this.arglist[index] = new Expression(e, this.program);
                }
                else if(e.name == "XCBASIC.String") {
                    this.arglist[index] = new StringExpression(e, this.program);
                }
                else {
                    this.program.error("Syntax error");
                }

                this.arglist[index].eval();
            }
        }
    }

    void process()
    {
        this.fncode ~= "\tusr\n";
    }

    override string toString()
    {
        string asmcode;
        foreach(ref e; this.arglist) {
            if(e is null) {
                continue;
            }
            asmcode ~= to!string(e);
        }

        if(this.address != "") {
            // Address was specified: this is an aliased fn call
            asmcode ~= address;
        }

        asmcode ~= fncode;
        return asmcode;
    }
}

class AliasedFun: UsrFun
{
    mixin FunConstructor;

    protected bool check_argcount = false;

    override protected char[] getPossibleTypes()
    {
        return ['b', 'w', 'f', 's'];
    }

    override void process()
    {
        string fnname = join(this.node.children[0].matches);
        string sigil = join(this.node.children[1].matches);
        sigil = sigil == "" ? "#" : sigil;
        string name = fnname ~ sigil;
        if(!(name in this.program.fun_aliases)) {
            this.program.error("Function '" ~ name ~ "' does not exist");
        }
        this.address = this.program.fun_aliases[name];
        this.fncode ~= "\tusr\n";
    }
}

class RndFun:Fun
{
    mixin FunConstructor;
    protected ubyte arg_count = 0;

    override protected char[] getPossibleTypes()
    {
        return ['w', 'f', 'b'];
    }

    void process()
    {
       this.fncode ~= "\trnd" ~ to!string(this.type) ~ "\n";
    }
}

class InKeyFun:Fun
{
    mixin FunConstructor;

    protected ubyte arg_count = 0;

    override protected char[] getPossibleTypes()
    {
        return ['w', 'b'];
    }

    void process()
    {
        this.fncode ~= "\tinkey"~ to!string(this.type) ~"\n";
    }
}

class FerrFun:Fun
{
    mixin FunConstructor;

    protected ubyte arg_count = 0;

    override protected char[] getPossibleTypes()
    {
        return ['w', 'b'];
    }

    void process()
    {
        this.fncode ~= "\tferr"~ to!string(this.type) ~"\n";
    }
}

class AbsFun:Fun
{
    mixin FunConstructor;

    protected ubyte arg_count = 1;

    override protected char[] getPossibleTypes()
    {
        return ['w', 'f'];
    }

    void process()
    {
        if(this.type != this.arglist[0].detect_type()) {
            this.program.error("The abs() function's argument type and return type must match");
        }

        this.fncode ~= "\tabs" ~ to!string(this.type) ~ "\n";
    }
}

class StrlenFun:Fun
{
    mixin FunConstructor;

    protected ubyte arg_count = 1;

    override protected char[] getPossibleTypes()
    {
        return ['b'];
    }

    void process()
    {
        if(this.arglist[0].detect_type() != 's') {
            this.program.error("Wrong type passed to strlen()");
        }

        this.program.use_stringlib = true;
        this.fncode ~= "\tstrlen\n";
    }
}

class StrcmpFun:Fun
{
    mixin FunConstructor;

    protected ubyte arg_count = 2;

    override protected char[] getPossibleTypes()
    {
        return ['w'];
    }

    void process()
    {
        if(this.arglist[0].detect_type() != 's' || this.arglist[1].detect_type() != 's') {
            this.program.error("Wrong type passed to strcmp()");
        }
        this.program.use_stringlib = true;
        this.fncode ~= "\tstrcmp\n";
    }
}

class StrposFun:Fun
{
    mixin FunConstructor;

    protected ubyte arg_count = 2;

    override protected char[] getPossibleTypes()
    {
        return ['b'];
    }

    void process()
    {
        if(this.arglist[0].detect_type() != 's' || this.arglist[1].detect_type() != 's') {
            this.program.error("Wrong type passed to strcmp()");
        }
        this.program.use_stringlib = true;
        this.fncode ~= "\tstrpos\n";
    }
}

class CastFun:Fun
{
    mixin FunConstructor;

    protected ubyte arg_count = 1;

    override protected char[] getPossibleTypes()
    {
        return ['b', 'w', 'f'];
    }

    void process()
    {
        char argtype = this.arglist[0].type;
        if(argtype == this.type) {
            this.program.error("Can't cast to the same type");
        }

        if(this.type == 'b') {
            this.program.warning("Possible truncation or loss of precision");
        }

        this.fncode = "\t"~to!string(this.arglist[0].type)~"to"~to!string(this.type)~"\n";
    }
}

abstract class TrigonometricFun:Fun
{
    mixin FunConstructor;

    protected ubyte arg_count = 1;

    override protected char[] getPossibleTypes()
    {
        return ['f'];
    }

    abstract string getName();

    void process()
    {
        if(this.arglist[0].type != 'f') {
            this.program.error("Argument #1 of "~this.getName()~"() must be a float");
        }

        this.fncode = "\t" ~this.getName()~ "f\n";
    }
}

class SinFun:TrigonometricFun
{
    mixin FunConstructor;

    override string getName()
    {
        return "sin";
    }
}

class CosFun:TrigonometricFun
{
    mixin FunConstructor;

    override string getName()
    {
        return "cos";
    }
}

class TanFun:TrigonometricFun
{
    mixin FunConstructor;

    override string getName()
    {
        return "tan";
    }
}

class AtnFun:TrigonometricFun
{
    mixin FunConstructor;

    override string getName()
    {
        return "atn";
    }
}


class SqrFun:Fun
{
    mixin FunConstructor;

    protected ubyte arg_count = 1;

    override protected char[] getPossibleTypes()
    {
        return ['w', 'f'];
    }

    void process()
    {
        if(this.type != this.arglist[0].detect_type()) {
            this.program.error("The sqr() function's argument type and return type must match");
        }

        this.fncode ~= "\tsqr" ~ to!string(this.type) ~ "\n";
    }
}


class ValFun:Fun
{
    mixin FunConstructor;

    protected ubyte arg_count = 1;

    override protected char[] getPossibleTypes()
    {
        return ['b', 'w', 'f'];
    }

    void process()
    {
        this.program.use_stringlib = true;
        char argtype = this.arglist[0].type;
        if(argtype != 's') {
            this.program.error("Argument 1 of VAL() must be a string pointer");
        }

        this.fncode = "\tval"~to!string(this.type)~"\n";
    }
}

class SgnFun:Fun
{
    mixin FunConstructor;

    protected ubyte arg_count = 1;

    override protected char[] getPossibleTypes()
    {
        return ['w'];
    }

    void process()
    {
        char argtype = this.arglist[0].detect_type();

        if(indexOf("bwf", argtype) == -1) {
            this.program.error("The argument passed to SGN must be an int or float");
        }

        if(argtype == 'b') {
            this.arglist[0].convert('w');
        }

        this.fncode ~= "\tsgn" ~ to!string(this.type) ~ "\n";
    }
}
