/* A JFLex scanner for parsing postgresql dumps to extract jdbc commands*/

package pro.tman.pg.hibernate;

import java.lang.StringBuffer;
import java.util.ArrayList;
import java.util.List;

/**
* This class is a PostgreSQL scanner for extracting jdbc commands.
* <p>
* DO NOT EDIT - this file will be re-generated on each build.
* Instead edit pg_dump.flex file
*
* @author andreas.trautmann
*/
%%
%class PSQLScanner
%unicode
%line
%column
%standalone

%{
  StringBuffer command = new StringBuffer();
  List<String> commands = new ArrayList<>();

  boolean isZzAtEOF() {
    return zzAtEOF;
  }

  public List<String> getCommands(){
    return this.commands;
  }
%}

LineTerminator 	   = \r|\n|\r\n
InputCharacter 	   = [^\r\n]
NoEOCMD 		   = [^\r\n\$;]
NoEODCL 		   = [^\r\n\$]
WhiteSpace     	   = {LineTerminator} | [ \t\f]

/* comments */
Comment 			= "\-\-" {InputCharacter}* {LineTerminator}?
EndOfCommand 		= ";" {LineTerminator}
SqlCommandToken 	= ("SET " | "SELECT " | "CREATE " | "COMMENT " | "ALTER " | "DELETE "| "REVOKE " | "GRANT ") {NoEOCMD}*
DeclareToken		= [\$]+ "DECLARE"
EndOfDeclare		= [\$]+ {EndOfCommand}
CopyToken 			= "COPY" {NoEOCMD}+ "FROM stdin;" {LineTerminator}?
BeginToken			= "BEGIN"
EndOfBegin			= "END"
Quote				= "\""
EndOfCopy			= "\\\." {LineTerminator}?


%state COMMAND, COPY, DECLARE
%xstate COPYDATA

%%
 /* keywords */

<YYINITIAL> {
  {Comment}			{ /* ignore comments*/ }
  {WhiteSpace}		{ /* ignore empty lines */ }
  {SqlCommandToken}	{ command.setLength(0); command.append( yytext() ); yybegin(COMMAND); }
  {CopyToken}			{ command.setLength(0); command.append( yytext() ); yybegin(COPY); }
}

/* in any state but exclusive COPYDATA... */
/* tabs and newlines will be transferred to white space */
{WhiteSpace}+		{ command.append(' '); }
{LineTerminator}	{ command.append(' '); }
{Quote}             { command.append('\"'); }

<COMMAND>{
  {NoEOCMD}+			{ command.append( yytext() ); }
  {DeclareToken}		{ yybegin(DECLARE); command.append( yytext() ); }
  {EndOfCommand}		{ yybegin(YYINITIAL); command.append(yytext()); return commands.add(command.toString())?1:0; }
}

<DECLARE>{
  {NoEODCL}+			{ command.append( yytext() ); }
  {EndOfDeclare}		{ yybegin(YYINITIAL); command.append(yytext()); return commands.add(command.toString())?1:0; }

}

<COPY> {
  {CopyToken}			{ command.setLength(0); command.append(yytext()); yybegin(COPYDATA);  }
  <COPYDATA> {
    [\w]+ {InputCharacter}+ {LineTerminator} { command.append(yytext().replaceAll("\"","\\\"")); }
    {LineTerminator}	{ command.append('\n'); }
    {EndOfCopy}		{ yybegin(YYINITIAL); command.append(yytext()); return commands.add(command.toString())?1:0; }
  }
}

