# kube-bro

This is a [Helm Chart](https://helm.sh/) packaging 
[Bro IDS](https://www.bro.org/) for easy installation onto Kubernetes. That
said, there are some prerequisites to make this work properly. Detailed
discussion of this is available in 
[this blog series](https://www.ixiacom.com/company/blog/threat-hunting-%C2%A0scale-part-one-series).

In a nutshell.
 * You need to have Elasticsearch installed somewhere (for example using
   [Bitnami's Helm Chart](https://bitnami.com/stack/elasticsearch/helm)
 * You need to have [CloudLens](https://ixia.cloud/)
 * You need a project key from a CloudLens project
 * You probably want Kibana also installed (for example using the [stable Helm Repo's Kibana chart.](https://github.com/helm/charts/tree/master/stable/kibana)


## Settings

There are three important settings you will need to set when running this chart.

 * You need to explicitly accept the CloudLens EULA by setting
   global.cloudlens.acceptEula to 'y'
 * You need to give the project Key from your CloudLens project by settings
   global.cloudlens.apikey.
 * You need to point to the elasticsearch cluster by setting elasticsearch.url

For example,

```
helm install kube-bro-0.1.0.tgz --name bro --tls --set elasticsearch.url=bro-es-elasticsearch-coordinating-only:9200,global.cloudlens.acceptEula=y,global.cloudlens.apikey=sxxxxxxxxxxxxxxxxxxxxxxxxxx
```
