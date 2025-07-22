import { useEffect, useState, useCallback } from "react";
import "./App.css";

type Todo = {
  id: number;
  text: string;
  completed: boolean;
};

const App = () => {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [newTodo, setNewTodo] = useState("");
  const [editingId, setEditingId] = useState<number | null>(null);
  const [editingText, setEditingText] = useState("");
  const [loading, setLoading] = useState(false);

  // Configuration de l'API selon l'environnement
  const getApiBaseUrl = () => {
    // En production sur AWS, utiliser l'URL du serveur actuel sur le port 3005
    if (window.location.hostname !== "localhost") {
      return `http://${window.location.hostname}:3005`;
    }
    // En développement local, utiliser localhost
    return "http://localhost:3005";
  };

  const API_BASE_URL = getApiBaseUrl();

  const fetchTodos = useCallback(async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/todos`);
      if (response.ok) {
        const todos = await response.json();
        setTodos(todos);
      }
    } catch (error) {
      console.error("Erreur lors du chargement des tâches:", error);
    } finally {
      setLoading(false);
    }
  }, [API_BASE_URL]);

  useEffect(() => {
    fetchTodos();
  }, [fetchTodos]);

  const addTodo = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTodo.trim()) return;

    try {
      const response = await fetch(`${API_BASE_URL}/todos`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ text: newTodo }),
      });

      if (response.ok) {
        const todo = await response.json();
        setTodos([...todos, todo]);
        setNewTodo("");
      }
    } catch (error) {
      console.error("Erreur lors de l'ajout de la tâche:", error);
    }
  };

  const deleteTodo = async (id: number) => {
    try {
      const response = await fetch(`${API_BASE_URL}/todos/${id}`, {
        method: "DELETE",
      });

      if (response.ok) {
        setTodos(todos.filter((todo) => todo.id !== id));
      }
    } catch (error) {
      console.error("Erreur lors de la suppression de la tâche:", error);
    }
  };

  const toggleTodo = async (id: number, completed: boolean) => {
    try {
      const response = await fetch(`${API_BASE_URL}/todos/${id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ completed }),
      });

      if (response.ok) {
        const updatedTodo = await response.json();
        setTodos(todos.map((todo) => (todo.id === id ? updatedTodo : todo)));
      }
    } catch (error) {
      console.error("Erreur lors de la mise à jour de la tâche:", error);
    }
  };

  const startEditing = (id: number, text: string) => {
    setEditingId(id);
    setEditingText(text);
  };

  const saveEdit = async (id: number) => {
    if (!editingText.trim()) return;

    try {
      const response = await fetch(`${API_BASE_URL}/todos/${id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ text: editingText }),
      });

      if (response.ok) {
        const updatedTodo = await response.json();
        setTodos(todos.map((todo) => (todo.id === id ? updatedTodo : todo)));
        setEditingId(null);
        setEditingText("");
      }
    } catch (error) {
      console.error("Erreur lors de la modification de la tâche:", error);
    }
  };

  const cancelEdit = () => {
    setEditingId(null);
    setEditingText("");
  };

  if (loading) {
    return <div className="loading">Chargement des tâches...</div>;
  }

  return (
    <div className="app">
      <h1>🗂️ Gestionnaire de Tâches</h1>

      <form onSubmit={addTodo} className="add-form">
        <input
          type="text"
          value={newTodo}
          onChange={(e) => setNewTodo(e.target.value)}
          placeholder="Ajouter une nouvelle tâche..."
          className="add-input"
        />
        <button type="submit" className="add-button">
          ➕ Ajouter
        </button>
      </form>

      <div className="todos-container">
        {todos.length === 0 ? (
          <p className="empty-state">
            Aucune tâche pour le moment. Ajoutez-en une !
          </p>
        ) : (
          <ul className="todos-list">
            {todos.map((todo) => (
              <li
                key={todo.id}
                className={`todo-item ${todo.completed ? "completed" : ""}`}
              >
                <div className="todo-content">
                  <input
                    type="checkbox"
                    checked={todo.completed}
                    onChange={(e) => toggleTodo(todo.id, e.target.checked)}
                    className="todo-checkbox"
                  />

                  {editingId === todo.id ? (
                    <div className="edit-form">
                      <input
                        type="text"
                        value={editingText}
                        onChange={(e) => setEditingText(e.target.value)}
                        className="edit-input"
                        autoFocus
                      />
                      <div className="edit-buttons">
                        <button
                          onClick={() => saveEdit(todo.id)}
                          className="save-button"
                        >
                          ✅ Sauver
                        </button>
                        <button onClick={cancelEdit} className="cancel-button">
                          ❌ Annuler
                        </button>
                      </div>
                    </div>
                  ) : (
                    <span className="todo-text">{todo.text}</span>
                  )}
                </div>

                {editingId !== todo.id && (
                  <div className="todo-actions">
                    <button
                      onClick={() => startEditing(todo.id, todo.text)}
                      className="edit-button"
                    >
                      ✏️ Modifier
                    </button>
                    <button
                      onClick={() => deleteTodo(todo.id)}
                      className="delete-button"
                    >
                      🗑️ Supprimer
                    </button>
                  </div>
                )}
              </li>
            ))}
          </ul>
        )}
      </div>

      <div className="stats">
        <p>
          Total : {todos.length} tâche{todos.length !== 1 ? "s" : ""} | Terminée
          {todos.filter((t) => t.completed).length !== 1 ? "s" : ""} :{" "}
          {todos.filter((t) => t.completed).length} | En cours :{" "}
          {todos.filter((t) => !t.completed).length}
        </p>
      </div>
    </div>
  );
};

export default App;
