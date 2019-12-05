package pro.trautmann.pg.hibernate;

import static org.junit.Assert.fail;

import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.charset.Charset;
import java.util.Arrays;
import java.util.stream.Collectors;

import org.apache.logging.log4j.core.util.IOUtils;
import org.junit.Assert;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class PSQLCommandExtractorTest {

	private static final Logger LOG = LoggerFactory.getLogger(PSQLCommandExtractorTest.class);

	@Test
	public void testGetCommands() {
		try(InputStream is = PSQLCommandExtractorTest.class.getClassLoader().getResourceAsStream("sql/pgdump.sql")){

			InputStreamReader reader = new InputStreamReader(is, Charset.forName("utf-8"));
			PSQLCommandExtractor classUnderTest = new PSQLCommandExtractor();
			String[] commands = classUnderTest.extractCommands(reader);
			// write to file to have a look at it...
			FileWriter writeToFile = new FileWriter("target/test-classes/pgdump.sql");
			//
			StringWriter writeToString = new StringWriter();
			Arrays.stream(commands).forEach(t -> {
				try {
					writeToFile.write(t);
					writeToString.write(t);
					LOG.info("Extract: " + t);
				} catch (IOException e) {
					LOG.error(e.getMessage(), e);
				}
			});
			writeToFile.close();
			writeToString.close();
			Assert.assertEquals(20, commands.length);
			// test multi line copy statement
			Assert.assertEquals("INSERT INTO atable (note, id) VALUES ('se'\"cond', '2');\n", commands[16]);


		} catch (Exception e) {
			LOG.error(e.getMessage(), e);
			fail(e.getMessage());
		}
	}

	@Test
	public void testSingleDropCommand() {
		try(InputStream is = PSQLCommandExtractorTest.class.getClassLoader().getResourceAsStream("sql/drop.sql")){
			StringWriter clone = new StringWriter();
			InputStreamReader reader = new InputStreamReader(is, Charset.forName("utf-8"));
			IOUtils.copy(reader, clone);
			String cloneString = clone.toString();
			PSQLCommandExtractor classUnderTest = new PSQLCommandExtractor();
			String[] commands = classUnderTest.extractCommands(new StringReader(cloneString));
			Assert.assertEquals(1, commands.length);
			Assert.assertEquals(cloneString, commands[0]);

		} catch (Exception e) {
			LOG.error(e.getMessage(), e);
			fail(e.getMessage());
		}
	}

	@Test
	public void testMaskQuotationMark() {
		Assert.assertEquals("se'\"nd","se\"nd".replaceAll("\"","'\""));
		Assert.assertTrue("\n\\.".matches("(?s).*[\\\n\\\r]+\\\\.[\\\n\\\r]*"));
	}

	@Test
	public void testAppendCopyAsInsert() {
		String copyData = "se\"cond	2";
		String[] values = copyData.replaceAll("\"","'\"").replaceAll("\\\\N", "NULL").split("\t");
		String valueString = Arrays.stream(values).map(t -> t.equals("NULL")?t:"'" + t + "'").collect( Collectors.joining( ", " ) );
		StringBuffer insert = new StringBuffer();
		insert.append("INSERT INTO ")
			.append("atable")
			.append(" (note, id)")
		  	.append(" VALUES (")
		  	.append(valueString)
		  	.append(");\n");
		Assert.assertEquals("INSERT INTO atable (note, id) VALUES ('se'\"cond', '2');\n", insert.toString());
		}

}
