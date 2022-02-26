REM @echo off

call config.bat

set CA_KEY="output\ca_key.cer"
set CA_CERT="output\ca_cert.cer"
set SERVER_KEY="output\server_key.cer"
set SERVER_CERT="output\server_cert.cer"
set SERVER_REQ="output\server_req.cer"

set MIKROTIK_SERVER_RESULT="output\mikrotik_server.cer"
set MIKROTIK_CA_RESULT="output\mikrotik_ca.cer"
set CLIENT_RESULT="output\client.cer"
set OPENSSL_CONF=bin\openssl.cnf


del %CA_KEY% %CA_CERT% %SERVER_KEY% %SERVER_CERT% %SERVER_REQ% %MIKROTIK_SERVER_RESULT% %MIKROTIK_CA_RESULT% %CLIENT_RESULT%


REM Creating the Certificate Authority's Certificate and Keys
bin\openssl.exe genrsa 2048 > "%CA_KEY%"
bin\openssl.exe req -new -x509 -nodes -days 3650 -key %CA_KEY% -out %CA_CERT% ^
    -subj "/C=%COUNTRY%/ST=%STATE%/L=%LOCALITY%/O=%CA_ORGANIZATION%/OU=%OU%/CN=%CA_COMMON_NAME%" ^
    -addext  "keyUsage=critical, Certificate Sign, CRL Sign"

REM Create server key and certificate sign request (CSR)
bin\openssl.exe genrsa 2048 > "%SERVER_KEY%"
bin\openssl.exe req -new -nodes -subj "/C=%COUNTRY%/ST=%STATE%/L=%LOCALITY%/O=%SRV_ORGANIZATION%/OU=%OU%/CN=%SRV_COMMON_NAME%" ^
   -key "%SERVER_KEY%" ^
   -out "%SERVER_REQ%" ^
   -addext  "extendedKeyUsage=TLS Web Server Authentication, TLS Web Client Authentication"

REM Sign the server CSR and create the X509 cert for server
bin\openssl.exe x509 -req -days 3650 -set_serial 01 ^
   -in "%SERVER_REQ%" ^
   -out "%SERVER_CERT%" ^
   -CA "%CA_CERT%" ^
   -CAkey "%CA_KEY%"

type "%CA_CERT%" "%CA_KEY%" > "%MIKROTIK_CA_RESULT%"
type "%SERVER_CERT%" "%SERVER_KEY%" > "%MIKROTIK_SERVER_RESULT%"
copy "%SERVER_CERT%" %CLIENT_RESULT%

del %CA_KEY% %CA_CERT% %SERVER_KEY% %SERVER_CERT% %SERVER_REQ%
