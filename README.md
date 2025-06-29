## CI/CD Pipeline using GitHub Actions and Argo CD

#### Workflow
![CD with Argocd](./argocd.png)

#### Continuous Delivery

To deploy an Argo CD application, apply the associated manifest file to your Kubernetes cluster:

```bash
kubectl apply -f argocd-application.yml
```

To access the Argo CD API server, you first need to change the `argocd-server` service type to `LoadBalancer`:

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

Use the external ip of the load balander to access the UI.

Argo CD continuously monitors the `master` branch and automatically updates the Kubernetes deployments based on the manifest files located in the `manifests` directory.

##### Successful deployment
![Successful deployment](./successful_deployment.png)

#### Continuous Integration

Continuous integration is handled via GitHub Actions. The typical workflow is as follows:

1. Create a new branch.
2. Modify the necessary files.
3. Update the version in `pyproject.toml` (`version = "x.x.x"`).
4. Commit and push the changes to the remote repository.
5. Open a pull request (PR) to merge the changes into the `master` branch.
