apiVersion: v1
kind: Service
metadata:
  name: {{ template "zeek.fullname" . }}-worker
  namespace: {{ .Values.namespace }}
  labels:
    app: {{ template "zeek.name" . }}
    chart: {{ template "zeek.chart" . }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
    component: worker
spec:
  type: NodePort
  ports:
    - port: {{ .Values.settings.worker.port }}
      targetPort: {{ .Values.settings.worker.port }}
      protocol: TCP
      name: worker
    - port: 22
      targetPort: 22
      protocol: TCP
      nodePort: 31793
      name: ssh
  selector:
    app: {{ template "zeek.name" . }}
    release: {{ .Release.Name }}
    component: worker


