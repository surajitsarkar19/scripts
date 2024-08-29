import org.apache.http.client.HttpClient;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.ssl.SSLContextBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

import javax.net.ssl.SSLContext;
import java.io.InputStream;
import java.security.KeyStore;

@Configuration
public class RestTemplateConfig {

    @Bean
    public RestTemplate restTemplate() throws Exception {
        // Load the PKCS12 certificate from the classpath (resources)
        KeyStore keyStore = KeyStore.getInstance("PKCS12");
        ClassPathResource classPathResource = new ClassPathResource("your-certificate.p12");
        try (InputStream inputStream = classPathResource.getInputStream()) {
            keyStore.load(inputStream, "keystore-password".toCharArray());
        }

        // Create SSLContext using the KeyStore
        SSLContext sslContext = SSLContextBuilder
                .create()
                .loadKeyMaterial(keyStore, "keystore-password".toCharArray()) // Use the same password
                .build();

        // Create SSLConnectionSocketFactory using the SSLContext
        SSLConnectionSocketFactory socketFactory = new SSLConnectionSocketFactory(sslContext);

        // Create HttpClient using the socketFactory
        CloseableHttpClient httpClient = HttpClients.custom()
                .setSSLSocketFactory(socketFactory)
                .build();

        // Create a RestTemplate using the HttpClient
        HttpComponentsClientHttpRequestFactory requestFactory =
                new HttpComponentsClientHttpRequestFactory(httpClient);

        return new RestTemplate(requestFactory);
    }
}