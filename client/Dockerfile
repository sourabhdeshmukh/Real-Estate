FROM node:20.11.0
RUN mkdir -p /app/
WORKDIR /app
COPY . ./
RUN npm install
EXPOSE 5173
CMD [ "npm", "run", "dev"]