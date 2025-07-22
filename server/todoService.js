import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  ScanCommand,
  GetCommand,
  PutCommand,
  UpdateCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";

// Configuration DynamoDB
const client = new DynamoDBClient({
  region: process.env.AWS_REGION || "eu-west-1",
});

const dynamoDb = DynamoDBDocumentClient.from(client);
const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || "cloud-devops-app-todos";

// Service pour gérer les todos avec DynamoDB
export class TodoService {
  // Récupérer tous les todos
  async getAllTodos() {
    try {
      const command = new ScanCommand({
        TableName: TABLE_NAME,
      });

      const result = await dynamoDb.send(command);
      return result.Items || [];
    } catch (error) {
      console.error("Erreur lors de la récupération des todos:", error);
      throw new Error("Impossible de récupérer les todos");
    }
  }

  // Récupérer un todo par ID
  async getTodoById(id) {
    try {
      const command = new GetCommand({
        TableName: TABLE_NAME,
        Key: { id: id.toString() },
      });

      const result = await dynamoDb.send(command);
      return result.Item || null;
    } catch (error) {
      console.error("Erreur lors de la récupération du todo:", error);
      throw new Error("Impossible de récupérer le todo");
    }
  }

  // Créer un nouveau todo
  async createTodo(text) {
    try {
      const id = Date.now().toString(); // Utilise timestamp comme ID
      const todo = {
        id,
        text: text.trim(),
        completed: false,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      const command = new PutCommand({
        TableName: TABLE_NAME,
        Item: todo,
      });

      await dynamoDb.send(command);
      return todo;
    } catch (error) {
      console.error("Erreur lors de la création du todo:", error);
      throw new Error("Impossible de créer le todo");
    }
  }

  // Mettre à jour un todo
  async updateTodo(id, updates) {
    try {
      const { text, completed } = updates;

      // Construire l'expression de mise à jour dynamiquement
      let updateExpression = "SET updatedAt = :updatedAt";
      const expressionAttributeValues = {
        ":updatedAt": new Date().toISOString(),
      };

      if (text !== undefined) {
        updateExpression += ", #text = :text";
        expressionAttributeValues[":text"] = text.trim();
      }

      if (completed !== undefined) {
        updateExpression += ", completed = :completed";
        expressionAttributeValues[":completed"] = completed;
      }

      const command = new UpdateCommand({
        TableName: TABLE_NAME,
        Key: { id: id.toString() },
        UpdateExpression: updateExpression,
        ExpressionAttributeNames:
          text !== undefined ? { "#text": "text" } : undefined,
        ExpressionAttributeValues: expressionAttributeValues,
        ReturnValues: "ALL_NEW",
      });

      const result = await dynamoDb.send(command);
      return result.Attributes;
    } catch (error) {
      console.error("Erreur lors de la mise à jour du todo:", error);
      throw new Error("Impossible de mettre à jour le todo");
    }
  }

  // Supprimer un todo
  async deleteTodo(id) {
    try {
      const command = new DeleteCommand({
        TableName: TABLE_NAME,
        Key: { id: id.toString() },
        ReturnValues: "ALL_OLD",
      });

      const result = await dynamoDb.send(command);
      return result.Attributes;
    } catch (error) {
      console.error("Erreur lors de la suppression du todo:", error);
      throw new Error("Impossible de supprimer le todo");
    }
  }

  // Initialiser avec des données par défaut (appelé au démarrage)
  async initializeDefaultTodos() {
    try {
      const existingTodos = await this.getAllTodos();

      if (existingTodos.length === 0) {
        console.log("🎯 Initialisation des todos par défaut...");

        const defaultTodos = [
          { text: "Apprendre Docker", completed: false },
          { text: "Créer une API REST", completed: false },
          { text: "Déployer avec Docker Compose", completed: true },
          { text: "Utiliser DynamoDB", completed: false },
        ];

        for (const todo of defaultTodos) {
          await this.createTodo(todo.text);
          if (todo.completed) {
            // Marquer comme complété après création
            const todos = await this.getAllTodos();
            const createdTodo = todos.find((t) => t.text === todo.text);
            if (createdTodo) {
              await this.updateTodo(createdTodo.id, { completed: true });
            }
          }
        }

        console.log("✅ Todos par défaut créés avec succès!");
      }
    } catch (error) {
      console.error("⚠️  Erreur lors de l'initialisation:", error);
    }
  }
}
