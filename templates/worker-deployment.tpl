apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "bro.fullname" . }}-worker
  labels:
    app: {{ template "bro.name" . }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
    component: worker
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        app: {{ template "bro.name" . }}
        release: {{ .Release.Name }}
        module: {{ .Chart.Name }}
        component: worker
    spec:
      containers:
      - name: worker
        image: {{ .Values.image.repository -}}:{{- .Values.image.tag }}
        env:
          - name: CLUSTER_NODE
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        command: 
          - "/sbin/tini"
          - "--"
          - "/bin/bash"
          - "/opt/bro/spool/installed-scripts-do-not-touch/auto/relauncher.sh"
          - "/opt/bro/share/broctl/scripts/run-bro"
          - "-1"
          - "-i"
          - "{{ .Values.settings.worker.interface }}"
          - "-U"
          - ".status"
          - "-p"
          - broctl
          - "-p"
          - "broctl-live"
          - "-p"
          - local
          - "-p"
          - "worker-$CLUSTER_NODE"
          - local.bro
          - broctl
          - base/frameworks/cluster
          - local-worker.bro
          - broctl/auto
        volumeMounts:
        - name: cluster-config
          mountPath: /opt/bro/spool/installed-scripts-do-not-touch/auto
        - name: policy-config
          mountPath: /opt/bro/spool/installed-scripts-do-not-touch/site
      - name: cloudlens
        image: {{ .Values.global.cloudlens.repository -}}:{{- .Values.global.cloudlens.tag }}
        imagePullPolicy: {{ .Values.global.cloudlens.pullPolicy }}
        args:
          - '--accept_eula'
          - {{ required "You must explicitly accept the EULA agreement, e.g. --set global.cloudlens.acceptEula=y" .Values.global.cloudlens.acceptEula | quote }}
          - '--server'
          - '{{ with .Values.global.cloudlens.stage }}{{ . -}}-{{- end -}}agent.{{- .Values.global.cloudlens.domain }}'
          - '--apikey'
          - {{ required "An API Key must be specified e.g. --set global.cloudlens.apikey=abcdefg" .Values.global.cloudlens.apikey | quote }}
          - '--custom_tags'
          {{ range .Values.global.cloudlens.tags }}
          - {{ . | quote }}
          {{ end }}
          - "install={{- .Release.Name -}}"
          - "installrev={{- .Release.Revision -}}"
          - "version={{- .Chart.Version -}}"
          - "module={{- .Chart.Name -}}"
        securityContext:
          capabilities:
            add:
            - SYS_RAWIO
            - SYS_ADMIN
            - SYS_RESOURCE
            - NET_ADMIN
      volumes:
      - name: cluster-config
        configMap:
          name: {{ template "bro.fullname" .}}-cluster-configmap
      - name: policy-config
        configMap:
          name: {{ template "bro.fullname" .}}-policy
