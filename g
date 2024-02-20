import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.HttpClientBuilder;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

@Configuration
public class RestTemplateConfig {

    private final ProxyProperties proxyProperties;

    public RestTemplateConfig(ProxyProperties proxyProperties) {
        this.proxyProperties = proxyProperties;
    }

    @Bean
    public RestTemplate restTemplate(RestTemplateBuilder restTemplateBuilder) {
        return restTemplateBuilder
                .requestFactory(() -> {
                    HttpComponentsClientHttpRequestFactory requestFactory = new HttpComponentsClientHttpRequestFactory();
                    configureProxy(requestFactory);
                    disableSslVerification(requestFactory);
                    return requestFactory;
                })
                .build();
    }

    private void configureProxy(HttpComponentsClientHttpRequestFactory requestFactory) {
        if (proxyProperties.isEnabled()) {
            CredentialsProvider credentialsProvider = new BasicCredentialsProvider();
            credentialsProvider.setCredentials(
                    new AuthScope(proxyProperties.getHost(), proxyProperties.getPort()),
                    new UsernamePasswordCredentials(proxyProperties.getUsername(), proxyProperties.getPassword()));

            HttpClientBuilder httpClientBuilder = HttpClientBuilder.create()
                    .setDefaultCredentialsProvider(credentialsProvider)
                    .setProxy(new HttpHost(proxyProperties.getHost(), proxyProperties.getPort()));

            requestFactory.setHttpClient(httpClientBuilder.build());
        }
    }

    private void disableSslVerification(HttpComponentsClientHttpRequestFactory requestFactory) {
        try {
            HttpClientBuilder httpClientBuilder = HttpClientBuilder.create()
                    .setSSLHostnameVerifier((hostname, session) -> true);

            requestFactory.setHttpClient(httpClientBuilder.build());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
