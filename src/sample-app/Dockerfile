FROM node:24

WORKDIR /app

COPY . .

RUN npm install

# COPY --from=icr.io/instana/aws-fargate-nodejs:latest /instana /instana
# RUN /instana/setup.sh
# ENV NODE_OPTIONS="--require /instana/node_modules/@instana/aws-fargate"

EXPOSE 4000
CMD ["node", "server.js"]
