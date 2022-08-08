FROM denoland/deno:1.22.0

EXPOSE 8080

WORKDIR /app

USER deno

COPY . ./
RUN deno cache --importmap=imports.json src/main.ts

CMD ["run", "--allow-net", "--allow-env", "--importmap=imports.json", "main.ts"]
