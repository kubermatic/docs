
| Source                  | Destination                 | Expose Strategy | Ports             | Purpose                                              |
|-------------------------|-----------------------------|-----------------|-------------------|------------------------------------------------------|
| KKP Users               | Master Ingress Controller   | Any             | 443*              | Access to KKP Dashboard                              |
| KKP Operator            | Seed cluster Kubernetes API | Any             | 6443*             | Operator access                                      |
| Kubermatic API          | Seed cluster Kubernetes API | Any             | 6443*             | Operator access                                      |
| Kubermatic API          | Seed cluster nodeport-proxy | Tunneling       | 6443              | Access to User Cluster API Endpoints                 |
| Kubermatic API          | Seed cluster nodeport-proxy | NodePort        | 30000-32767**     | Access to User Cluster API Endpoints                 |
| Kubermatic API          | Seed cluster nodeport-proxy | LoadBalancer    | 30000-32767**     | Access to User Cluster API Endpoints                 |
| Seed controller manager | Cloud Provider API          | Any             | provider specific | Cloud provider api access                            |
| User cluster nodes      | Seed cluster nodeport-proxy | Tunneling       | 6443, 8088        | Access to User Cluster API Endpoints and Konnecitivy |
| User cluster nodes      | Seed cluster nodeport-proxy | NodePort        | 30000-32767**     | Access to User Cluster API Endpoints and Konnecitivy |
| User cluster nodes      | Seed cluster nodeport-proxy | LoadBalancer    | 30000-32767**     | Access to User Cluster API Endpoints and Konnecitivy |
| KKP Users               | Seed cluster nodeport-proxy | Tunneling       | 6443              | Access to User Cluster API Endpoints                 |
| KKP Users               | Seed cluster nodeport-proxy | NodePort        | 30000-32767**     | Access to User Cluster API Endpoints                 |
| KKP Users               | Seed cluster nodeport-proxy | LoadBalancer    | 30000-32767**     | Access to User Cluster API Endpoints                 |
