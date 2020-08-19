apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ template "zeek.fullname" . }}-worker
  namespace: {{ .Values.namespace }}
  labels:
    app: {{ template "zeek.name" . }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
    component: worker
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ template "zeek.name" . }}
  template:
    metadata:
      labels:
        app: {{ template "zeek.name" . }}
        release: {{ .Release.Name }}
        module: {{ .Chart.Name }}
        component: worker
    spec:
      hostNetwork: true
      containers:
      - name: worker
        image: {{ .Values.image.repository -}}:{{- .Values.image.tag }}
        ports:
        - containerPort: 22
        env:
          - name: CLUSTER_NODE
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
        imagePullPolicy: {{ .Values.image.pullPolicy }}
      nodeSelector:
        kubernetes.io/hostname: {{ .Values.nodeSelector }}

