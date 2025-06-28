## CI/CD Pipeline using GitHub Actions (CI) and Argocd (CD)

#### Workflow
![CD with Argocd](./argocd.png)

#### Successful deployment
![Successful deployment](./successful_deployment.png)

#### Usage
To deploy an Argo CD application, apply the manifest file to your Kubernetes cluster:

```bash
kubectl apply -f argocd-application.yml
```

Argo CD continuously monitors the master branch and automatically updates the Kubernetes deployments based on the manifest files located in the `manifests` directory. Continuous integration is handled via GitHub Actions. The typical workflow is as follows:

1. Create a new branch.
2. Modify the necessary files.
3. Update the version in `pyproject.toml` (`version = "x.x.x"`).
4. Commit and push the changes to the remote repository.
5. Open a pull request (PR) to merge the changes into the `master` branch.
