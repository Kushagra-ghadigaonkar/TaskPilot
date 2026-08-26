# Flow of how tls certificates are created assigned to applications

## Self-Issued Certificates
```bash

    1. Cert-Manager : Cluster issuer tells Cert-Manager how to create certificates
                                        |
                                        V
    2. SelfSigned ClusterIssuer : Creates Certificates without encryption and real domain
                                        |
                                        V
    3. Certificate : Request a certificate for app.local
                                        |
                                        V
    4. TLS Secret : Cert manager stores the generated tls.crt and tls.key
                                        |
                                        V
    5. GateWay : terminates https using tls secret
                                        |
                                        V
    6. HTTPRoute : Routes the request from gateway to application service
                                        |
                                        V
    7. GateWayClass : Determines which gateway controller actually implements the gateway

```

## Verfied Https Certification Processs 

```bash

    1. Cert-Manager : Cluster issuer tells Cert-Manager how to create certificates
                                        |
                                        V
    2. ClusterIssuer : Encrypt ClusterIssuer with encrypter like lets-encrypter
                                        |
                                        V
    3. HTTP-01 challenge : Proof of cluster issuer is encrypted 
                                        |
                                        V
    4. Gateway + temporary HTTPRoute : cert-manager creates a temporary HTTPRoute for the challenge.
                                        |
                                        V
    5. Let's Encrypt verifies the domain 
                                        |
                                        V
    6. Certificate is issued : Let's Encrypt gives cert-manager the actual TLS certificate
                                        |
                                        V
    7. TLS Secret : cert-manager stores the certificate and private key in a Kubernetes Secret.
                                        |
                                        V
    8. Gateway uses the certificate to terminate https

```

## Summary 

cert-manager uses a Let's Encrypt ClusterIssuer to request a certificate. Let's Encrypt provides an HTTP-01 challenge. cert-manager creates a temporary HTTPRoute through the Gateway so the challenge URL is publicly accessible. Let's Encrypt accesses that URL and verifies domain ownership. After successful validation, Let's Encrypt issues the certificate. cert-manager stores the certificate and private key in a Kubernetes TLS Secret, and the Gateway uses that Secret to terminate HTTPS traffic.