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

1. Event Arrival: A webhook event (see `/demo-argo-events/job-send-webhook.yml`) hits the EventSource; Sensor dependency `test-dep` is satisfied.

2. Parameter Extraction: Sensor reads `body.message` and `body.ttl` from the event payload.

3. Workflow creation (`generateName: webhook‑`) with a DAG entrypoint named `print`.

| Order | Task (template)                                  | Action & Dependencies                                                                                                                                                                                                                                    |
| ----: | ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     1 | **`print-body-message`** (`print-message`)       | Alpine container echoes the **`message`** (`"The message is: {{inputs.parameters.message}}"`).                                                                                                                                                           |
|     2 | **`print-body-ttl`** (`print-ttl`)               | Echoes the **`ttl`** (`"This message lives for {{inputs.parameters.ttl}}"`). **Depends on 1.**                                                                                                                                                           |
|     3 | **`print-body-all`** (`print-both`)              | Python (3.11-alpine) prints both params and does a simple `"hook"` substring check. **Depends on 1 & 2.**                                                                                                                                                |
|     4 | **`clone-my-repo`** (`clone-repo`)               | Clones GitHub repo **`Safarveisi/airflow-stackable`** (branch **`master`**) into `/tmp/`, then **outputs** `/tmp/pyproject.toml` as an artifact and **uploads to S3** at `customerintelligence/argo/repo/<repo>/pyproject.toml`. **Depends on 1, 2, 3.** |
|     5 | **`print-poetry-file`** (`print-poetry`)         | **Downloads the artifact** from step 4 (`from: "{{tasks.clone-my-repo.outputs.artifacts.poetry-file}}"`) to **`/tmp/pyproject`** (input path of this template) and `cat`s it. **Depends on 4.**                                                          |
|     6 | **`mlflow-connect`** (`list-mlflow-experiments`) | Runs the container `ciaa/mlflow-connect:latest` to list MLflow experiments (connects via its internal config/env). **Depends on 1.**                                                                                                                     |
|     7 | **`snowflake-connect`** (`snowflake-table`)      | Runs `ciaa/snowflake-connect:latest`; Snowflake creds injected from Kubernetes Secret `snowflake-credentials` (keys: `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`, `SNOWFLAKE_ACCOUNT`). **Depends on 1.**                                                     |
                                                                                                     |
Parallelism note: after 1, tasks 2, 6, and 7 may run in parallel; 3 waits for 1 & 2; 4 waits for 1, 2, 3; 5 waits for 4.

#### Key Details

* Triggering: An Argo Events Sensor (`Sensor` named `webhook` in namespace `argo-events`) creates the `Workflow` on events from `eventSourceName: webhook`, `eventName: example`.

* Parameters: `message` and `ttl` are mapped from the webhook payload (`body.message`, `body.ttl`) into the Workflow’s `spec.arguments`.

* Entrypoint & Type: `entrypoint: print` uses a DAG with explicit `dependencies` for ordering and parallelism.

* Artifact passing:

  * `clone-repo` outputs artifact `poetry-file` at path `/tmp/pyproject.toml` and uploads to S3 (endpoint `s3-de-central.profitbricks.com:443`, bucket `customerintelligence`, key `argo/repo/{{inputs.parameters.repo-name}}/pyproject.toml`).

  * `print-poetry-file` inputs artifact `pyproject` and places it at `/tmp/pyproject`, then prints it.

* S3 credentials: Provided via Secret `s3-credentials` (`accessKey`, `secretKey`) referenced in the output artifact config of `clone-repo`.

* Snowflake credentials: The `snowflake-table` template reads env vars from Secret `snowflake-credentials` (`SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`, `SNOWFLAKE_ACCOUNT`).

* Images:

  * Echo steps use `alpine:latest`; Python step uses `python:3.11-alpine`; git clone uses `alpine/git:v2.49.1`.

  * Internal service connectors: `ciaa/mlflow-connect:latest`, `ciaa/snowflake-connect:latest`.

* ServiceAccount: The Sensor runs as `operate-workflow-sa`. (The generated Workflow does not set `serviceAccountName`, so Workflow pods will use the namespace default unless you add one to the Workflow spec.)

You can use the `argo cli` to see the status of the workflow:

```bash
argo get @latest -n argo-events
```

<details>
<summary><strong>Click to expand raw CLI output</strong></summary>

```text
Name:                webhook-jkvzh
Namespace:           argo-events
ServiceAccount:      unset (will run with the default ServiceAccount)
Status:              Succeeded
Conditions:
 PodRunning          False
 Completed           True
Created:             Fri Aug 01 14:08:02 +0200 (14 minutes ago)
Started:             Fri Aug 01 14:08:02 +0200 (14 minutes ago)
Finished:            Fri Aug 01 14:08:52 +0200 (14 minutes ago)
Duration:            50 seconds
Progress:            7/7
ResourcesDuration:   0s*(1 cpu),37s*(100Mi memory)
Parameters:
  message:           this is my first webhook
  ttl:               60s

STEP                     TEMPLATE                 PODNAME                                           DURATION  MESSAGE
 ✔ webhook-jkvzh         print
 ├─✔ print-body-message  print-message            webhook-jkvzh-print-message-177711544             6s
 ├─✔ mlflow-connect      list-mlflow-experiments  webhook-jkvzh-list-mlflow-experiments-2843226054  8s
 ├─✔ print-body-ttl      print-ttl                webhook-jkvzh-print-ttl-4108477847                5s
 ├─✔ snowflake-connect   snowflake-table          webhook-jkvzh-snowflake-table-1032547547          13s
 ├─✔ print-body-all      print-both               webhook-jkvzh-print-both-66352536                 4s
 ├─✔ clone-my-repo       clone-repo               webhook-jkvzh-clone-repo-227934185                8s
 └─✔ print-poetry-file   print-poetry             webhook-jkvzh-print-poetry-3247567644             6s
```

</details>


**This example has nothing to do with the graph shown above.**

You can also see some demos for Argo workflows in `/demo-argo-workflows` with some of them taken directly from the git repository for the [Argo workflows](https://github.com/argoproj/argo-workflows/tree/main/examples).
