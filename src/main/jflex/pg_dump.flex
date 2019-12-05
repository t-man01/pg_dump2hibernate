/* A JFLex scanner for parsing postgresql dumps to extract jdbc commands*/

package pro.trautmann.pg.hibernate;

import java.lang.StringBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;


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
  String copyTable;
  String copyColumns;

  boolean isZzAtEOF() { return zzAtEOF; }

  public List<String> getCommands(){ return this.commands; }

  public int appendCopyAsInsert(String copyData) {
	String[] values = copyData.replaceAll("\"","'\"").replaceAll("\\\\N", "NULL").split("\t");
	String valueString = Arrays.stream(values).map(t -> t.equals("NULL")?t:"'" + t + "'").collect( Collectors.joining( ", " ) );
	StringBuffer insert = new StringBuffer();
	insert.append("INSERT INTO ")
		.append(copyTable)
		.append(copyColumns)
	  	.append(" VALUES (")
	  	.append(valueString)
	  	.append(");\n");
	return commands.add(insert.toString())?1:0;
	}

	public void appendToCommand(String yytext) { this.command.append(yytext); }

	public void appendToCommand(char yytext) { this.command.append(yytext); }

	public void resetCommand() { command.setLength(0); }

	public void copyTable(String yytext) { this.copyTable = yytext; }

	public void copyColumns(String yytext) { this.copyColumns = yytext; }

	public int appendAndAddCommand(String yytext) {
		this.command.append(yytext);
		return this.commands.add(this.command.toString())?1:0;
	}

%}

LineTerminator 	   = \r|\n|\r\n
InputCharacter 	   = [^\r\n]
NoEOCMD 		   = [^\r\n\$;]
NoEODCL 		   = [^\r\n\$]
NoEOCPY			   = [^\r\n\$;\(\)]
WhiteSpace     	   = {LineTerminator} | [ \t\f]

/* comments */
Comment 			= "\-\-" {InputCharacter}* {LineTerminator}?
EndOfCommand 		= ";" {LineTerminator}?
SqlCommandToken 	= ("DROP " | "SET " | "SELECT " | "CREATE " | "COMMENT " | "ALTER " | "DELETE "| "REVOKE " | "GRANT ") {NoEOCMD}*
DeclareToken		= [\$]+ "DECLARE"
EndOfDeclare		= [\$]+ {EndOfCommand}
CopyToken 			= "COPY "
BeginToken			= "BEGIN"
EndOfBegin			= "END"
Quote				= "\""
EndOfCopy			= "\\\." {LineTerminator}?


%state COMMAND, COPY, DECLARE
%xstate INSERT, COPYDATA

%%
 /* keywords */

<YYINITIAL> {
  {Comment}			{ /* ignore comments*/ }
  {WhiteSpace}		{ /* ignore empty lines */ }
  {SqlCommandToken}	{ resetCommand(); appendToCommand( yytext() ); yybegin(COMMAND); }
  {CopyToken}		{ resetCommand(); appendToCommand( yytext() ); yybegin(COPY); }
}

/* in any state but exclusive COPYDATA... */
/* tabs and newlines will be transferred to white space */
{WhiteSpace}+		{ appendToCommand(' '); }
{LineTerminator}	{ appendToCommand(' '); }
{Quote}             { appendToCommand('\"'); }

<COMMAND>{
  {NoEOCMD}+			{ appendToCommand( yytext() ); }
  {DeclareToken}		{ yybegin(DECLARE); appendToCommand( yytext() ); }
  {EndOfCommand}		{ yybegin(YYINITIAL); return appendAndAddCommand(yytext()); }
}

<DECLARE>{
  {NoEODCL}+			{ appendToCommand( yytext() ); }
  {EndOfDeclare}		{ yybegin(YYINITIAL); return appendAndAddCommand(yytext()); }

}

<COPY> {
  {CopyToken}			{ resetCommand(); }
  {NoEOCPY}+ 			{ copyTable(yytext()); }
  "\(" ~"\)"			{ copyColumns(yytext()); }
  " FROM stdin;" {LineTerminator}? {yybegin(INSERT); }
}

<COPYDATA> {
    [\w]+ {InputCharacter}+ {LineTerminator} { ; }
    {LineTerminator}	{ appendToCommand('\n'); }
    {EndOfCopy}			{ yybegin(YYINITIAL); return appendAndAddCommand(yytext()); }
 }

 <INSERT> {
  	[\w]+ {InputCharacter}+	{ return appendCopyAsInsert(yytext()); }
  	{EndOfCopy}			{ yybegin(YYINITIAL); }
 }