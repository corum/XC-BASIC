module number;

import std.stdio;
import std.conv;
import std.string;
import pegged.grammar;
import program;
import petscii;
import excess;

class Number
{
    ParseTree node;
    Program program;
    string str_repr;
    int intval;
    real floatval;
    char type;

    const real lower_limit = -1.70141183E38;
    const real upper_limit =  1.70141183E38;

    this(ParseTree node, Program program)
    {
        this.str_repr = str_repr;
        this.program = program;

        string num_str = join(node.children[0].matches);
        final switch(node.children[0].name) {

            case "XCBASIC.Charlit":
                this.type = 'b';
                string chrlit = join(node.children[0].matches);
                char chr = chrlit[1];
                if(chr != 123) {    // not a "{" character
                    this.intval = to!int(ascii_to_petscii(chr));
                }
                else {
                    char[] replaced_chrlit = replace_petscii_escapes(chrlit[1..$-1]);
                    this.intval = to!int(replaced_chrlit[0]);
                }
                break;

            case "XCBASIC.Integer":
                int num = to!int(num_str);
                if(num < -32768 || num > 65535) {
                    this.program.error("Number out of range");
                }
                this.intval = num;
                break;

            case "XCBASIC.Hexa":
                num_str = num_str[1..$];
                int num = to!int(num_str, 16);
                if(num > 65535) {
                    this.program.error("Number out of range");
                }
                this.intval = num;
                break;

            case "XCBASIC.Binary":
                num_str = num_str[1..$];
                int num = to!int(num_str, 2);
                if(num > 65535) {
                    this.program.error("Number out of range");
                }
                this.intval = num;
                break;

            case "XCBASIC.Floating":
            case "XCBASIC.Scientific":
                try {
                    this.floatval = to!real(num_str);
                    this.type = 'f';

                    if(this.floatval < this.lower_limit || this.floatval > this.upper_limit) {
                        this.program.error("Number out of range");
                    }
                }
                catch(Exception e) {
                    this.program.error("Can't parse number "~num_str);
                }
                break;
        }

        if(this.type != 'f') {
            if(this.intval >= 0 && this.intval < 256) {
                this.type = 'b';
            }
            else {
                this.type = 'w';
            }
        }
    }

    string getPushCode()
    {
        string asmcode;
        if(this.type == 'w') {
            asmcode = "\tpword #" ~ to!string(this.intval) ~ "\n";
        }
        else if(this.type == 'b') {
            asmcode = "\tpbyte #" ~ to!string(this.intval) ~ "\n";
        }
        else {
            ubyte[5] bytes = float_to_hex(this.floatval);
            asmcode ~= "\tpfloat $" ~ to!string(bytes[0], 16) ~ ", $" ~ to!string(bytes[1], 16) ~ ", $"
            ~ to!string(bytes[2], 16) ~ ", $" ~ to!string(bytes[3], 16)  ~ ", $" ~ to!string(bytes[4], 16) ~ "\n";
        }
        return asmcode;
    }
}
