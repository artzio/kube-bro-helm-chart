apiVersion: v1
kind: Service
metadata:
  name: {{ template "bro.fullname" . }}-proxy
  labels:
    app: {{ template "bro.name" . }}
    chart: {{ template "bro.chart" . }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
    component: proxy
spec:
  type: ClusterIP
  ports:
    - port: {{ .Values.settings.proxy.port }}
      targetPort: {{ .Values.settings.proxy.port }}
      protocol: TCP
      name: proxy
  selector:
    app: {{ template "bro.name" . }}
    release: {{ .Release.Name }}
    component: proxy


