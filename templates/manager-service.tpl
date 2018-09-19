apiVersion: v1
kind: Service
metadata:
  name: {{ template "bro.fullname" . }}-manager
  labels:
    app: {{ template "bro.name" . }}
    chart: {{ template "bro.chart" . }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
    component: manager
spec:
  type: ClusterIP
  ports:
    - port: {{ .Values.settings.manager.port }}
      targetPort: {{ .Values.settings.manager.port }}
      protocol: TCP
      name: manager
  selector:
    app: {{ template "bro.name" . }}
    release: {{ .Release.Name }}
    component: manager

