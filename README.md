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

Argo CD continuously monitors the `master` branch and automatically updates the Kubernetes deployments based on the manifest files located in the `manifests-argocd` directory.

##### Successful deployment
![Successful deployment](./successful_deployment.png)

#### Continuous Integration

Continuous integration is handled via GitHub Actions. The typical workflow is as follows:

1. Create a new branch.
2. Modify the necessary files.
3. Update the version in `pyproject.toml` (`version = "x.x.x"`).
4. Commit and push the changes to the remote repository.
5. Open a pull request (PR) to merge the changes into the `master` branch.

## Extra Material

### Argo Events and Workflows

Think of this section as the “cherry on top” of the repository: a focused exploration of how [Argo Events](https://argoproj.github.io/argo-events/) integrate with [Argo Workflows](https://argoproj.github.io/workflows/). The following diagram walks through a representative use case.

![Argo Events use case](./ago-event-and-workflow.png)

Please also see `/demo-argo-events/demo-event-sensor-1.yml` for a minimal running example for an Argo event. In summary:

1. Event Arrival: A webhook event (see `/demo-argo-events/job-send-webhook.yml`) hits the EventSource; Sensor dependency test-dep is satisfied.

2. Parameter Extraction: Sensor reads body.message and body.ttl from the event payload.

3. Workflow Instantiation: Sensor creates a Workflow (generateName: webhook-) injecting those values into spec.arguments.parameters (message, ttl).

4. Step 1 – Message: Alpine container prints the message.

5. Step 2 – TTL: Alpine container prints the ttl value.

6. Step 3 – Combined Script: Python script prints both and evaluates the "hook" substring condition.

7. Completion: Workflow finishes; logs show all three outputs.

**This example has nothing to do with the graph shown above.**

You can also see some demos for Argo workflows in `/demo-argo-workflows` with some of them taken directly from the git repository for the [Argo workflows](https://github.com/argoproj/argo-workflows/tree/main/examples).
