FROM node:alpine as build

WORKDIR /app
COPY . /app
RUN yarn
RUN yarn global add elm
RUN yarn build-prod

FROM nginx:stable-alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]