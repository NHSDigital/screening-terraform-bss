package net.nhs.example;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.HiddenHttpMethodFilter;


@Configuration
public class Config {
private static final Logger LOG = LoggerFactory.getLogger(Config.class);



/**
 * Filter to wrap the request in a {@link MultiReadHttpServletRequest}.
* <p>
* Doing this so the body of the request can be read many times.
*
* @see http://blog.meandmymac.de/pages/spring-boot-eats-the-body-of-post-requests
*/
@Bean
public HiddenHttpMethodFilter hiddenHttpMethodFilter() {
return new HiddenHttpMethodFilter() {
@Override
protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
FilterChain filterChain) throws ServletException, IOException {
super.doFilterInternal(new MultiReadHttpServletRequest(request), response, filterChain);
}
};
}
}
