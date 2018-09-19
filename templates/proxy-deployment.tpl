apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "bro.fullname" . }}-proxy
  labels:
    app: {{ template "bro.name" . }}
    chart: {{ template "bro.chart" . }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
    component: proxy
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        app: {{ template "bro.name" . }}
        release: {{ .Release.Name }}
        module: {{ .Chart.Name }}
        component: proxy
    spec:
      containers:
      - name: proxy
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
          - "proxy-0"
          - local.bro
          - broctl
          - base/frameworks/cluster
          - local-proxy
          - broctl/auto
        volumeMounts:
        - name: cluster-config
          mountPath: /opt/bro/spool/installed-scripts-do-not-touch/auto
        - name: policy-config
          mountPath: /opt/bro/spool/installed-scripts-do-not-touch/site
        env:
          - name: CLUSTER_NODE
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
      volumes:
      - name: cluster-config
        configMap:
          name: {{ template "bro.fullname" .}}-cluster-configmap
      - name: policy-config
        configMap:
          name: {{ template "bro.fullname" .}}-policy
