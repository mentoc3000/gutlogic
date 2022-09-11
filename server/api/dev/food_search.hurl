GET http://localhost:8080/food/v0/search
Authorization: Bearer @dNyHDe64RdJc7pSAB8n!p@j9bc7fACN933XTmYR

[QueryStringParams]
name: broccoli

HTTP/1.1 200

[Asserts]
header "Content-Type" == "application/json; charset=UTF-8"