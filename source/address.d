module address;

import pegged.grammar;
import program;
import std.string;
import std.stdio;
import core.stdc.stdlib;

class Address
{
    Program program;
    string asmcode;

    this(ParseTree node, Program program)
    {
        this.program = program;
        ParseTree v = node;
        string varname = join(v.children[0].matches);
        string sigil = "";
        if(v.children.length > 1) {
            sigil = join(v.children[1].matches);
        }

        string lbl = "";

        if(this.program.labelExists(varname)) {
            lbl =this.program.getLabelForCurrentScope(varname);
        }
        else if(this.program.is_variable(varname, sigil)) {
            Variable var = this.program.findVariable(varname, sigil);
            if(var.isConst) {
                this.program.error("A constant has no address");
            }
            lbl = var.getLabel();
        }
        else {
            this.program.error("Undefined variable or label: " ~ varname);
        }

        this.asmcode ~= "\tpaddr " ~ lbl ~ "\n";
    }
}
