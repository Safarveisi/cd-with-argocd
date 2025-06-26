FROM alpine:3.19

ENV APP_HOME=/app \
    SLEEP_DURATION=3600

WORKDIR $APP_HOME

RUN addgroup -g 10001 appgroup && adduser -u 10001 -S appuser -G appgroup

COPY entrypoint.sh .

RUN chmod +x entrypoint.sh

RUN chown -R appuser:appgroup $APP_HOME

USER appuser

ENTRYPOINT ["./entrypoint.sh"]