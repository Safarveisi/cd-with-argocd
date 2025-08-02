FROM python:3.12-alpine

ENV APP_HOME=/app \
    SLEEP_DURATION=5 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR $APP_HOME

# Add non-root user
RUN addgroup -g 10001 appgroup && adduser -u 10001 -S appuser -G appgroup

# Copy files
COPY entrypoint.sh .
COPY app/ app/

# Permissions
RUN chmod +x entrypoint.sh && \
    chown -R appuser:appgroup $APP_HOME

USER appuser

ENTRYPOINT ["./entrypoint.sh"]
