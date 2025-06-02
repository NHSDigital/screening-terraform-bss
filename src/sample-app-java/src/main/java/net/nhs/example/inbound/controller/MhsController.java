package net.nhs.example.inbound.controller;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.security.cert.X509Certificate;
import java.util.Date;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.StringTokenizer;

import javax.activation.DataHandler;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.w3c.dom.NodeList;

/**
 * REST controller for requests from screening systems.
 */
@RestController
@RequestMapping("/MHSEndpoint")
public class MhsController {
private static final Logger LOG = LoggerFactory.getLogger(MhsController.class);
@GetMapping
public void process(HttpServletRequest request, HttpServletResponse response) throws IOException {
try {
LOG.info("Recieved request");
response.getWriter().write("Hello World");
response.getWriter().flush();
} catch (Exception e) {
LOG.error("Request unprocessable by MHSEndpoint", e);
response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
}
}
}
