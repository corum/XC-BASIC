module statements;

import pegged.grammar;
import program;
import std.string, std.conv, std.stdio;
import expression;
import stringliteral;
import number, address, var;
import excess;
import xcbarray;
import condition;
import std.algorithm.mutation;
import std.algorithm.comparison;

Stmt StmtFactory(ParseTree node, Program program) {
	string stmt_class =node.children[0].name;
	Stmt stmt;
	switch (stmt_class) {
		case "XCBASIC.Const_stmt":
			stmt = new Const_stmt(node, program);
		break;

		case "XCBASIC.Let_stmt":
			stmt = new Let_stmt(node, program);
		break;

		case "XCBASIC.Print_stmt":
			stmt = new Print_stmt(node, program);
		break;

		case "XCBASIC.Goto_stmt":
			stmt = new Goto_stmt(node, program);
		break;

		case "XCBASIC.Gosub_stmt":
			stmt = new Gosub_stmt(node, program);
		break;

		case "XCBASIC.Return_stmt":
			stmt = new Return_stmt(node, program);
		break;

		case "XCBASIC.End_stmt":
			stmt = new End_stmt(node, program);
		break;

		case "XCBASIC.Rem_stmt":
			stmt = new Rem_stmt(node, program);
		break;

		case "XCBASIC.If_stmt":
			stmt = new If_stmt(node, program);
		break;

		case "XCBASIC.Poke_stmt":
			stmt = new Poke_stmt(node, program);
		break;

        case "XCBASIC.Doke_stmt":
            stmt = new Doke_stmt(node, program);
        break;

		case "XCBASIC.Input_stmt":
			stmt = new Input_stmt(node, program);
		break;

		case "XCBASIC.Dim_stmt":
			stmt = new Dim_stmt(node, program);
		break;

		case "XCBASIC.Charat_stmt":
			stmt = new Charat_stmt(node, program);
		break;

		case "XCBASIC.Textat_stmt":
			stmt = new Textat_stmt(node, program);
		break;

		case "XCBASIC.Data_stmt":
			stmt = new Data_stmt(node, program);
		break;

		case "XCBASIC.For_stmt":
			stmt = new For_stmt(node, program);
		break;

		case "XCBASIC.Next_stmt":
			stmt = new Next_stmt(node, program);
		break;

		case "XCBASIC.Inc_stmt":
			stmt = new Inc_stmt(node, program);
		break;

		case "XCBASIC.Dec_stmt":
			stmt = new Dec_stmt(node, program);
		break;

		case "XCBASIC.Proc_stmt":
			stmt = new Proc_stmt(node, program);
		break;

		case "XCBASIC.Endproc_stmt":
			stmt = new Endproc_stmt(node, program);
		break;

		case "XCBASIC.Call_stmt":
			stmt = new Call_stmt(node, program);
		break;

		case "XCBASIC.Sys_stmt":
			stmt = new Sys_stmt(node, program);
		break;

        case "XCBASIC.Load_stmt":
            stmt = new Load_stmt(node, program);
        break;

        case "XCBASIC.Save_stmt":
            stmt = new Save_stmt(node, program);
        break;

        case "XCBASIC.Origin_stmt":
            stmt = new Origin_stmt(node, program);
        break;

        case "XCBASIC.Incbin_stmt":
            stmt = new Incbin_stmt(node, program);
        break;

        case "XCBASIC.Include_stmt":
            stmt = new Rem_stmt(node, program);
        break;

        case "XCBASIC.Asm_stmt":
            stmt = new Asm_stmt(node, program);
        break;

        case "XCBASIC.Strcpy_stmt":
            stmt = new Strcpy_stmt(node, program);
        break;

        case "XCBASIC.Strncpy_stmt":
            stmt = new Strncpy_stmt(node, program);
        break;

        case "XCBASIC.Curpos_stmt":
            stmt = new Curpos_stmt(node, program);
        break;

        case "XCBASIC.On_stmt":
            stmt = new On_stmt(node, program);
        break;

        case "XCBASIC.Wait_stmt":
            stmt = new Wait_stmt(node, program);
        break;

        case "XCBASIC.Watch_stmt":
            stmt = new Watch_stmt(node, program);
        break;

        case "XCBASIC.Pragma_stmt":
            stmt = new Pragma_stmt(node, program);
        break;

        case "XCBASIC.Memset_stmt":
            stmt = new Memset_stmt(node, program);
        break;

        case "XCBASIC.Memcpy_stmt":
            stmt = new Memcpy_stmt(node, program);
        break;

        case "XCBASIC.Memshift_stmt":
            stmt = new Memshift_stmt(node, program);
        break;

        case "XCBASIC.While_stmt":
            stmt = new While_stmt(node, program);
        break;

        case "XCBASIC.Endwhile_stmt":
            stmt = new Endwhile_stmt(node, program);
        break;

        case "XCBASIC.Repeat_stmt":
            stmt = new Repeat_stmt(node, program);
        break;

        case "XCBASIC.Until_stmt":
            stmt = new Until_stmt(node, program);
        break;

        case "XCBASIC.If_sa_stmt":
            stmt = new If_standalone_stmt(node, program);
        break;

        case "XCBASIC.Else_stmt":
            stmt = new Else_stmt(node, program);
        break;

        case "XCBASIC.Endif_stmt":
            stmt = new Endif_stmt(node, program);
        break;

        case "XCBASIC.Aliasfn_stmt":
            stmt = new Aliasfn_stmt(node, program);
        break;

        case "XCBASIC.Aliascmd_stmt":
            stmt = new Aliascmd_stmt(node, program);
        break;

        case "XCBASIC.Userland_stmt":
            stmt = new Userland_stmt(node, program);
        break;

		default:
            program.error("Unknown statement "~node.name);
		    assert(0);
	}

	return stmt;
}

template StmtConstructor()
{
	this(ParseTree node, Program program)
	{
		super(node, program);
	}
}

interface StmtInterface
{
	void process();
}

abstract class Stmt:StmtInterface
{
	protected ParseTree node;
	protected Program program;

	this(ParseTree node, Program program)
	{
		this.node = node;
		this.program = program;
	}
}

class Const_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		ParseTree v = this.node.children[0].children[0];
		ParseTree num = this.node.children[0].children[1];
		string varname = join(v.children[0].matches);
        string sigil = join(v.children[1].matches);
		char vartype = this.program.resolve_sigil(sigil);

        if(vartype == 's') {
            this.program.error("A string pointer cannot be constant");
        }

        Number number = new Number(num, this.program);

        if
        (
            (number.type == 'f' && vartype != 'f') ||
            (vartype == 'f' && number.type != 'f')
        ) {
            this.program.error("Type mismatch");
        }

        if(vartype == 'b' && (number.intval < 0 || number.intval > 255)) {
            this.program.error("Number out of range");
        }

		Variable var = {
			name: varname,
			type: vartype,
			isConst: true,
			constValInt: number.intval,
            constValFloat: number.floatval
		};

		if(!this.program.is_variable(varname, sigil)) {
			this.program.addVariable(var);
		}
		else {
			this.program.error("A variable or constant already exists with that name");
		}
	}
}

class Let_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		ParseTree v = this.node.children[0].children[0];
        ParseTree ex = this.node.children[0].children[1];
        string varname = join(v.children[0].matches);
        string sigil = join(v.children[1].matches);
        char vartype = this.program.resolve_sigil(sigil);

        if(!this.program.is_variable(varname, sigil)) {
            this.program.addVariable(Variable(0, varname, vartype));
        }
        Variable var = this.program.findVariable(varname, sigil);
        if(var.isConst) {
            this.program.error("Can't assign value to a constant");
        }
        Expression Ex = new Expression(ex, this.program);

        char extype = Ex.detect_type();

        extype = (extype == 's' ? 'w' : extype);
        vartype = (vartype == 's' ? 'w' : vartype);

        if
        (
            (extype == 'f' && vartype != 'f') ||
            (vartype == 'f' && extype != 'f')
        ) {
            this.program.error("Type mismatch");
        }

        Ex.eval();
        this.program.program_segment ~= to!string(Ex);

        if(extype == 'b' && vartype == 'w') {
            this.program.program_segment ~= "\tbtow\n";
            // bytes should be silently promoted to integers
            //this.program.warning("Implicit type conversion");
        }
        else if(extype == 'w' && vartype == 'b') {
            this.program.program_segment ~= "\twtob\n";
            this.program.warning("Integer truncated to byte");
        }

        if(v.children.length > 2) {
            /* any variable can be accessed as an array
            if(var.dimensions[0] == 1 && var.dimensions[1] == 1) {
                this.program.error("Not an array");
            }
            */
            auto subscript = v.children[2];
            XCBArray arr = new XCBArray(this.program, var, subscript);
            this.program.program_segment ~= arr.store();
        }
        else {
            this.program.program_segment ~= "\tpl" ~ to!string(vartype) ~ "2var " ~ var.getLabel() ~ "\n";
        }
	}
}

class Dim_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		ParseTree v = this.node.children[0].children[0];
        bool is_fast = false;
        if(this.node.matches[$-1] == "fast" || this.node.matches[$-1] == "FAST") {
            is_fast = true;
        }

		string varname = join(v.children[0].matches);
        string sigil = join(v.children[1].matches);
		char vartype = this.program.resolve_sigil(sigil);

		ushort[2] dimensions;
		if(v.children.length > 2) {
			auto subscript = v.children[2];

			ubyte i = 0;
			foreach(ref expr; subscript.children) {
                string dim = join(expr.matches);
                int dimlen = 0;

                // Case 1: test for constant
                if(this.program.is_variable(dim, "")) {
                    Variable var = this.program.findVariable(dim, "");
                    if(!var.isConst) {
                        this.program.error("Only numeric constants are accepted as array dimensions");
                    }
                    if(var.type != 'w') {
                        this.program.error("Array dimensions must be integers");
                    }

                    dimlen = var.constValInt;
                }
                // Case 2: test for numeric literal
                else {
                    if(expr.children.length > 1) {
                        this.program.error("Only numeric constants are accepted as array dimensions");
                    }
                    Number num = new Number(expr.children[0].children[0].children[0].children[0], this.program);
                    if(num.type == 'f') {
                        this.program.error("Array dimensions must be integers");
                    }
                    dimlen = num.intval;
                }

				dimensions[i] = to!ushort(dimlen);
				i++;
			}

			if(dimensions[1] == 0) {
				dimensions[1] = 1;
			}
		}
		else {
			dimensions[0]=1;
			dimensions[1]=1;
		}

		if(this.program.is_variable(varname, sigil)) {
			this.program.error("Variable "~varname~" is already defined/used.");
		}

		Variable var = Variable(0, varname, vartype, dimensions);
		this.program.addVariable(var, is_fast);
	}
}

class Print_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		ParseTree exlist = this.node.children[0].children[0];
		for(char i=0; i< exlist.children.length; i++) {
			final switch(exlist.children[i].name) {

				case "XCBASIC.Expression":
					auto Ex = new Expression(exlist.children[i], this.program);
					Ex.eval();
                    char type = Ex.detect_type();
					this.program.program_segment ~= to!string(Ex);
                    if(type == 's') {
                        this.program.program_segment ~= "\tstdlib_putstr\n";
                    }
                    else {
                        this.program.program_segment ~= "\tstdlib_print"~ to!string(type) ~"\n";
                    }
				break;

				case "XCBASIC.String":
					string str = join(exlist.children[i].matches[1..$-1]);
					Stringliteral sl = new Stringliteral(str, this.program);
					sl.register();
					this.program.program_segment ~= "\tpaddr _S" ~ to!string(Stringliteral.id) ~ "\n";
					this.program.program_segment ~= "\tstdlib_putstr\n";
				break;
			}
		}

		this.program.program_segment ~= "\tlda #13\n";
		this.program.program_segment ~= "\tjsr KERNAL_PRINTCHR\n";
	}
}

class Textat_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		ParseTree exlist = this.node.children[0];
		Expression col = new Expression(exlist.children[0], this.program);
		Expression row = new Expression(exlist.children[1], this.program);

        if(col.detect_type() == 'f' || row.detect_type == 'f') {
            this.program.error("Column and row must be bytes or integers");
        }

		col.eval();
        if(col.type == 'b') {
            col.btow();
        }
		row.eval();
        if(row.type == 'b') {
            row.btow();
        }

        string offset_code = "";

        offset_code ~= to!string(row); // rownum second
        // multiply by 40
        offset_code ~="\tpword #40\n" ~ "\tmulw\n";
        // add column
        offset_code ~= to!string(col); // colnum last
        offset_code ~= "\taddw\n";
        // add 1024
        offset_code ~="\tpword #1024\n" ~ "\taddw\n";

		if(exlist.children[2].name == "XCBASIC.Expression") {

            Expression ex = new Expression(exlist.children[2], this.program);
            ex.eval();

            if(ex.type != 's') {
                this.program.program_segment ~= offset_code;
                this.program.program_segment ~= to!string(ex) ~ "\n";
                this.program.program_segment ~= "\t"~to!string(ex.type)~"at\n";
            }
            else {
                this.program.program_segment ~= to!string(ex) ~ "\n";
                this.program.program_segment ~= offset_code;
                this.program.program_segment ~="\tstringat\n";
            }

		}
		else {
			// string literal
			string str = join(exlist.children[2].matches[1..$-1]);
			Stringliteral sl = new Stringliteral(str, this.program);
			sl.register(false, true);
			// text first
			this.program.program_segment ~= "\tpaddr _S" ~ to!string(Stringliteral.id) ~ "\n";
            this.program.program_segment ~= offset_code;
			this.program.program_segment ~="\ttextat\n";
		}
	}
}

class Goto_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		string lbl = join(this.node.children[0].children[0].matches);
		if(!this.program.labelExists(lbl)) {
			this.program.error("Label "~lbl~" does not exist");
		}

		lbl = this.program.in_procedure ? this.program.current_proc_name ~ "." ~ lbl : lbl;
		this.program.program_segment ~= "\tjmp _L"~lbl~"\n";
	}
}

class Call_stmt:Stmt
{
	mixin StmtConstructor;

    protected string getProcLabel()
    {
        string lbl = join(this.node.children[0].children[0].matches);
        if(!this.program.procExists(lbl)) {
            this.program.error("Procedure not declared");
        }
        return lbl;
    }

	void process()
	{
		string lbl = this.getProcLabel();
		Procedure proc = this.program.findProcedure(lbl);
		if(this.node.children[0].children.length > 1) {
			ParseTree exprlist = this.node.children[0].children[1];
			if(exprlist.children.length != proc.arguments.length) {
				this.program.error("Wrong number of arguments");
			}

			for(ubyte i = 0; i < proc.arguments.length; i++) {
				Expression Ex = new Expression(exprlist.children[i], this.program);
				Ex.eval;
				if(proc.arguments[i].type != Ex.detect_type()) {
                    Ex.convert(proc.arguments[i].type);
				}
				this.program.program_segment ~= to!string(Ex);
				char vartype = proc.arguments[i].type;
				string varlabel = proc.arguments[i].getLabel();
				this.program.program_segment ~= "\tpl" ~ to!string(vartype) ~ "2var " ~ varlabel ~ "\n";
			}
		}

        bool recursive = false;
        if(lbl == this.program.current_proc_name) {
            recursive = true;
            // push local vars
            foreach(ref var; this.program.localVariables()) {
                if(var.dimensions == [1,1]) {
                    this.program.program_segment ~= "\tp"~to!string(var.type)~"var " ~ var.getLabel() ~ "\n";
                }
                else {
                    // an array
                    int length = var.dimensions[0] * var.dimensions[1] * this.program.varlen[var.type];
                    for(int offset = 0; offset < length; offset++) {
                        this.program.program_segment ~= "\tpbyte " ~ var.getLabel() ~ "+" ~to!string(offset)~ "\n";
                    }
                }
            }
        }

		this.program.program_segment ~= "\tjsr " ~ proc.getLabel() ~ "\n";

        if(recursive) {
            // pull local vars
            foreach(ref var; this.program.localVariables().reverse) {
                if(var.dimensions == [1,1]) {
                    this.program.program_segment ~= "\tpl"~to!string(var.type)~"2var " ~ var.getLabel() ~ "\n";
                }
                else {
                    // an array
                    int length = var.dimensions[0] * var.dimensions[1] * this.program.varlen[var.type];
                    for(int offset = length -1 ; offset >= 0; offset--) {
                        this.program.program_segment ~= "\tplb2var " ~ var.getLabel() ~ "+" ~to!string(offset)~ "\n";
                    }
                }

            }
        }
	}
}

class Gosub_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		string lbl = join(this.node.children[0].children[0].matches);
		if(!this.program.labelExists(lbl)) {
			this.program.error("Label "~lbl~" does not exist");
		}

		lbl = this.program.in_procedure ? this.program.current_proc_name ~ "." ~ lbl : lbl;
		this.program.program_segment ~= "\tjsr _L"~lbl~"\n";
	}
}

class Return_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		this.program.program_segment ~= "\trts\n";
	}
}

class End_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		this.program.program_segment ~= "\thalt\n";
	}
}

class Rem_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		{}
	}
}

class If_stmt:Stmt
{
	mixin StmtConstructor;

	public static int counter = 65536;

	void process()
	{
        auto statement = this.node.children[0];
        Condition cond = new Condition(statement.children[0], this.program);
        cond.eval();
        this.program.program_segment ~= cond.asmcode;

		int cursor = 1;
		auto st = statement.children[cursor];
		bool else_present = false;

		ParseTree else_st;

		if(statement.children.length > cursor + 1) {
			else_present = true;
			else_st = statement.children[cursor + 1];
		}

		string ret;
		ret ~= "\tcond_stmt _EI_" ~ to!string(counter) ~ ", _EL_" ~ to!string(counter) ~ "\n";

		this.program.program_segment~=ret;

        // can be multiple statements
        foreach(ref child; st.children) {
            Stmt stmt = StmtFactory(child, this.program);
            stmt.process();
        }

		// else branch
		if(else_present) {
			this.program.program_segment ~= "\tjmp _EI_" ~ to!string(counter)  ~ "\n";
			this.program.program_segment ~= "_EL_" ~to!string(counter)~ ":\n";

            // can be multiple statements
            foreach(ref e_child; else_st.children) {
                Stmt else_stmt = StmtFactory(e_child, this.program);
                else_stmt.process();
            }
		}

		this.program.program_segment ~= "_EI_" ~to!string(counter)~ ":\n";
		counter++;
	}
}

class If_standalone_stmt:Stmt
{
    mixin StmtConstructor;

    public static int counter = 0;

    void process()
    {
        counter++;
        this.program.if_stack.push(counter);

        auto statement = this.node.children[0];
        Condition cond = new Condition(statement.children[0], this.program);
        cond.eval();
        this.program.program_segment ~= cond.asmcode;
        this.program.program_segment ~= "\tcond_stmt _EI_" ~ to!string(counter) ~ ", _EL_" ~ to!string(counter) ~ "\n";
    }
}

class Else_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        string label_q = to!string(this.program.if_stack.top());
        this.program.program_segment ~= "\tjmp _EI_" ~label_q~ "\n";
        this.program.program_segment ~= "_EL_"~ label_q ~ ":\n";
    }
}

class Endif_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        this.program.program_segment ~= "_EI_"~ to!string(this.program.if_stack.pull()) ~ ":\n";
    }
}

class While_stmt:Stmt
{
    mixin StmtConstructor;

    public static int counter = 0;

    void process()
    {
        counter++;
        this.program.while_stack.push(counter);

        string ret;
        string strcounter = to!string(counter);

        ret ~= "_WH_" ~ strcounter ~ ":\n";

        auto statement = this.node.children[0];
        Condition cond = new Condition(statement.children[0], this.program);
        cond.eval();
        ret ~= cond.asmcode;

        ret ~= "\tcond_stmt _EW_" ~ strcounter ~ ", _void_\n";
        this.program.program_segment ~= ret;
    }
}

class Endwhile_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        int counter = this.program.while_stack.pull();
        this.program.program_segment ~= "\tjmp _WH_" ~ to!string(counter) ~ "\n";
        this.program.program_segment ~= "_EW_" ~ to!string(counter) ~ ":\n";
    }
}

class Repeat_stmt:Stmt
{
    mixin StmtConstructor;

    public static int counter = 0;

    void process()
    {
        counter++;
        this.program.repeat_stack.push(counter);
        this.program.program_segment ~= "_RP_" ~ to!string(counter) ~ ":\n";
    }
}

class Until_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        int counter = this.program.repeat_stack.pull();

        string ret;
        string strcounter = to!string(counter);

        auto statement = this.node.children[0];
        Condition cond = new Condition(statement.children[0], this.program);
        cond.eval();
        ret ~= cond.asmcode;

        ret ~= "\tcond_stmt _RP_" ~ strcounter ~ ", _void_ \n";
        this.program.program_segment ~= ret;
    }
}

class Poke_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		auto e1 = this.node.children[0].children[0];
		auto e2 = this.node.children[0].children[1];

		auto Ex1 = new Expression(e1, this.program);
        if(Ex1.detect_type() != 'w') {
            this.program.error("Address must be an integer");
        }
		Ex1.eval();
		auto Ex2 = new Expression(e2, this.program);
        if(Ex2.detect_type() == 'f') {
            this.program.error("Value must not be a float");
        }
        Ex2.eval();

		this.program.program_segment ~= to!string(Ex2); // value first
		this.program.program_segment ~= to!string(Ex1); // address last

		this.program.program_segment~="\tpoke"~to!string(Ex2.type)~"\n";
	}
}

class Doke_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        auto e1 = this.node.children[0].children[0];
        auto e2 = this.node.children[0].children[1];

        auto Ex1 = new Expression(e1, this.program);
        if(Ex1.detect_type() != 'w') {
            this.program.error("Address must be an integer");
        }
        Ex1.eval();
        auto Ex2 = new Expression(e2, this.program);
        if(Ex2.detect_type() == 'f') {
            this.program.error("Value must not be a float");
        }

        Ex2.eval();
        if(Ex2.type == 'b') {
            Ex2.btow();
        }

        this.program.program_segment ~= to!string(Ex2); // value first
        this.program.program_segment ~= to!string(Ex1); // address last

        this.program.program_segment~="\tdoke\n";
    }
}

class Charat_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		auto e1 = this.node.children[0].children[0];
		auto e2 = this.node.children[0].children[1];
		auto e3 = this.node.children[0].children[2];

		auto Ex1 = new Expression(e1, this.program);
		Ex1.eval();
        if(Ex1.type == 'b') {
            Ex1.btow();
        }
        else if(Ex1.type == 'f') {
            this.program.error("Row and column must not be floats");
        }

		auto Ex2 = new Expression(e2, this.program);
		Ex2.eval();
        if(Ex2.type == 'b') {
            Ex2.btow();
        }
        else if(Ex2.type == 'f') {
            this.program.error("Row and column must not be floats");
        }
		auto Ex3 = new Expression(e3, this.program);
		Ex3.eval();
        if(Ex3.type == 'f') {
            this.program.error("Screencode must not be a float");
        }

		this.program.program_segment ~= to!string(Ex3); // screencode first
		this.program.program_segment ~= to!string(Ex2); // rownum second
		// multiply by 40
		this.program.program_segment ~="\tpword #40\n" ~ "\tmulw\n";
		// add column
		this.program.program_segment ~= to!string(Ex1); // colnum last
		this.program.program_segment ~= "\taddw\n";
		// add 1024
		this.program.program_segment ~="\tpword #1024\n" ~ "\taddw\n";

		this.program.program_segment~="\tpoke"~to!string(Ex3.type)~"\n";
	}
}

class Input_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
        this.program.use_stringlib = true;
		ParseTree list = this.node.children[0];

        ParseTree v = list.children[0];
        string varname = join(v.children[0].matches);
        string sigil = join(v.children[1].matches);
        char vartype = this.program.resolve_sigil(sigil);
        if(!this.program.is_variable(varname, sigil)) {
            this.program.error("Variable does not exist");
        }
        Variable var = this.program.findVariable(varname, sigil);
        if(vartype != 's') {
            this.program.error("Argument 1 of INPUT must be a string pointer");
        }

        this.program.program_segment ~= "\tpwvar "~var.getLabel()~"\n";

        ParseTree len = list.children[1];
        Expression e = new Expression(len, this.program);
        if(e.detect_type() != 'b') {
            this.program.error("Argument 2 of INPUT must be a byte");
        }

        e.eval();
        this.program.program_segment ~= e.asmcode;

        if(list.children.length > 2) {
            string mask = join(list.children[2].matches)[1..$-1];
            if(mask == "") {
                this.program.error("Empty string");
            }

            auto sl = new Stringliteral(mask, this.program);
            sl.register();
            this.program.program_segment ~= "\tpaddr _S" ~ to!string(Stringliteral.id) ~ "\n";
        }
        else {
            this.program.program_segment ~= "\tpaddr str_default_mask\n";
        }

        this.program.program_segment~="\tinput\n";
	}
}

class Data_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		string varname = join(this.node.children[0].children[0].matches);
        string sigil = join(this.node.children[0].children[1].matches);
		char vartype = this.program.resolve_sigil(sigil);
		ParseTree list = this.node.children[0].children[2];
		ushort dimension = to!ushort(list.children.length);

		if(!this.program.is_variable(varname, sigil)) {
			this.program.addVariable(Variable(0, varname, vartype, [dimension, 1], false, true));
		}
		Variable var = this.program.findVariable(varname, sigil);

		if(var.isConst) {
			this.program.error(varname ~ " is a constant");
		}


        if(list.name == "XCBASIC.Datalist") {
            this.program.data_segment ~= var.getLabel();
            if(vartype == 'b' || vartype == 'f') {
                this.program.data_segment ~= "\tDC.B ";
            }
            else {
                this.program.data_segment ~= "\tDC.W ";
            }

            string value;
            ubyte[5] floatbytes;
            ubyte counter = 0;
            for(int i=0; i< list.children.length; i++) {
                ParseTree v = list.children[i];
                Number num = new Number(v, this.program);

                if (counter > 0) {
                    this.program.data_segment ~= ", ";
                }

                if(vartype == 'f' && num.type !='f' || num.type == 'f' && vartype != 'f') {
                    this.program.error("Type mismatch");
                }

                if(vartype == 'b' && num.type == 'w') {
                    this.program.error("Number out of range");
                }

                if(vartype == 'b' || vartype == 'w') {
                    value = to!string(num.intval);
                    this.program.data_segment ~= "#" ~value;
                }
                else {
                    floatbytes = excess.float_to_hex(num.floatval);
                    this.program.data_segment ~=
                        "#$" ~ to!string(floatbytes[0], 16) ~
                        ", #$" ~ to!string(floatbytes[1], 16) ~
                        ", #$" ~ to!string(floatbytes[2], 16) ~
                        ", #$" ~ to!string(floatbytes[3], 16) ~
                        ", #$" ~ to!string(floatbytes[4], 16);
                }

                counter++;
                if(counter == 16 && i < list.children.length-1) {
                    this.program.data_segment ~= "\n";
                    if(vartype == 'b' || vartype == 'f') {
                        this.program.data_segment ~= "\tDC.B ";
                    }
                    else {
                        this.program.data_segment ~= "\tDC.W ";
                    }
                    counter = 0;
                }
            }

            this.program.data_segment ~="\n";
        }
        else {
            if(vartype != 'b') {
                this.program.error("Included binary files may only be assigned to byte type arrays");
            }
            this.program.data_segment ~= var.getLabel() ~ ":\n\tINCBIN "~join(list.children[0].matches)~"\n";
        }
	}
}

class For_stmt: Stmt
{
	mixin StmtConstructor;

	void process()
	{
		/* step 1 initialize variable */
		ParseTree v = this.node.children[0].children[0];
		ParseTree ex = this.node.children[0].children[1];
		string varname = join(v.children[0].matches);
        string sigil = join(v.children[1].matches);
		char vartype = this.program.resolve_sigil(sigil);

        if(vartype == 'f') {
            this.program.error("Index must not be a float");
        }

		if(!this.program.is_variable(varname, sigil)) {
			this.program.addVariable(Variable(0, varname, vartype));
		}
		Variable var = this.program.findVariable(varname, sigil);
		Expression Ex = new Expression(ex, this.program);
		Ex.eval();
        if(Ex.type == 'f' || (Ex.type == 'w' && vartype == 'b')) {
            this.program.error("Type mismatch");
        }
        else if(Ex.type == 'b' && vartype == 'w') {
            Ex.btow();
        }
		this.program.program_segment ~= to!string(Ex);
		this.program.program_segment ~= "\tpl" ~ to!string(vartype) ~ "2var " ~ var.getLabel() ~ "\n";

		/* step 2 evaluate max_value and push value */
		ParseTree ex2 = this.node.children[0].children[2];
		Expression Ex2 = new Expression(ex2, this.program);
		Ex2.eval();
        if(Ex2.type == 'f' || (Ex2.type == 'w' && vartype == 'b')) {
            this.program.error("Type mismatch");
        }
        else if(Ex2.type == 'b' && vartype == 'w') {
            Ex2.btow();
        }
        this.program.program_segment ~= to!string(Ex2);

		/* step 3 call for */
		this.program.program_segment ~= "\tfor\n";
	}
}

class Next_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		ParseTree v = this.node.children[0].children[0];
		string varname = join(v.children[0].matches);
        string sigil = join(v.children[1].matches);
        if(!this.program.is_variable(varname, sigil)) {
            this.program.error("Variable " ~varname~" does not exist");
        }
		Variable var = this.program.findVariable(varname, sigil);

        if(var.type == 'f') {
            this.program.error("Variable "~varname~" is a float");
        }

        this.program.program_segment ~= "\tnext"~to!string(var.type)~" "~var.getLabel()~"\n";
	}
}

class Inc_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		ParseTree v = this.node.children[0].children[0];
		string varname = join(v.children[0].matches);
        string sigil = join(v.children[1].matches);
        if(!this.program.is_variable(varname, sigil)) {
            this.program.error("Variable " ~varname~" does not exist");
        }

		Variable var = this.program.findVariable(varname, sigil);

        if(var.type == 'f') {
            this.program.error("INC does not work on floats");
        }

		if(var.isConst) {
			this.program.error(varname ~ " is a constant");
		}

		this.program.program_segment ~= "\tinc"~to!string(var.type)~" "~var.getLabel()~"\n";
	}
}


class Dec_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		ParseTree v = this.node.children[0].children[0];
		string varname = join(v.children[0].matches);
        string sigil = join(v.children[1].matches);
        if(!this.program.is_variable(varname, sigil)) {
            this.program.error("Variable " ~varname~" does not exist");
        }
		Variable var = this.program.findVariable(varname, sigil);

        if(var.type == 'f') {
            this.program.error("DEC does not work on floats");
        }

		if(var.isConst) {
			this.program.error(varname ~ " is a constant");
		}
		this.program.program_segment ~= "\tdec"~to!string(var.type)~" "~var.getLabel()~"\n";
	}
}

class Proc_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		if(this.program.in_procedure) {
			this.program.error("Procedure declaration is not allowed here.");
		}
		this.program.in_procedure = true;

		ParseTree pname = this.node.children[0].children[0];
		string name = join(pname.matches);
		if(this.program.procExists(name)) {
			this.program.error("Procedure already declared");
		}

		this.program.current_proc_name = name;

		Variable[] arguments;

		Procedure proc = Procedure(name);

		if(this.node.children[0].children.length > 1) {
			ParseTree varlist = this.node.children[0].children[1];
			foreach(ref var; varlist.children) {
				Variable argument =
                    Variable(
                        0,
                        join(var.children[0].matches),
                        this.program.resolve_sigil(join(var.children[1].matches))
                    );
				this.program.addVariable(argument);
				proc.addArgument(argument);
			}
		}

		this.program.procedures ~= proc;
		this.program.program_segment ~= "\tjmp " ~ proc.getLabel() ~ "_end\n";
		this.program.program_segment ~= proc.getLabel() ~ ":\n";
	}
}

class Endproc_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		if(!this.program.in_procedure) {
			this.program.error("Not in procedure context");
		}


		Procedure current_proc = this.program.findProcedure(this.program.current_proc_name);

		this.program.program_segment ~= "\trts\n";
		this.program.program_segment ~= current_proc.getLabel() ~"_end:\n";

		this.program.in_procedure = false;
		this.program.current_proc_name = "";
	}
}

class Sys_stmt:Stmt
{
	mixin StmtConstructor;

	void process()
	{
		auto e1 = this.node.children[0].children[0];

		auto Ex1 = new Expression(e1, this.program);
		Ex1.eval();

		this.program.program_segment ~= to!string(Ex1);
		this.program.program_segment~="\tsys\n";
	}
}

class Strcpy_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        auto e1 = this.node.children[0].children[0];
        auto Ex1 = new Expression(e1, this.program);
        Ex1.eval();

        auto e2 = this.node.children[0].children[1];
        auto Ex2 = new Expression(e2, this.program);
        Ex2.eval();

        if(Ex1.type != 's' || Ex2.type != 's') {
            this.program.error("STRCPY accepts string pointers only");
        }

        this.program.program_segment ~= to!string(Ex1);
        this.program.program_segment ~= to!string(Ex2);
        this.program.use_stringlib = true;
        this.program.program_segment~="\tstrcpy\n";
    }
}

class Strncpy_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        auto e1 = this.node.children[0].children[0];
        auto Ex1 = new Expression(e1, this.program);
        Ex1.eval();

        auto e2 = this.node.children[0].children[1];
        auto Ex2 = new Expression(e2, this.program);
        Ex2.eval();

        if(Ex1.type != 's' || Ex2.type != 's') {
            this.program.error("STRNCPY accepts string pointers only");
        }

        auto e3 = this.node.children[0].children[2];
        auto Ex3 = new Expression(e3, this.program);
        Ex3.eval();

        if(Ex3.type != 'b') {
            this.program.error("The length param passed to STRNCPY must be a byte");
        }

        this.program.program_segment ~= to!string(Ex1);
        this.program.program_segment ~= to!string(Ex2);
        this.program.program_segment ~= to!string(Ex3);
        this.program.use_stringlib = true;
        this.program.program_segment~="\tstrncpy\n";
    }
}

class Curpos_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        auto e1 = this.node.children[0].children[0];
        auto xpos = new Expression(e1, this.program);
        xpos.eval();

        auto e2 = this.node.children[0].children[1];
        auto ypos = new Expression(e2, this.program);
        ypos.eval();

        if(indexOf("bw", xpos.type) == -1 || indexOf("bw", ypos.type) == -1) {
            this.program.error("CURPOS accepts arguments of type byte or int");
        }

        if(xpos.type == 'w') {
            xpos.convert('b');
        }

        if(ypos.type == 'w') {
            ypos.convert('b');
        }

        this.program.program_segment ~= to!string(ypos);
        this.program.program_segment ~= to!string(xpos);

        this.program.use_stringlib = true;
        this.program.program_segment~="\tcurpos\n";
    }
}

class Load_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        string filename = join(this.node.children[0].children[0].matches)[1..$-1];
        if(filename == "") {
            this.program.error("Empty string");
        }

        auto sl = new Stringliteral(filename, this.program);
        sl.register();

        auto device_no = new Expression(this.node.children[0].children[1], this.program);
        device_no.eval();
        if(device_no.type == 'f') {
            this.program.error("Argument #2 of LOAD must not be a float");
        }
        else if(device_no.type == 'b') {
            device_no.btow();
        }

        bool fixed_address = false;
        if(this.node.children[0].children.length > 2) {
            auto address = new Expression(this.node.children[0].children[2], this.program);
            address.eval();
            if(address.type != 'w') {
                this.program.error("Argument #3 of LOAD must be an integer");
            }
            this.program.program_segment ~= to!string(address);
            fixed_address = true;
        }

        this.program.program_segment ~= to!string(device_no);
        this.program.program_segment ~= "\tpbyte #" ~ to!string(filename.length) ~ "\n";
        this.program.program_segment ~= "\tlda #<_S" ~ to!string(Stringliteral.id) ~ "\n";
        this.program.program_segment ~= "\tpha\n";
        this.program.program_segment ~= "\tlda #>_S" ~ to!string(Stringliteral.id) ~ "\n";
        this.program.program_segment ~= "\tpha\n";
        this.program.program_segment~="\tload " ~ (fixed_address ? "0" : "1") ~ "\n";
    }
}

class Save_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        string filename = join(this.node.children[0].children[0].matches)[1..$-1];
        if(filename == "") {
            this.program.error("Empty string");
        }

        auto sl = new Stringliteral(filename, this.program);
        sl.register();

        auto device_no = new Expression(this.node.children[0].children[1], this.program);
        device_no.eval();
        if(device_no.type == 'f') {
            this.program.error("Argument #2 of SAVE must not be a float");
        }
        else if(device_no.type == 'b') {
            device_no.btow();
        }

        auto address1 = new Expression(this.node.children[0].children[2], this.program);
        address1.eval();
        if(address1.type != 'w') {
            this.program.error("Argument #3 of SAVE must be an integer");
        }

        auto address2 = new Expression(this.node.children[0].children[3], this.program);
        address2.eval();
        if(address2.type != 'w') {
            this.program.error("Argument #4 of SAVE must be an integer");
        }

        this.program.program_segment ~= to!string(address2);
        this.program.program_segment ~= to!string(address1);
        this.program.program_segment ~= to!string(device_no);
        this.program.program_segment ~= "\tpbyte #" ~ to!string(filename.length) ~ "\n";
        this.program.program_segment ~= "\tlda #<_S" ~ to!string(Stringliteral.id) ~ "\n";
        this.program.program_segment ~= "\tpha\n";
        this.program.program_segment ~= "\tlda #>_S" ~ to!string(Stringliteral.id) ~ "\n";
        this.program.program_segment ~= "\tpha\n";
        this.program.program_segment ~= "\tsave\n";
    }
}

class Origin_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        string num = join(this.node.children[0].children[0].matches);
        this.program.program_segment~="\torg "~num~"\n";
    }
}

class Incbin_stmt:Stmt
{
    mixin StmtConstructor;

    static int counter = 0;

    void process()
    {
        Incbin_stmt.counter+=1;
        string lblc = to!string(Incbin_stmt.counter);
        string incfile = join(this.node.children[0].children[0].matches);
        this.program.program_segment~="_IJS"~lblc~"\tINCBIN "~incfile~"\n";
        this.program.program_segment~="_IJ"~lblc~"\n";
        this.program.program_segment~= "\tECHO \"Included file ("~replace(incfile,"\"", "")~"):\",_IJS"~lblc~",\"-\", _IJ"~lblc~"\n";
    }
}

class Asm_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        string asm_string = stripLeft(chop(join(this.node.children[0].children[0].matches)), "\"");
        this.program.program_segment~="\t; Inline ASM start\n";
        this.program.program_segment~=asm_string~"\n";
        this.program.program_segment~="\t; Inline ASM end\n";
    }
}

class On_stmt:Stmt
{
    mixin StmtConstructor;

    private static int counter = 0;

    void process()
    {
        On_stmt.counter++;
        auto args = this.node.children[0].children;
        auto e1 = args[0];
        auto index = new Expression(e1, this.program);
        index.eval();

        if(indexOf("bw", index.type) == -1 || indexOf("bw", index.type) == -1) {
            this.program.error("ON accepts argument of type byte or int");
        }

        if(index.type == 'w') {
            index.convert('b');
        }

        string branch_type = join(args[1].matches);
        string lbs ="_On_LB"~to!string(On_stmt.counter)~": DC.B ";
        string hbs ="_On_HB"~to!string(On_stmt.counter)~": DC.B ";
        for(int i=2; i < args.length; i++) {
            string lbl = join(args[i].matches);
            if(!this.program.labelExists(lbl)) {
                this.program.error("Label "~lbl~" does not exist");
            }

            lbl = "_L" ~ (this.program.in_procedure ? this.program.current_proc_name ~ "." ~ lbl : lbl);
            string comma = (i < args.length - 1 ? ", " : "");
            lbs~="<"~lbl~ comma;
            hbs~=">"~lbl~ comma;
        }

        this.program.data_segment ~= lbs ~ "\n" ~ hbs ~ "\n";
        this.program.program_segment ~= to!string(index);
        this.program.program_segment ~= "\ton" ~ branch_type ~ " _On_LB"~to!string(On_stmt.counter)~", _On_HB"~to!string(On_stmt.counter) ~ "\n";
    }
}

class Wait_stmt: Stmt
{
    mixin StmtConstructor;

    void process()
    {
        auto args = this.node.children[0].children;
        auto address = new Expression(args[0], this.program);
        address.eval();
        if(address.type == 'f') {
            this.program.error("Argument #1 of WAIT must not be a float");
        }
        else if(address.type == 'b') {
            address.convert('w');
        }

        auto mask = new Expression(args[1], this.program);
        mask.eval();
        if(mask.type == 'f') {
            this.program.error("Argument #2 of WAIT must not be a float");
        }
        else if(mask.type == 'w') {
            mask.convert('b');
        }

        if(args.length > 2) {
            auto trig = new Expression(args[2], this.program);
            trig.eval();
            if(trig.type == 'f') {
                this.program.error("Argument #3 of WAIT must not be a float");
            }
            else if(trig.type == 'w') {
                trig.convert('b');
            }
            this.program.program_segment ~= to!string(trig);
        }
        else {
            this.program.program_segment ~= "\tpzero\n";
        }

        this.program.program_segment ~= to!string(mask);
        this.program.program_segment ~= to!string(address);
        this.program.program_segment ~= "\twait\n";
    }
}

class Watch_stmt: Stmt
{
    mixin StmtConstructor;

    void process()
    {
        auto args = this.node.children[0].children;
        auto address = new Expression(args[0], this.program);
        address.eval();
        if(address.type == 'f') {
            this.program.error("Argument #1 of WATCH must not be a float");
        }
        else if(address.type == 'b') {
            address.convert('w');
        }

        auto mask = new Expression(args[1], this.program);
        mask.eval();
        if(mask.type == 'f') {
            this.program.error("Argument #2 of WATCH must not be a float");
        }
        else if(mask.type == 'w') {
            mask.convert('b');
        }

        this.program.program_segment ~= to!string(mask);
        this.program.program_segment ~= to!string(address);
        this.program.program_segment ~= "\twatch\n";
    }
}

class Pragma_stmt: Stmt
{
    mixin StmtConstructor;

    void process()
    {
        auto stmt = this.node.children[0];
        string option_key = join(stmt.children[0].matches);
        auto num = new Number(stmt.children[1], this.program);
        this.program.setCompilerOption(option_key, num.intval);
    }
}

class Memset_stmt: Stmt
{
    mixin StmtConstructor;

    void process()
    {
        auto args = this.node.children[0].children;
        auto source = new Expression(args[0], this.program);
        source.eval();
        if(source.type == 'f') {
            this.program.error("Argument #1 of MEMSET must not be a float");
        }
        else if(source.type == 'b') {
            source.convert('w');
        }

        auto len = new Expression(args[1], this.program);
        len.eval();
        if(len.type == 'f') {
            this.program.error("Argument #2 of MEMSET must not be a float");
        }
        else if(len.type == 'b') {
            len.convert('w');
        }

        auto val = new Expression(args[2], this.program);
        val.eval();
        if(val.type == 'f') {
            this.program.error("Argument #3 of MEMSET must not be a float");
        }
        else if(val.type == 'w') {
            val.convert('b');
        }

        this.program.program_segment ~= to!string(val);
        this.program.program_segment ~= to!string(len);
        this.program.program_segment ~= to!string(source);
        this.program.program_segment ~= "\tmemset\n";

        this.program.use_memlib = true;
    }
}

abstract class Memmove_stmt: Stmt
{
    mixin StmtConstructor;

    abstract protected string getName();
    abstract protected string getMenmonic();

    void process()
    {
        auto args = this.node.children[0].children;

        Expression e;

        for(int i=2; i>=0; i--) {
            e = new Expression(args[i], this.program);
            e.eval();
            if(e.type == 'f') {
                this.program.error("Argument #" ~to!string(i+1)~ " of " ~this.getName()~ " must not be a float");
            }
            else if(e.type == 'b') {
                e.convert('w');
            }

            this.program.program_segment ~= to!string(e);
        }

        this.program.program_segment ~= "\t" ~this.getMenmonic()~ "\n";

        this.program.use_memlib = true;
    }
}

class Memcpy_stmt: Memmove_stmt
{
    mixin StmtConstructor;

    override protected string getName()
    {
        return "MEMCPY";
    }

    override protected string getMenmonic()
    {
        return "memcpy";
    }
}

class Memshift_stmt: Memmove_stmt
{
    mixin StmtConstructor;

    override protected string getName()
    {
        return "MEMSHIFT";
    }

    override protected string getMenmonic()
    {
        return "memshift";
    }
}

abstract class Alias_stmt: Stmt
{
    mixin StmtConstructor;

    string getCode(ParseTree address)
    {
        string code;
        final switch(address.name) {
            case "XCBASIC.Number":
                Number num = new Number(address, this.program);
                if(num.type != 'w') {
                    this.program.error("Address must be an integer");
                }
                code = num.getPushCode();
            break;

            case "XCBASIC.Address":
                Address a = new Address(address, this.program);
                code = a.asmcode;
            break;

            case "XCBASIC.Var":
                Var v = new Var(address, this.program);
                if(!v.program_var.isConst) {
                    this.program.error("Address must be constant");
                }
                code = v.get_asm_code();
            break;
        }
        return code;
    }
}

class Aliasfn_stmt: Alias_stmt
{
    mixin StmtConstructor;

    void process()
    {
        auto address = this.node.children[0].children[0];
        string code = this.getCode(address);
        string fnname = join(this.node.children[0].children[1].matches)[1..$-1];

        if(!endsWith(fnname, "#", "!", "$", "%")) {
            fnname = fnname ~ "#";
        }

        if(fnname in this.program.fun_aliases) {
            this.program.error("The function alias '" ~ fnname ~ "' already exists");
        }

        this.program.fun_aliases[fnname] = code;
    }
}

class Aliascmd_stmt: Alias_stmt
{
    mixin StmtConstructor;

    void process()
    {
        auto address = this.node.children[0].children[0];
        string code = this.getCode(address);
        string cmdname = join(this.node.children[0].children[1].matches)[1..$-1];

        if(cmdname in this.program.cmd_aliases) {
            this.program.error("The command alias '" ~ cmdname ~ "' already exists");
        }

        this.program.cmd_aliases[cmdname] = code;
    }
}

class Userland_stmt: Call_stmt
{
    mixin StmtConstructor;

    protected string getProcLabel()
    {
        string cmdname = join(this.node.children[0].children[0].matches);

    }

}
