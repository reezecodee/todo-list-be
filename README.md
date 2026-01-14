```
dart_backend_proper/
├── 🐳 DEVOPS & CONFIG
├── docker-compose.yaml      # Buat jalanin Postgres & Redis di laptop
├── Dockerfile               # Buat Production (Jenkins)
├── Jenkinsfile              # Script Automasi Jenkins
├── pubspec.yaml
├── analysis_options.yaml
├── .env                     # Config Database (Local)
│
├── 🚦 HTTP LAYER (Routes)
├── routes/
│   ├── _middleware.dart     # 1. Inject Database & Redis ke sini
│   ├── index.dart           # Health check
│   └── api/
│       └── v1/
│           └── todos/       # Contoh fitur CRUD
│               ├── index.dart    # Handle GET all & POST
│               └── [id].dart     # Handle GET one, PUT, DELETE
│
└── 🧠 CORE LOGIC (Lib)
    ├── lib/
    │   ├── database/        # Setup Koneksi (biar rapi)
    │   │   └── db_connection.dart  # Class buat connect Postgres & Redis
    │   │
    │   ├── models/          # Bentuk Data (Class Dart)
    │   │   └── todo_model.dart     # Definisi: id, title, completed
    │   │
    │   └── services/        # Logic Bisnis (CRUD sesungguhnya di sini)
    │       └── todo_service.dart   # Isinya: getAll(), create(), update()...
```