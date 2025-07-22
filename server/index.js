import express from "express";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json());

let todos = [
  { id: 1, text: "Apprendre Docker", completed: false },
  { id: 2, text: "Créer une API REST", completed: false },
  { id: 3, text: "Déployer avec Docker Compose", completed: true },
];

let nextId = 4;

app.get("/todos", (req, res) => {
  res.json(todos);
});

app.get("/todos/:id", (req, res) => {
  const id = parseInt(req.params.id);
  const todo = todos.find(t => t.id === id);
  
  if (!todo) {
    return res.status(404).json({ error: "Tâche non trouvée" });
  }
  
  res.json(todo);
});

app.post("/todos", (req, res) => {
  const { text } = req.body;
  
  if (!text || text.trim() === "") {
    return res.status(400).json({ error: "Le texte de la tâche est requis" });
  }
  
  const newTodo = {
    id: nextId++,
    text: text.trim(),
    completed: false
  };
  
  todos.push(newTodo);
  res.status(201).json(newTodo);
});

app.put("/todos/:id", (req, res) => {
  const id = parseInt(req.params.id);
  const { text, completed } = req.body;
  
  const todoIndex = todos.findIndex(t => t.id === id);
  
  if (todoIndex === -1) {
    return res.status(404).json({ error: "Tâche non trouvée" });
  }
  
  if (text !== undefined) {
    if (text.trim() === "") {
      return res.status(400).json({ error: "Le texte de la tâche ne peut pas être vide" });
    }
    todos[todoIndex].text = text.trim();
  }
  
  if (completed !== undefined) {
    todos[todoIndex].completed = completed;
  }
  
  res.json(todos[todoIndex]);
});

app.delete("/todos/:id", (req, res) => {
  const id = parseInt(req.params.id);
  const todoIndex = todos.findIndex(t => t.id === id);
  
  if (todoIndex === -1) {
    return res.status(404).json({ error: "Tâche non trouvée" });
  }
  
  const deletedTodo = todos.splice(todoIndex, 1)[0];
  res.json(deletedTodo);
});

app.get("/health", (req, res) => {
  res.status(200).json({ 
    status: "healthy", 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    version: "1.0.0"
  });
});

app.listen(3005, () => {
  console.log(`🚀 Server is running on port 3005`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`💚 Health check available at: http://localhost:3005/health`);
});