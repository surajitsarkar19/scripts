String rawJson = restTemplate.execute(url, HttpMethod.GET, (clientHttpRequest) -> {}, this::responseExtractor, uriVariables);

// response extractor would be something like this
private String responseExtractor(ClientHttpResponse response) throws IOException {
    InputStream inputStream = response.getBody();
    ByteArrayOutputStream result = new ByteArrayOutputStream();
    byte[] buffer = new byte[1024];
    for (int length; (length = inputStream.read(buffer)) != -1; ) {
        result.write(buffer, 0, length);
    }
    return result.toString("UTF-8");
}