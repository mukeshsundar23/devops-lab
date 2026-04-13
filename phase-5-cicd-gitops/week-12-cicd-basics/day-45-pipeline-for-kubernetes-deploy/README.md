# Day 45 — Pipeline for Kubernetes Deploy

> CI/CD that deploys to k3s

## What I Built

_CI pipeline that builds image, pushes to registry, then uses helm upgrade to deploy to k3s. kubeconfig as CI secret._

## How to Run

```bash
# Build/Run instructions here
```

## Tasks

- [ ] Store kubeconfig as masked CI variable\n- [ ] Add k8s deploy stage with kubectl/helm\n- [ ] Implement rollback on failure\n- [ ] Notify Slack on success/failure\n- [ ] Add smoke test post-deploy

## What I Learned

- [Key learning 1]
- [Key learning 2]

## Tools Used

`gitlab-ci` · `helm` · `kubectl` · `kubernetes`

## Resume Bullet

> _Implemented CI/CD pipeline with Kubernetes deployment via Helm with rollback and Slack notifications_
