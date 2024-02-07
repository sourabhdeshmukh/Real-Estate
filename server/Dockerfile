FROM node:20.11.0
RUN mkdir -p /app/
WORKDIR /app
COPY . ./ 
RUN npm install && touch /app/.env
EXPOSE 3000
CMD [ "npm", "run", "dev"]