FROM openfaas/of-watchdog:0.7.7 as watchdog
FROM python:3.7-alpine

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Add non root user
RUN addgroup -S app && adduser app -S -G app
WORKDIR /home/app/

COPY requirements.txt   .
RUN pip install -r requirements.txt
RUN chown -R app:app ./

ADD entrypoint /entrypoint

USER app

ENV PATH=$PATH:/home/app/.local/bin
ENV function_process="python main.py"

HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1

CMD ["/entrypoint"]
