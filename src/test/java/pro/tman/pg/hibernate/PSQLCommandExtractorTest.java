package pro.tman.pg.hibernate;

import static org.junit.Assert.fail;

import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.util.Arrays;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class PSQLCommandExtractorTest {

	private static final Logger LOG = LoggerFactory.getLogger(PSQLCommandExtractorTest.class);

	@Test
	public void testGetCommands() {
		try(InputStream is = PSQLCommandExtractorTest.class.getClassLoader().getResourceAsStream("pgdump.sql")){

			InputStreamReader reader = new InputStreamReader(is, Charset.forName("utf-8"));
			PSQLCommandExtractor classUnderTest = new PSQLCommandExtractor();
			String[] commands = classUnderTest.extractCommands(reader);
			FileWriter writeToFile = new FileWriter("target/pgdump.sql");
			Arrays.stream(commands).forEach(t -> {
				try {
					writeToFile.write(t);
				} catch (IOException e) {
					LOG.error(e.getMessage(), e);
				}
			});
			writeToFile.close();

		} catch (Exception e) {
			LOG.error(e.getMessage(), e);
			fail(e.getMessage());
		}
	}

}
