package pro.tman.pg.hibernate;

import java.io.IOException;
import java.io.Reader;

import org.hibernate.tool.hbm2ddl.ImportSqlCommandExtractor;

/**
 * Extracts postgres multiline commands from pg_dump files to send them to JDBC
 * driver.
 * </p>
 * For extracting the commands, a JFlex based {@link PSQLScanner} scanner scans
 * a given pg_dump file.
 *
 * @see REAME.md
 * @author andreas.trautmann
 *
 */
public class PSQLCommandExtractor implements ImportSqlCommandExtractor {
	@Override
	public String[] extractCommands(Reader reader) {
		PSQLScanner scanner = new PSQLScanner(reader);
		while (!scanner.isZzAtEOF())
			try {
				scanner.yylex();
			} catch (IOException e) {
				throw new IllegalArgumentException(e.getMessage());
			}
		return scanner.getCommands().toArray(new String[0]);
	}
}
