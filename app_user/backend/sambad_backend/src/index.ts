require('reflect-metadata');
require('dotenv').config();

const express = require('express');
const http = require('http');
const cors = require('cors');
const { ApolloServer } = require('apollo-server-express');

const { initDB } = require('./db');
const { typeDefs } = require('./typeDefs');
const { resolvers } = require('./resolvers');
const { authMiddleware } = require('./utils/auth');

const PORT = process.env.PORT || 4000;

async function startServer() {
  await initDB();

  const app = express();
  app.use(cors());
  app.use(express.json());
  app.use(authMiddleware);

  const apolloServer = new ApolloServer({
    typeDefs,
    resolvers,
    context: ({ req }: any) => ({ user: req.user }),
  });

  await apolloServer.start();
  apolloServer.applyMiddleware({ app });

  const server = http.createServer(app);

  server.listen(PORT, () => {
    console.log('Server running at http://localhost:' + PORT + '/graphql');
  });
}

startServer().catch((err) => {
  console.error('Server failed to start', err);
  process.exit(1);
});
