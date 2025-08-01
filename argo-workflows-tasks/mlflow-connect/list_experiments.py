import mlflow
from mlflow.tracking import MlflowClient


def main():
    mlflow.set_tracking_uri("http://85.215.137.231:5002")

    print(f"Using MLflow Tracking URI: {mlflow.get_tracking_uri()}")

    client = MlflowClient()

    experiments = client.search_experiments()
    print(f"Found {len(experiments)} experiments:")
    for exp in experiments:
        print(f" - {exp.name} (ID: {exp.experiment_id})")


if __name__ == "__main__":
    main()
