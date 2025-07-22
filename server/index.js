import express from "express";
import cors from "cors";
import { TodoService } from "./todoService.js";

const app = express();
app.use(cors());
app.use(express.json());

// Initialiser le service TodoService
const todoService = new TodoService();

app.get("/todos", async (req, res) => {
  try {
    const todos = await todoService.getAllTodos();
    res.json(todos);
  } catch (error) {
    console.error("Erreur /todos:", error);
    res.status(500).json({ error: error.message });
  }
});

app.get("/todos/:id", async (req, res) => {
  try {
    const id = req.params.id;
    const todo = await todoService.getTodoById(id);

    if (!todo) {
      return res.status(404).json({ error: "Tâche non trouvée" });
    }

    res.json(todo);
  } catch (error) {
    console.error("Erreur /todos/:id:", error);
    res.status(500).json({ error: error.message });
  }
});

app.post("/todos", async (req, res) => {
  try {
    const { text } = req.body;

    if (!text || text.trim() === "") {
      return res.status(400).json({ error: "Le texte de la tâche est requis" });
    }

    const newTodo = await todoService.createTodo(text);
    res.status(201).json(newTodo);
  } catch (error) {
    console.error("Erreur POST /todos:", error);
    res.status(500).json({ error: error.message });
  }
});

app.put("/todos/:id", async (req, res) => {
  try {
    const id = req.params.id;
    const { text, completed } = req.body;

    if (text !== undefined && text.trim() === "") {
      return res
        .status(400)
        .json({ error: "Le texte de la tâche ne peut pas être vide" });
    }

    const updatedTodo = await todoService.updateTodo(id, { text, completed });

    if (!updatedTodo) {
      return res.status(404).json({ error: "Tâche non trouvée" });
    }

    res.json(updatedTodo);
  } catch (error) {
    console.error("Erreur PUT /todos/:id:", error);
    res.status(500).json({ error: error.message });
  }
});

app.delete("/todos/:id", async (req, res) => {
  try {
    const id = req.params.id;
    const deletedTodo = await todoService.deleteTodo(id);

    if (!deletedTodo) {
      return res.status(404).json({ error: "Tâche non trouvée" });
    }

    res.json(deletedTodo);
  } catch (error) {
    console.error("Erreur DELETE /todos/:id:", error);
    res.status(500).json({ error: error.message });
  }
});

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || "development",
    version: "2.0.0",
    database: "DynamoDB",
    region: process.env.AWS_REGION || "eu-west-1",
    table: process.env.DYNAMODB_TABLE_NAME || "cloud-devops-app-todos",
  });
});

// Démarrer le serveur
const startServer = async () => {
  try {
    // Initialiser les todos par défaut
    await todoService.initializeDefaultTodos();

    app.listen(3005, () => {
      console.log(`🚀 Server is running on port 3005`);
      console.log(`🌍 Environment: ${process.env.NODE_ENV || "development"}`);
      console.log(
        `💾 Database: DynamoDB (${process.env.AWS_REGION || "eu-west-1"})`
      );
      console.log(
        `📊 Table: ${
          process.env.DYNAMODB_TABLE_NAME || "cloud-devops-app-todos"
        }`
      );
      console.log(`💚 Health check available at: http://localhost:3005/health`);
    });
  } catch (error) {
    console.error("❌ Erreur lors du démarrage du serveur:", error);
    process.exit(1);
  }
};

startServer();
