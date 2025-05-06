terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "C:\\Users\\MojdlMartin\\.kube\\config"
}

resource "kubernetes_namespace" "ns-demo" {
  metadata {
    name = "demo"
  }
}

resource "kubernetes_config_map" "cm-demo" {
  metadata {
    name      = "demo-config"
    namespace = kubernetes_namespace.ns-demo.metadata[0].name
  }

  data = {
    APP_MODE     = "dev"
    FEATURE_FLAG = "true"
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "demo-deployment"
    namespace = kubernetes_namespace.ns-demo.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          env_from {
            config_map_ref {
              name = kubernetes_config_map.cm-demo.metadata[0].name
            }
          }

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_service" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.ns-demo.metadata[0].name
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "nginx_ingress" {
  metadata {
    name      = "nginx-ingress"
    namespace = kubernetes_namespace.ns-demo.metadata[0].name
  }

  spec {
    rule {
      host = "demo.local"

      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.nginx_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

