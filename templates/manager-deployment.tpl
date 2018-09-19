apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "bro.fullname" . }}-manager
  labels:
    app: {{ template "bro.name" . }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
    component: manager
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        app: {{ template "bro.name" . }}
        release: {{ .Release.Name }}
        module: {{ .Chart.Name }}
        component: manager
    spec:
      containers:
      - name: manager
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
          - "manager"
          - local.bro
          - broctl
          - base/frameworks/cluster
          - local-manager.bro
          - broctl/auto
        env:
        - name: CLUSTER_NODE
          value: manager
        volumeMounts:
        - name: cluster-config
          mountPath: /opt/bro/spool/installed-scripts-do-not-touch/auto
        - name: policy-config
          mountPath: /opt/bro/spool/installed-scripts-do-not-touch/site
      volumes:
      - name: cluster-config
        configMap:
          name: {{ template "bro.fullname" .}}-cluster-configmap
      - name: policy-config
        configMap:
          name: {{ template "bro.fullname" .}}-policy
