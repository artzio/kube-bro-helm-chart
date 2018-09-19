apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "bro.fullname" . }}-logger
  labels:
    app: {{ template "bro.name" . }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
    component: logger
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        app: {{ template "bro.name" . }}
        release: {{ .Release.Name }}
        module: {{ .Chart.Name }}
        component: logger
    spec:
      containers:
      - name: logger
        image: {{ .Values.image.repository -}}:{{- .Values.image.tag }}
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        command: 
          - "/sbin/tini"
          - "--"
          - "/bin/bash"
          - "/opt/bro/spool/installed-scripts-do-not-touch/auto/relauncher.sh"
          - "/opt/bro/share/broctl/scripts/run-bro"
          - "-1"
          - "-U"
          - ".status"
          - "-p"
          - broctl
          - "-p"
          - "broctl-live"
          - "-p"
          - local
          - "-p"
          - "logger"
          - local.bro
          - broctl
          - base/frameworks/cluster
          - local-logger.bro
          - broctl/auto
        env:
        - name: CLUSTER_NODE
          value: logger
        volumeMounts:
        - name: cluster-config
          mountPath: /opt/bro/spool/installed-scripts-do-not-touch/auto
        - name: policy-config
          mountPath: /opt/bro/spool/installed-scripts-do-not-touch/site
        - name: bro-logs
          mountPath: /opt/bro/spool/logger/
      - name: logstash
        image: {{ .Values.logstash.repository -}}:{{- .Values.logstash.tag }}
        imagePullPolicy: {{ .Values.logstash.pullPolicy }}
        volumeMounts:
        - name: logstash-config
          mountPath: /usr/share/logstash/config/
        - name: logstash-pipeline
          mountPath: /usr/share/logstash/pipeline/
        - name: bro-logs
          mountPath: /logs/
      volumes:
      - name: cluster-config
        configMap:
          name: {{ template "bro.fullname" .}}-cluster-configmap
      - name: policy-config
        configMap:
          name: {{ template "bro.fullname" .}}-policy
      - name: logstash-config
        configMap:
          name: {{ template "bro.fullname" .}}-logstash-config
      - name: logstash-pipeline
        configMap:
          name: {{ template "bro.fullname" .}}-logstash-pipeline
      - name: bro-logs
        emptyDir: {}
