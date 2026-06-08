FROM node:20-alpine

WORKDIR /app

COPY forward-auth.js token.js .

EXPOSE 3000

CMD ["node", "forward-auth.js"]
