package net.nhs.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * -Djavax.net.ssl.keyStore=mq-keystore.jks -Djavax.net.ssl.keyStorePassword=???
 * -Djavax.net.ssl.trustStore=mq-keystore.jks -Djavax.net.ssl.trustStorePassword=??? -Djavax.net.debug=true
 * -Dcom.ibm.mq.integrateJMSTrace=true -Dcom.ibm.msg.client.commonservices.trace.status=ON
 * -Dcom.ibm.mq.cfg.useIBMCipherMappings=false
 */
@SpringBootApplication
public class Application {
   public static void main(String[] args) {
      SpringApplication.run(Application.class, args);
   }
}
