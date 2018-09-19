apiVersion: v1
kind: Service
metadata:
  name: {{ template "bro.fullname" . }}-logger
  labels:
    app: {{ template "bro.name" . }}
    chart: {{ template "bro.chart" . }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
    component: logger
spec:
  type: ClusterIP
  ports:
    - port: {{ .Values.settings.logger.port }}
      targetPort: {{ .Values.settings.logger.port }}
      protocol: TCP
      name: logger
  selector:
    app: {{ template "bro.name" . }}
    release: {{ .Release.Name }}
    component: logger
