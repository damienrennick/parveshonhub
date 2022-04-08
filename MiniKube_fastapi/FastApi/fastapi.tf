terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

#Create a deployment of fastapi with resources.
resource "kubernetes_deployment" "fastapi_deployment" {
  metadata {
    name = "tf_fastapi_deployment"
    labels = {
      app = "fapi"
    }
  }
  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "fapi"
      }
    }

    template {
      metadata {
        labels = {
          app = "fapi"
        }
      }

      spec {
        container {
          image = "4oh4/kubernetes-fastapi:1.0.0"
          name  = "fapi"

          resources {
            limits = {
              cpu    = "2"
              memory = "2048Mi"
            }
            requests = {
              cpu    = "0.5"
              memory = "500Mi"
            }
          }
        }
      }
    }
  }
}

#creating LB service
resource "kubernetes_service" "fastapi_service" {
  metadata {
    name = "tf-fastapi_service"
  }
  spec {
    selector = {
      app = "fapi"
    }
    session_affinity = "ClientIP"
    port {
      port        = 8080
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

#Autoscaling of deployments horizontally
resource "kubernetes_horizontal_pod_autoscaler" "kube_pod_scaler" {
  metadata {
    name = "tf_kube_pod_scaler"
  }

  spec {
    max_replicas = 5
    min_replicas =  2

    scale_target_ref {
      kind = "Deployment"
      name = "tf_fastapi_deployment"
    }
  }
}


#Setting up prometheus
resource "kubernetes_namespace" "ktc-monitor" {
  metadata {
    annotations = {
      name = "ktc-monitor"
    }
    labels = {
      mylabel = "ktc-monitor"
    }
    name = "ktc-monitor"
  }
}

resource "kubernetes_cluster_role" "ktc-prom-cr" {
  metadata {
    name = "ktc-prom-cr"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "services", "endpoints", "pods", "configmaps", "/metrics"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_service_account" "ktc-prom-sa" {
  metadata {
    name = "ktc-prom-sa"
  }
}

resource "kubernetes_cluster_role_binding" "ktc-prom-crb" {
  metadata {
    name = "ktc-prom-crb"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ktc-prom-cr"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "ktc-prom-sa"
    namespace = "default"
  }

}

resource "kubernetes_config_map" "ktc-prom-cm" {
  metadata {
    name = "ktc-prom-cm"
  }

  data = {
    "prometheus.yml" = "${file("/opt/project/prometheus_configMap.yml")}"
  }
}

resource "kubernetes_deployment" "ktc-prom-deploy" {
  metadata {
    # name = "ktc-prom-deploy"
    name = "prom-pod"
    labels = {
      name = "prom-pod"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "prom-pod"
      }
    }

    template {
      metadata {
        labels = {
          name = "prom-pod"
        }
      }
      spec {
        container {
          name  = "prom-pod"
          image = "prom/prometheus"
          volume_mount {
            name = "config-volume"
            mount_path = "/etc/prometheus"
          }
          port {
            container_port = 9090
          }

        }
        volume {
          name = "config-volume"
          config_map {
            name = "ktc-prom-cm"
          }
        }
        service_account_name = "ktc-prom-sa"
      }
    }
  }
}

resource "kubernetes_service" "ktc-prom-service" {
  metadata {
    name = "ktc-prom-service"
  }
  spec {
    selector = {
      "name" = "prom-pod"
    }
    port {
      name        = "prom-port"
      node_port   = 30900
      protocol    = "TCP"
      port        = 9090
      target_port = 9090
    }
    type = "NodePort"
  }
}