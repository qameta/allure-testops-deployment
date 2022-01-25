# Allure TestOps Official k8S Deploy

### Values Example:
```
version: 3.189.2

# Credentials for accessing AllureTestOps as Admin on default auth scheme
username: admin
password: admin

# Security Context
runAsUser: 65534

# your-domain.tld
host: localhost

# Registry Auth. Access to registry secrets can be obtained from QAMeta team
registry:
  # Private registry or Proxy like Nexus
  enabled: false
  # Registry Domain like quay.io / docker.io / ghcr.io / ...
  repo: docker.io
  # Prefix with registry name
  name: allure
  imagePullSecret: allure-server
  pullPolicy: IfNotPresent
  auth:
    username: foo
    password: bar

rbac:
  enabled: true

strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0

network:
  # Nginx Ingress
  ingress:
    enabled: false
    className:
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/ssl-redirect: "false"
      nginx.ingress.kubernetes.io/proxy-body-size: "50m"
  # Istio Gateway
  istio:
    enabled: false
    gateway:
      name: ingressgateway
      selector: istio # e.g. qameta.io/istio-ingressgateway
    domain_exceptions: "https://jira.your-domain.io https://jira.your-domain.ru" # makes Allure TestOps accessible from Jira Plugin
  # TLS Settings
  tls:
    enabled: false
    secretName: allure-tls # Secret with SSL termination secrets.
    hstsEnabled: false

# Redis Config
redis:
  # Set Disabled if you have external Redis
  enabled: true
  # External Redis Host
  host: redis.example.com
  password: allure
  sentinel:
    enabled: false
    master: big_master
    nodes: []

# RabbitMQ Config
rabbitmq:
  enabled: true
  external:
    enabled: false
    host: mq.example.com
  auth:
    erlangCookie: fTwP5LxRVjZ9XJkyWmJSKR5hPDWMjkQx # Set your own random string
    username: allure
    password: allure
  resources: {}

postgresql:
  enabled: true
  postgresqlUsername: allure
  postgresqlPassword: allure
  external:
    endpoint: db.example.com
    uaaUsername: uaa
    uaaPassword: secret
    reportUsername: report
    reportPassword: secret
  initdbScripts:
    init.sql: |
      CREATE DATABASE uaa TEMPLATE template0 ENCODING 'utf8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';
      CREATE DATABASE report TEMPLATE template0 ENCODING 'utf8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';
  persistence:
    size: 20Gi

# Local FS is NOT disabled for migration purpose. Please bear in mind that primary FS for allure is S3
fs:
  # Supported: S3, LOCAL, NFS
  type: "S3"
  external: false
  pathstyle: true
  migration:
    enabled: false
    directory: /opt/allure/report/storage
  s3:
    endpoint: https://s3.amazonaws.com
    bucket: allure-testops
    region: eu-central-1
    accessKey: foo
    secretKey: bar
  # Required only if type is Local or NFS
  mountPoint: /storage
  # Create NFS Volume First as PV
  pvc:
    claimName: ""

gateway:
  replicaCount: 1
  image: allure-gateway
  tolerations: []
  affinity: {}
  nodeSelector: {}
  service:
    port: 8080
  env:
    open:
      TZ: "Europe/Moscow"
      ALLURE_SECURE: "true"
      ALLURE_JWT_ACCESS_TOKEN_VALIDITY_SECONDS: "57600"
      SPRING_OUTPUT_ANSI_ENABLED: never
      LOGGING_LEVEL_IO_QAMETA_ALLURE: warn
      LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_SECURITY: warn
      SPRING_SESSION_STORE_TYPE: REDIS
      SPRING_PROFILES_ACTIVE: kubernetes
      MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE: health,info,prometheus,configprops
      MANAGEMENT_ENDPOINT_HEALTH_CACHE_TIME-TO-LIVE: 19s
      JAVA_TOOL_OPTIONS: >
        -XX:+UseG1GC
        -XX:+UseStringDeduplication
        -Dsun.jnu.encoding=UTF-8
        -Dfile.encoding=UTF-8
  resources: # One pod is good for ~ 400 users
    requests:
      memory: 1Gi
      cpu: 500m
    limits:
      memory: 1536Mi
      cpu: 1
  probes:
    enabled: true
    liveness:
      probe:
        periodSeconds: 40
        timeoutSeconds: 2
        successThreshold: 1
        failureThreshold: 3
        initialDelaySeconds: 60
    readiness:
      probe:
        periodSeconds: 20
        timeoutSeconds: 2
        successThreshold: 1
        failureThreshold: 3
        initialDelaySeconds: 25

uaa:
  replicaCount: 1
  image: allure-uaa
  tolerations: []
  affinity: {}
  nodeSelector: {}
  service:
    port: 8082
  env:
    open:
      TZ: "Europe/Moscow"
      SERVER_SERVLET_CONTEXTPATH: /uaa/
      SPRING_OUTPUT_ANSI_ENABLED: never
      LOGGING_LEVEL_IO_QAMETA_ALLURE: warn
      LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_SECURITY: warn
      SPRING_PROFILES_ACTIVE: kubernetes
      SPRING_DATASOURCE_DRIVER_CLASS_NAME: org.postgresql.Driver
      SPRING_JPA_DATABASE_PLATFORM: org.hibernate.dialect.PostgreSQL9Dialect
      SPRING_JPA_PROPERTIES_HIBERNATE_GLOBALLY_QUOTED_IDENTIFIERS: 'true'
      MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE: health,info,prometheus,configprops
      MANAGEMENT_ENDPOINT_HEALTH_CACHE_TIME-TO-LIVE: 19s
      MANAGEMENT_HEALTH_DISKSPACE_ENABLED: "false"
      MANAGEMENT_HEALTH_KUBERNETES_ENABLED: "false"
      SPRING_CLOUD_DISCOVERY_CLIENT_HEALTH_INDICATOR_ENABLED: "false"
      JAVA_TOOL_OPTIONS: >
        -XX:+UseG1GC
        -XX:+UseStringDeduplication
        -Dsun.jnu.encoding=UTF-8
        -Dfile.encoding=UTF-8
  resources: # One pod is good for ~ 400 users
    requests:
      memory: 1Gi
      cpu: 500m
    limits:
      memory: 1536Mi
      cpu: 1
  probes:
    enabled: true
    liveness:
      probe:
        periodSeconds: 40
        timeoutSeconds: 2
        successThreshold: 1
        failureThreshold: 3
        initialDelaySeconds: 60
    readiness:
      probe:
        periodSeconds: 20
        timeoutSeconds: 5
        successThreshold: 1
        failureThreshold: 10
        initialDelaySeconds: 60

report:
  replicaCount: 1
  image: allure-report
  tolerations: []
  affinity: {}
  nodeSelector: {}
  service:
    port: 8081
  persistence:
    accessMode: ReadWriteOnce
    size: 10Gi
    annotations: {}
    finalizers:
      - kubernetes.io/pvc-protection
  env:
    open:
      TZ: "Europe/Moscow"
      SERVER_SERVLET_CONTEXTPATH: /rs/
      SPRING_OUTPUT_ANSI_ENABLED: never
      LOGGING_LEVEL_IO_QAMETA_ALLURE: warn
      LOGGING_LEVEL_IO_QAMETA_ALLURE_REPORT_ISSUE_LISTENER: error
      LOGGING_LEVEL_ORG_SPRINGFRAMEWORK: warn
      LOGGING_LEVEL_COM_ZAXXER_HIKARI: warn
      SPRING_PROFILES_ACTIVE: kubernetes
      SPRING_DATASOURCE_DRIVER_CLASS_NAME: org.postgresql.Driver
      SPRING_JPA_DATABASE_PLATFORM: org.hibernate.dialect.PostgreSQL9Dialect
      SPRING_JPA_PROPERTIES_HIBERNATE_GLOBALLY_QUOTED_IDENTIFIERS: 'true'
      MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE: health,info,prometheus,configprops
      MANAGEMENT_METRICS_EXPORT_PROMETHEUS_ENABLED: 'true'
      SERVER_ERROR_INCLUDE_STACKTRACE: always
      SPRING_DATASOURCE_HIKARI_CONNECTIONTIMEOUT: "60000"
      MANAGEMENT_ENDPOINT_HEALTH_CACHE_TIME-TO-LIVE: 19s
      MANAGEMENT_HEALTH_DISKSPACE_ENABLED: "false"
      MANAGEMENT_HEALTH_KUBERNETES_ENABLED: "false"
      SPRING_CLOUD_DISCOVERY_CLIENT_HEALTH_INDICATOR_ENABLED: "false"
      JAVA_TOOL_OPTIONS: >
        -XX:+UseG1GC
        -XX:+UseStringDeduplication
        -Dsun.jnu.encoding=UTF-8
        -Dfile.encoding=UTF-8
  resources: # One pod is good for ~ 400 users
    requests:
      memory: 3Gi
      cpu: 500m
    limits:
      memory: 3Gi
      cpu: 2
  probes:
    enabled: true
    liveness:
      probe:
        periodSeconds: 40
        timeoutSeconds: 2
        successThreshold: 1
        failureThreshold: 3
        initialDelaySeconds: 300
    readiness:
      probe:
        periodSeconds: 30
        timeoutSeconds: 5
        successThreshold: 1
        failureThreshold: 10
        initialDelaySeconds: 60
```

### Minio Example:
```
---
minio:
  enabled: true
  auth:
    rootUser: WBuetMuTAMAB4M78NG3gQ4dCFJr3SSmU # Replace with your Access Key
    rootPassword: m9F4qupW4ucKBDQBWr4rwQLSAeC6FE2L # Replace with your Secret Key
  disableWebUI: true
  service:
    ports:
      api: 9000
  defaultBuckets: allure-testops
  defaultRegion: qameta-0
  provisioning:
    enabled: true
    buckets:
      - name: allure-testops
        region: qameta-0
    config:
      - name: region
        options:
          name: qameta-0
```

### Minio Gateway Example:
```
---
# This configuration is used when Minio acting as S3 Proxy
minio:
  enabled: true
  auth:
    rootUser: WBuetMuTAMAB4M78NG3gQ4dCFJr3SSmU # Replace with your Access Key
    rootPassword: m9F4qupW4ucKBDQBWr4rwQLSAeC6FE2L # Replace with your Secret Key
  disableWebUI: true
  service:
    ports:
      api: 9000
  defaultBuckets: allure-testops
  defaultRegion: qameta-0
  provisioning:
    enabled: true
    buckets:
      - name: allure-testops
        region: qameta-0
    config:
      - name: region
        options:
          name: qameta-0
  gateway:
    enabled: true
    type: s3 # Could be azure, gcs, nas, s3 Details @ https://artifacthub.io/packages/helm/bitnami/minio Gateway
    replicaCount: 1
    auth:
      s3:
        serviceEndpoint: https://s3.amazonaws.com # Any S3 EP except azure, gcs
        accessKey: foo
        secretKey: bar

```