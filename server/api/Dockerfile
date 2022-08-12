FROM denoland/deno:1.24.2

EXPOSE 8080

WORKDIR /app

USER deno

COPY . ./
RUN deno cache --importmap=imports.json src/main.ts

CMD ["task", "start"]
