provider "helm" {
  kubernetes {
    config_path = "./../kube.conf"  #PATH to KUBERNETES CONFIG FILE
  }
}

#Deploy Longhorn via HELM
resource "helm_release" "longhorn" {
  #depends_on = [kubernetes_namespace.longhorn]   #Wait for the Namespace
  name       = "longhorn"
  namespace  = "longhorn-system"
  create_namespace = "true"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn" 
}
