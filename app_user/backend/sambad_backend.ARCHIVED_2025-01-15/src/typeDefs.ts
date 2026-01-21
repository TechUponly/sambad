import { gql } from 'apollo-server-express';
import fs from 'fs';
import path from 'path';

// Use process.cwd() for ts-node compatibility
const schemaPath = path.join(process.cwd(), 'src', 'schema.graphql');
export const typeDefs = gql(
  fs.readFileSync(schemaPath, 'utf8')
);
