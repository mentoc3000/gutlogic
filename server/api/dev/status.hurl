GET http://localhost:8080/

HTTP/1.1 200

[Asserts]
header "Content-Type" == "application/json; charset=utf-8"
jsonpath "$.status" == "ok"