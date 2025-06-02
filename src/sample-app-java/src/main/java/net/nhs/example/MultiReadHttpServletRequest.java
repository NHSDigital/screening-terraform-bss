package net.nhs.example;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UncheckedIOException;

import javax.servlet.ReadListener;
import javax.servlet.ServletInputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

import org.apache.commons.io.IOUtils;
import org.springframework.web.filter.HiddenHttpMethodFilter;

/**
 * The Class MultiReadHttpServletRequest is a {@link HttpServletRequestWrapper} that that caches the body of the
 * request, such that the body can be read multiple times. MultiReadHttpServletRequest is used by the custom
 * {@link HiddenHttpMethodFilter} provided by {@link HiddenHttpMethodFilterConfig}.
 *
 * @see http://blog.meandmymac.de/pages/spring-boot-eats-the-body-of-post-requests
 */
class MultiReadHttpServletRequest extends HttpServletRequestWrapper {
   private final ByteArrayOutputStream cachedBytes;

   MultiReadHttpServletRequest(HttpServletRequest request) {
      super(request);
      try {
         // Cache the inputstream in order to read it multiple times.
         cachedBytes = new ByteArrayOutputStream();
         IOUtils.copy(super.getInputStream(), cachedBytes);
      } catch (IOException e) {
         throw new UncheckedIOException(e);
      }
   }

   @Override
   public ServletInputStream getInputStream() throws IOException {
      return new CachedServletInputStream(cachedBytes.toByteArray());
   }

   @Override
   public BufferedReader getReader() throws IOException {
      return new BufferedReader(new InputStreamReader(getInputStream()));
   }

   private class CachedServletInputStream extends ServletInputStream {
      private final ByteArrayInputStream input;

      public CachedServletInputStream(byte[] bytes) {
         input = new ByteArrayInputStream(bytes);
      }

      @Override
      public int read() throws IOException {
         return input.read();
      }

      @Override
      public boolean isFinished() {
         return input.available() == 0;
      }

      @Override
      public boolean isReady() {
         return true;
      }

      @Override
      public void setReadListener(ReadListener listener) {
         throw new UnsupportedOperationException();
      }
   }
}