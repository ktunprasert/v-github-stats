FROM alpine

WORKDIR /app

COPY main ./

RUN chmod +x main

CMD ["./main"]
