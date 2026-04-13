# devops-lab

My hands-on DevOps engineering portfolio — 60 projects across 20 weeks, covering everything from Linux fundamentals to production GitOps platforms.

Built while working full-time as a DevOps Engineer. Every project is something I built, broke, debugged, and documented.

## Highlighted Projects

> These are my top builds. Each one is production-grade and interview-ready.

| Project | What I Built | Tools |
|---------|-------------|-------|
| [Full GitOps Platform](phase-8-capstone/week-19/day-58-gitops-platform/) | End-to-end: code push → CI → Docker → ArgoCD → Prometheus → Slack | GitLab CI, ArgoCD, Helm, Prometheus, k3s |
| [HPA + KEDA Autoscaling](phase-3-orchestration/week-07/) | Horizontal Pod Autoscaler + event-driven scaling on Redis queue length | Kubernetes, KEDA, k6, Redis |
| [Terraform Multi-Env IaC](phase-4-iac/week-10/day-38-terraform-workspaces/) | Dev/staging/prod from one codebase using workspaces | Terraform, Azure, GitLab CI |
| [Prometheus + Grafana Stack](phase-6-observability/week-15/day-51-prometheus-grafana/) | Full observability with custom FastAPI metrics and golden-signal dashboards | Prometheus, Grafana, cAdvisor |
| [Security-Gated CI Pipeline](phase-5-cicd/week-13/day-47-pipeline-security/) | SAST + SCA + image scanning with auto-fail on critical CVEs | Bandit, Safety, Trivy, GitLab CI |

## Repository Structure

```
devops-lab/
│
├── phase-1-foundations/
│   ├── week-01-linux/
│   │   ├── day-01-system-recon/
│   │   │   ├── README.md
│   │   │   ├── sysrecon.sh
│   │   │   └── screenshots/
│   │   ├── day-02-user-auditor/
│   │   ├── day-03-process-service-mgr/
│   │   ├── day-04-filesystem-storage/
│   │   └── day-05-hardening-checklist/
│   ├── week-02-networking/
│   │   ├── day-06-network-fundamentals/
│   │   ├── day-07-network-discovery/
│   │   ├── day-08-firewall-iptables/
│   │   ├── day-09-reverse-proxy-lb/
│   │   └── day-10-ssh-tunnels-vpn/
│   └── week-03-bash-git-python/
│       ├── day-11-log-parser/
│       ├── day-12-backup-system/
│       ├── day-13-git-workflow/
│       ├── day-14-gitlab-admin/
│       ├── day-15-python-toolkit/
│       └── day-16-infra-api-client/
│
├── phase-2-containerization/
│   ├── week-04-docker-core/
│   │   ├── day-17-docker-fundamentals/
│   │   ├── day-18-multistage-build/
│   │   ├── day-19-compose-fullstack/
│   │   ├── day-20-private-registry/
│   │   └── day-21-docker-networking/
│   └── week-05-docker-advanced/
│       ├── day-22-docker-api-controller/
│       ├── day-23-resource-governance/
│       └── day-24-ci-runner/
│
├── phase-3-orchestration/
│   ├── week-06-k8s-basics/
│   │   ├── day-25-k8s-fundamentals/
│   │   └── day-26-configmaps-secrets/
│   ├── week-07-k8s-intermediate/
│   │   ├── day-27-hpa-autoscaling/
│   │   ├── day-28-pvc-storage/
│   │   └── day-29-rbac/
│   └── week-08-k8s-advanced/
│       ├── day-30-helm-charts/
│       ├── day-31-keda/
│       └── day-32-argocd-gitops/
│
├── phase-4-iac/
│   ├── week-09-terraform-basics/
│   │   ├── day-33-provision-vm/
│   │   ├── day-34-remote-state/
│   │   └── day-35-cloud-overview/
│   ├── week-10-terraform-advanced/
│   │   ├── day-36-terraform-modules/
│   │   ├── day-37-provision-aks/
│   │   └── day-38-terraform-workspaces/
│   └── week-11-ansible/
│       ├── day-39-server-provisioning/
│       ├── day-40-nginx-tls-role/
│       ├── day-41-terraform-ansible/
│       └── day-42-ansible-k8s-setup/
│
├── phase-5-cicd/
│   ├── week-12-pipelines/
│   │   ├── day-43-gitlab-ci-basics/
│   │   ├── day-44-registry-deploy/
│   │   └── day-45-k8s-deploy-pipeline/
│   ├── week-13-advanced-ci/
│   │   ├── day-46-semantic-versioning/
│   │   ├── day-47-pipeline-security/
│   │   └── day-48-matrix-builds/
│   └── week-14-iac-pipelines/
│       ├── day-49-terraform-ci/
│       └── day-50-terratest/
│
├── phase-6-observability/
│   ├── week-15-metrics-logging/
│   │   ├── day-51-prometheus-grafana/
│   │   └── day-52-elk-stack/
│   └── week-16-alerting/
│       ├── day-53-alertmanager/
│       └── day-54-incident-bot/
│
├── phase-7-security/
│   ├── week-17-secrets/
│   │   ├── day-55-vault/
│   │   └── day-56-network-policy/
│   └── week-18-governance/
│       └── day-57-opa-gatekeeper/
│
├── phase-8-capstone/
│   ├── week-19-capstone/
│   │   ├── day-58-gitops-platform/
│   │   └── day-59-multicloud-vpn/
│   └── week-20-interview-prep/
│       └── day-60-portfolio/
│
├── .gitignore
└── README.md ← you are here
```

## Tech Stack

**Core**: Linux, Bash, Python, Git

**Containers & Orchestration**: Docker, Kubernetes (k3s), Helm, KEDA, ArgoCD

**Infrastructure as Code**: Terraform, Ansible

**Cloud**: Azure (primary), AWS (secondary)

**CI/CD**: GitLab CI, semantic-release, Trivy, Bandit

**Observability**: Prometheus, Grafana, ELK (Elasticsearch + Logstash + Kibana), Alertmanager

**Security**: HashiCorp Vault, OPA Gatekeeper, NetworkPolicy

## How I Work on This

- One feature branch per project (`day-01-system-recon`, `day-02-user-auditor`, etc.)
- Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`
- Merge to `main` via MR — even solo, the habit matters
- Every project folder has its own README with what I built, how to run it, and what I learned
- Push daily — consistency over perfection

## About Me

DevOps Engineer with 1 year of production experience. Stack includes Azure, GCP, GitLab CI/CD, Docker, Kubernetes, Terraform, and Python.

Currently building this portfolio to deepen my skills and prepare for my next role at a product company or funded startup.

- [LinkedIn](https://linkedin.com/in/mukeshsundarp)
- [Email](mukeshsundar2362004@gmail.com)