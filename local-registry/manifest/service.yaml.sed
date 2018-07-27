kind: Service
apiVersion: v1
metadata:
  name: {{.name}} 
spec:
  clusterIP: {{.cluster.ip}}
  ports:
    - protocol: TCP 
      port: {{.cluster.ip.port}} 
      targetPort: {{.port}}
