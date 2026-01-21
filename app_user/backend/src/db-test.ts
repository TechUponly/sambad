import "reflect-metadata";
console.log("1. reflect-metadata imported");

import { DataSource } from "typeorm";
console.log("2. DataSource imported");

import { User } from "./models/user";
console.log("3. User imported");

export const AppDataSource = new DataSource({
  type: "postgres",
  host: "localhost",
  port: 5432,
  username: "shamrai",
  password: "",
  database: "sambad",
  entities: [User],
  synchronize: false,
  logging: true,
});

console.log("4. DataSource created");
