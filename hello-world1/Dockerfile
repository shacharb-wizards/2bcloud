#FROM node:4.2
FROM node:23-alpine3.20
COPY . /src
RUN cd /src && npm install
EXPOSE 8080
CMD ["node", "/src/server.js"]
