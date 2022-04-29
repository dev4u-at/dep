provider "helm" {
  kubernetes {
    config_path = "./../kube.conf"  #PATH to KUBERNETES CONFIG FILE
  }
}

#Deploy Longhorn via HELM
resource "helm_release" "nextcloud" {
  #depends_on = [kubernetes_namespace.longhorn]   #Wait for the Namespace
  name       = "nextcloud"
  namespace  = "app-nextcloud" #name of the namespace
  create_namespace = "true" #Check if namespace exists
  repository = "https://nextcloud.github.io/helm/"
  chart      = "nextcloud" 

#NEXTCLOUD COMMON SETTINGS
   values = [
    "${file("values.yaml")}"
  ]

}


