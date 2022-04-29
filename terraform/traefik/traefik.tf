provider "helm" {
  kubernetes {
    config_path = "./../kube.conf"  #PATH to KUBERNETES CONFIG FILE
  }
}

#Deploy TRAEFIK via HELM
resource "helm_release" "traefik" {
  #depends_on = [kubernetes_namespace.longhorn]   #Wait for the Namespace
  name       = "traefik"
  namespace  = "traefik"
  create_namespace = "true"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik" 

  values = [
    "${file("values.yaml")}"
  ]

 

}



